CREATE PROCEDURE dbo.sp_Login
    @inUsername VARCHAR(50),
    @inPassword VARCHAR(50),
    @inIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @userId INT;

    BEGIN TRY

        SELECT @userId = Id
        FROM dbo.Usuario
        WHERE Username = @inUsername
          AND Password = @inPassword;

        -- Login fallido
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
                'Login fallido',
                NULL,
                @inIP
            );

            RETURN;
        END

        -- Login exitoso
        SET @outResultCode = 0;

        INSERT INTO dbo.BitacoraEvento (
            idTipoEvento,
            Descripcion,
            IdPostByUser,
            PostInIP
        )
        VALUES (
            1,
            'Login exitoso',
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