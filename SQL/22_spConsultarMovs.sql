/****** Object:  StoredProcedure [dbo].[sp_ConsultarMovimientos]    Script Date: 28/4/2026 09:09:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_ConsultarMovimientos]
    @inIdEmpleado INT
    , @inIdUsuario INT 
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. CONTROL DE FLUJO: Verificar existencia del empleado usando la tabla física
        IF (NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE Id = @inIdEmpleado))
        BEGIN
            SET @outResultCode = 50002; -- Empleado no existe
            RETURN;
        END

        -- 2. REGISTRO EN BITÁCORA: Usando las columnas exactas de tu tabla
        INSERT INTO dbo.BitacoraEvento (
            IdTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
            , PostTime
        )
        VALUES (
            15 -- ID para 'Consulta de movimientos'
            , CONCAT('Consulta de movimientos para empleado ID: ', CAST(@inIdEmpleado AS VARCHAR))
            , @inIdUsuario
            , @inIpPostIn
            , GETDATE()
        );

        -- 3. CONSULTA FINAL: Alineada con el modelo Movimiento.cs y las tablas físicas
        SELECT 
            M.Id
            , M.Fecha
            , TM.Nombre AS TipoMovimiento
            , TM.TipoAccion 
            , M.Monto
            , M.NuevoSaldo
            , U.Username AS NombreUsuario -- Alias para mapear a la propiedad en C#
            , M.PostTime            -- Columna física de la tabla Movimiento
        FROM dbo.Movimiento AS M
        INNER JOIN dbo.TipoMovimiento AS TM ON (M.IdTipoMovimiento = TM.Id)
        INNER JOIN dbo.Usuario AS U ON (M.IdUsuario = U.Id)
        WHERE (M.IdEmpleado = @inIdEmpleado)
        ORDER BY M.Fecha DESC, M.Id DESC;

    END TRY
    BEGIN CATCH
        SET @outResultCode = 50008; 
        
        -- Registro de error en tabla administrativa
        INSERT INTO dbo.DBError (
            UserName
            , Number
            , State
            , Severity
            , Line
            , [Procedure]
            , Message
            , DateTime
        )
        VALUES (
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , 'sp_ConsultarMovimientos'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
