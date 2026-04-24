CREATE PROCEDURE dbo.sp_InsertarEmpleado
    @inIdPuesto INT,
    @inDocumento VARCHAR(20),
    @inNombre VARCHAR(100),
    @inFechaContratacion DATE,
    @inIdPostByUser INT,
    @inPostInIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- validacion de que el documento no este repedito
        IF EXISTS (
            SELECT 1
            FROM dbo.Empleado
            WHERE ValorDocumentoIdentidad = @inDocumento
        )
        BEGIN
            SET @outResultCode = 50002;
            RETURN;
        END

        -- validacion de que el nombre no este repetido
        IF EXISTS (
            SELECT 1
            FROM dbo.Empleado
            WHERE Nombre = @inNombre
        )
        BEGIN
            SET @outResultCode = 50003;
            RETURN;
        END

        -- para insertar empleado
        INSERT INTO dbo.Empleado (
            IdPuesto,
            ValorDocumentoIdentidad,
            Nombre,
            FechaContratacion,
            SaldoVacaciones,
            EsActivo,
            IdPostByUser,
            PostInIP
        )
        VALUES (
            @inIdPuesto,
            @inDocumento,
            @inNombre,
            @inFechaContratacion,
            0,
            1,
            @inIdPostByUser,
            @inPostInIP
        );
        
        --bitacora
        INSERT INTO dbo.BitacoraEvento (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP
        )
        VALUES (
            3,
            'Empleado insertado correctamente',
            @inIdPostByUser,
            @inPostInIP
        );

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH

        SET @outResultCode = 50008;

        INSERT INTO dbo.DBError (
            UserName,
            Number,
            State,
            Severity,
            Line,
            [Procedure],
            Message
        )
        VALUES (
            'sp_InsertarEmpleado',
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE()
        );

    END CATCH
END;