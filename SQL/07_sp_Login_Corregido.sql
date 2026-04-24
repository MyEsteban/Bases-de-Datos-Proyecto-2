CREATE PROCEDURE dbo.sp_Login
    @inUsername VARCHAR(50),
    @inPassword VARCHAR(50),
    @inIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @userId INT,
        @intentosFallidos INT;

    BEGIN TRY
--aqui cuenta la cantidad de intentos fallidos en los ultimos 20 minutos
        SELECT
            @intentosFallidos = COUNT(*)
        FROM dbo.BitacoraEvento
        WHERE idTipoEvento = 2
          AND PostInIP = @inIP
          AND PostTime >= DATEADD(MINUTE, -20, GETDATE());

   --si se intenta muchas cveces se tiene que bloquear
        IF @intentosFallidos >= 5
        BEGIN
            SET @outResultCode = 50004;

            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento,
                Descripcion,
                IdPostByUser,
                PostInIP
            )
            VALUES (
                2,
                'Login deshabilitado',
                NULL,
                @inIP
            );

            RETURN;
        END

        --busca si el usuario es valido
        SELECT
            @userId = Id
        FROM dbo.Usuario
        WHERE Username = @inUsername
          AND Password = @inPassword;

        --y si no existe el login falla
        IF @userId IS NULL
        BEGIN
            SET @outResultCode = 50001;

            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento,
                Descripcion,
                IdPostByUser,
                PostInIP
            )
            VALUES (
                2,
                'Intento fallido #' + CAST(@intentosFallidos + 1 AS VARCHAR),
                NULL,
                @inIP
            );

            RETURN;
        END

        -- Login funciona
        SET @outResultCode = 0;

        INSERT INTO dbo.BitacoraEvento (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP
        )
        VALUES (
            1,
            'Exitoso',
            @userId,
            @inIP
        );

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
            @inUsername,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE()
        );

    END CATCH
END;