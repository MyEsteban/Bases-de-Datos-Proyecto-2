/****** Object:  StoredProcedure [dbo].[sp_InsertarEmpleado]    Script Date: 28/4/2026 09:03:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_InsertarEmpleado]
    @inNombre VARCHAR(100)
    , @inValorDocumentoIdentidad VARCHAR(20)
    , @inIdPuesto INT
    , @inFechaContratacion DATE
    , @inIdUsuario INT -- Usuario que ejecuta la acción
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Variables para pre-proceso de cálculos
    DECLARE @NombreInvalido BIT = 0;
    DECLARE @IdentidadInvalida BIT = 0;

    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. PRE-PROCESO: Validaciones de formato (R3)
        -- Validar que el nombre solo contenga letras y espacios
        IF (@inNombre LIKE '%[^a-zA-Z ]%') 
            SET @NombreInvalido = 1;

        -- Validar que el documento solo contenga números
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

        -- Verificar duplicados de identificación
        IF (EXISTS(SELECT 1 FROM dbo.Empleado AS E WHERE (E.ValorDocumentoIdentidad = @inValorDocumentoIdentidad)))
        BEGIN
            SET @outResultCode = 50004; -- Empleado ya existe
            RETURN;
        END

        -- 3. TRANSACCIÓN: Inserción de datos
        BEGIN TRANSACTION;

            INSERT INTO dbo.Empleado (
                Nombre
                , ValorDocumentoIdentidad
                , IdPuesto
                , FechaContratacion
                , SaldoVacaciones
                , EsActivo
                , PostTime
                , IpPostIn
            )
            VALUES (
                @inNombre
                , @inValorDocumentoIdentidad
                , @inIdPuesto
                , @inFechaContratacion
                , 0.00 -- Saldo inicial según requerimiento
                , 1    -- EsActivo por defecto
                , GETDATE()
                , @inIpPostIn
            );

            -- Registro en Bitácora (R7)
            INSERT INTO dbo.BitacoraEvento (
                IdTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
                , PostTime
            )
            VALUES (
                6 -- IdTipoEvento para 'Inserción exitosa'
                , CONCAT('Inserción de empleado: ', @inNombre)
                , @inIdUsuario
                , @inIpPostIn
                , GETDATE()
            );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF (@@TRANCOUNT > 0) 
            ROLLBACK TRANSACTION;

        SET @outResultCode = 50008; -- Error de plataforma
        
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
            , 'sp_InsertarEmpleado'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
