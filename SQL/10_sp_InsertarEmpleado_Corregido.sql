/****** Object:  StoredProcedure [dbo].[sp_InsertarEmpleado]    Script Date: 24/4/2026 14:59:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_InsertarEmpleado]
    @inIdPuesto INT
    , @inDocumento VARCHAR(20)
    , @inNombre VARCHAR(100)
    , @inFechaContratacion DATE
    , @inIdUsuario INT
    , @inIpPostIn VARCHAR(50)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validación de que el documento no esté repetido
        IF EXISTS (
            SELECT 1
            FROM dbo.Empleado
            WHERE ValorDocumentoIdentidad = @inDocumento
        )
        BEGIN
            SET @outResultCode = 50002;
            RETURN;
        END

        -- Validación de que el nombre no esté repetido
        IF EXISTS (
            SELECT 1
            FROM dbo.Empleado
            WHERE Nombre = @inNombre
        )
        BEGIN
            SET @outResultCode = 50003;
            RETURN;
        END

        -- Inserción del empleado
        INSERT INTO dbo.Empleado (
            IdPuesto
            , ValorDocumentoIdentidad
            , Nombre
            , FechaContratacion
            , SaldoVacaciones
            , EsActivo
            , IdUsuario
            , IpPostIn
        )
        VALUES (
            @inIdPuesto
            , @inDocumento
            , @inNombre
            , @inFechaContratacion
            , 0
            , 1
            , @inIdUsuario
            , @inIpPostIn
        );
        
        -- Registro en bitácora
        INSERT INTO dbo.BitacoraEvento (
            idTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
        )
        VALUES (
            3
            , 'Empleado insertado correctamente'
            , @inIdUsuario
            , @inIpPostIn
        );

        SET @outResultCode = 0;

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
        )
        VALUES (
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ERROR_PROCEDURE()
            , ERROR_MESSAGE()
        );
    END CATCH
END;
