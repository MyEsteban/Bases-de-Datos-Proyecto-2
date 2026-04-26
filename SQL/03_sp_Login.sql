CREATE OR ALTER PROCEDURE dbo.sp_Login
    @inUsername VARCHAR(100)
    , @inPassword VARCHAR(100)
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @userId INT
        , @intentosFallidos INT;

    BEGIN TRY
        SET @outResultCode = 0;

        -- Contar intentos fallidos en últimos 20 minutos por IP
        SELECT
            @intentosFallidos = COUNT(*)
        FROM dbo.BitacoraEvento AS BE
        WHERE (BE.IdTipoEvento = 2) -- Paréntesis obligatorios en condiciones
          AND (BE.IpPostIn = @inIpPostIn)
          AND (BE.PostTime >= DATEADD(MINUTE, -20, GETDATE()));

        -- Bloqueo por exceso de intentos (R1)
        IF (@intentosFallidos >= 5)
        BEGIN
            SET @outResultCode = 50003; -- Código según catálogo de errores

            INSERT INTO dbo.BitacoraEvento (
                IdTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
                , PostTime
            )
            VALUES (
                3 -- Evento de bloqueo
                , 'Login deshabilitado'
                , NULL
                , @inIpPostIn
                , GETDATE()
            );

            RETURN;
        END

        -- Búsqueda de usuario con alias obligatorio
        SELECT
            @userId = U.Id
        FROM dbo.Usuario AS U
        WHERE (U.Username = @inUsername)
          AND (U.Password = @inPassword);

        -- Manejo de login fallido
        IF (@userId IS NULL)
        BEGIN
            SET @outResultCode = 50001;

            INSERT INTO dbo.BitacoraEvento (
                IdTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
                , PostTime
            )
            VALUES (
                2
                , 'Intento fallido #' + CAST(@intentosFallidos + 1 AS VARCHAR)
                , NULL
                , @inIpPostIn
                , GETDATE()
            );

            RETURN;
        END

        -- Login exitoso
        INSERT INTO dbo.BitacoraEvento (
            IdTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
            , PostTime
        )
        VALUES (
            1
            , 'Exitoso'
            , @userId
            , @inIpPostIn
            , GETDATE()
        );

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
            @inUsername
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ERROR_PROCEDURE()
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
GO
