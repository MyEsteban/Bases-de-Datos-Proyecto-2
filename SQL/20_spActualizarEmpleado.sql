/****** Object:  StoredProcedure [dbo].[sp_ActualizarEmpleado]    Script Date: 28/4/2026 09:07:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_ActualizarEmpleado]
    @inId INT
    , @inNombre VARCHAR(100)
    , @inValorDocumentoIdentidad VARCHAR(20)
    , @inIdPuesto INT
    , @inFechaContratacion DATE
    , @inIdUsuario INT 
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Variables de control
    DECLARE @NombreInvalido BIT = 0;
    DECLARE @IdentidadInvalida BIT = 0;

    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. PRE-PROCESO: Validaciones de formato (R4)
        IF (@inNombre LIKE '%[^a-zA-Z ]%') 
            SET @NombreInvalido = 1;

        IF (@inValorDocumentoIdentidad LIKE '%[^0-9]%') 
            SET @IdentidadInvalida = 1;

        -- 2. CONTROL DE FLUJO: Validar errores de negocio
        IF (@NombreInvalido = 1)
        BEGIN
            SET @outResultCode = 50009; -- Nombre no alfabético
            RETURN;
        END

        IF (@IdentidadInvalida = 1)
        BEGIN
            SET @outResultCode = 50010; -- Documento no numérico
            RETURN;
        END

        -- Validar que el documento no lo tenga OTRO empleado (R4)
        IF (EXISTS(SELECT 1 FROM dbo.Empleado AS E WHERE (E.ValorDocumentoIdentidad = @inValorDocumentoIdentidad) AND (E.Id <> @inId)))
        BEGIN
            SET @outResultCode = 50006; -- Documento ya existe en otro empleado
            RETURN;
        END

        -- 3. TRANSACCIÓN: Actualización de datos
        BEGIN TRANSACTION;

            UPDATE E
            SET E.Nombre = @inNombre
                , E.ValorDocumentoIdentidad = @inValorDocumentoIdentidad
                , E.IdPuesto = @inIdPuesto
                , E.FechaContratacion = @inFechaContratacion
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
                8 -- IdTipoEvento para 'Update exitoso'
                , CONCAT('Actualización de empleado ID: ', CAST(@inId AS VARCHAR))
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
            , 'sp_ActualizarEmpleado'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
