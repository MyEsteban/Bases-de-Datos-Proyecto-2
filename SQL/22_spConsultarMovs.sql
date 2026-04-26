CREATE OR ALTER PROCEDURE dbo.sp_ConsultarMovimientos
    @inIdEmpleado INT
    , @inIdUsuario INT -- Usuario que consulta para la bitácora
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. CONTROL DE FLUJO: Verificar que el empleado exista
        IF (NOT EXISTS(SELECT 1 FROM dbo.Empleado AS E WHERE (E.Id = @inIdEmpleado)))
        BEGIN
            SET @outResultCode = 50002; -- Empleado no existe
            RETURN;
        END

        -- 2. REGISTRO EN BITÁCORA (R7)
        INSERT INTO dbo.BitacoraEvento (
            IdTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
            , PostTime
        )
        VALUES (
            15 -- Asumiendo Id para 'Consulta de movimientos'
            , CONCAT('Consulta de movimientos para empleado ID: ', CAST(@inIdEmpleado AS VARCHAR))
            , @inIdUsuario
            , @inIpPostIn
            , GETDATE()
        );

        -- 3. CONSULTA DE MOVIMIENTOS (R5)
        -- Traemos el detalle vinculando con TipoMovimiento para saber si fue Crédito o Débito
        SELECT 
            M.Id
            , M.Fecha
            , TM.Nombre AS TipoMovimiento
            , TM.TipoAccion -- Para saber si sumó o restó
            , M.Monto
            , M.NuevoSaldo
        FROM dbo.Movimiento AS M
        INNER JOIN dbo.TipoMovimiento AS TM 
            ON (M.IdTipoMovimiento = TM.Id)
        WHERE (M.IdEmpleado = @inIdEmpleado)
        ORDER BY M.Fecha DESC, M.Id DESC; -- Los más recientes primero

    END TRY
    BEGIN CATCH
        SET @outResultCode = 50008; 
        
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
GO
