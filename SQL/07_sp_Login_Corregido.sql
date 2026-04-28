/****** Object:  StoredProcedure [dbo].[sp_Login]    Script Date: 28/4/2026 09:01:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_Login]
    @inUsername VARCHAR(50)
    , @inPassword VARCHAR(50)
    , @inIpPostIn VARCHAR(50) -- Cambiado para ser consistente con el estándar
    , @outResultCode INT OUTPUT
    , @outIdUsuario INT OUTPUT  
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @userId INT
        , @intentosFallidos INT;

    BEGIN TRY
        -- Contar intentos fallidos en últimos 20 minutos por IP
        SELECT
            @intentosFallidos = COUNT(*)
        FROM dbo.BitacoraEvento
        WHERE idTipoEvento = 2
          AND IpPostIn = @inIpPostIn
          AND PostTime >= DATEADD(MINUTE, -20, GETDATE());

        -- Bloqueo por exceso de intentos
        IF @intentosFallidos >= 5
        BEGIN
            SET @outResultCode = 50004;

            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
            )
            VALUES (
                2
                , 'Login deshabilitado'
                , NULL
                , @inIpPostIn
            );

            RETURN;
        END

        -- Búsqueda de usuario
        SELECT
            @userId = Id
        FROM dbo.Usuario
        WHERE Username = @inUsername
          AND Password = @inPassword;

        -- Manejo de login fallido
        IF @userId IS NULL
        BEGIN
            SET @outResultCode = 50001;

            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
            )
            VALUES (
                2
                , 'Intento fallido #' + CAST(@intentosFallidos + 1 AS VARCHAR)
                , NULL
                , @inIpPostIn
            );

            RETURN;
        END

        -- Login exitoso
        SET @outResultCode = 0;
        SET @outIdUsuario = @userId;

        INSERT INTO dbo.BitacoraEvento (
            idTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
        )
        VALUES (
            1
            , 'Exitoso'
            , @userId
            , @inIpPostIn
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
        )
        VALUES (
            @inUsername
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ERROR_PROCEDURE()
            , ERROR_MESSAGE()
        );
    END CATCH
END;
