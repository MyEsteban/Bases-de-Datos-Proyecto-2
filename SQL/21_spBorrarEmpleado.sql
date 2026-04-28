/****** Object:  StoredProcedure [dbo].[sp_BorrarEmpleado]    Script Date: 28/4/2026 09:08:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_BorrarEmpleado]
    @inId INT
    , @inIdUsuario INT -- Usuario que ejecuta el borrado
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. CONTROL DE FLUJO: Verificar si el empleado existe y está activo
        IF (NOT EXISTS(SELECT 1 FROM dbo.Empleado AS E WHERE (E.Id = @inId) AND (E.EsActivo = 1)))
        BEGIN
            SET @outResultCode = 50002; -- El empleado no existe o ya está borrado
            RETURN;
        END

        -- 2. TRANSACCIÓN: Borrado lógico
        BEGIN TRANSACTION;

            UPDATE E
            SET E.EsActivo = 0
                , E.PostTime = GETDATE()
                , E.IpPostIn = @inIpPostIn
            FROM dbo.Empleado AS E
            WHERE (E.Id = @inId);

            -- Registro en Bitácora (R7)
            INSERT INTO dbo.BitacoraEvento (
                IdTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
                , PostTime
            )
            VALUES (
                9 -- IdTipoEvento para 'Borrado lógico exitoso'
                , CONCAT('Borrado lógico de empleado ID: ', CAST(@inId AS VARCHAR))
                , @inIdUsuario
                , @inIpPostIn
                , GETDATE()
            );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF (@@TRANCOUNT > 0) 
            ROLLBACK TRANSACTION;

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
            , 'sp_BorrarEmpleado'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
