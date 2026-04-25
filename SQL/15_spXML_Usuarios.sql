SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_CargarUsuariosXML
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xmlData XML = '
    <Datos>
        <Usuarios>
            <usuario Id="1" Nombre="UsuarioScripts" Pass="UsuarioScripts"/>
            <usuario Id="2" Nombre="mgarrison" Pass=")*2LnSr^lk"/>
            <usuario Id="3" Nombre="jgonzalez" Pass="3YSI0HtiXI"/>
            <usuario Id="4" Nombre="zkelly" Pass="X4US4aLam@"/>
            <usuario Id="5" Nombre="andersondeborah" Pass="732F34xo%S"/>
            <usuario Id="6" Nombre="hardingmicheal" Pass="himB9Dzd%_"/>
            <usuario Id="7" Nombre="martinezlisa" Pass="7Kp9vQ2mT1"/>
            <usuario Id="8" Nombre="floresdaniel" Pass="H4s8Nq3xL6"/>
            <usuario Id="9" Nombre="perezmaria" Pass="R2m7Bv5cZ8"/>
            <usuario Id="10" Nombre="torresluis" Pass="J9t6Wk4pS3"/>
        </Usuarios>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dbo.Usuario (Id, Username, Password)
            SELECT 
                T.Item.value('@Id', 'INT')
                , T.Item.value('@Nombre', 'VARCHAR(50)')
                , T.Item.value('@Pass', 'VARCHAR(50)')
            FROM @xmlData.nodes('/Datos/Usuarios/usuario') AS T(Item);
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @outResultCode = 50008;
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message)
        VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), 'sp_CargarUsuariosXML', ERROR_MESSAGE());
    END CATCH
END;
