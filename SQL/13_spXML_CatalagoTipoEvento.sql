/****** Object:  StoredProcedure [dbo].[sp_CargarTiposEventoXML]    Script Date: 28/4/2026 21:54:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_CargarTiposEventoXML] 
    @outResultCode INT OUTPUT 
AS
BEGIN
    SET NOCOUNT ON;

    -- XML segmentado verticalmente para cumplir el estándar de lectura
    DECLARE @xmlData XML = 
    '<Datos>
        <TiposEvento>
            <TipoEvento Id="1" Nombre="Login Exitoso"/>
            <TipoEvento Id="2" Nombre="Login No Exitoso"/>
            <TipoEvento Id="3" Nombre="Login deshabilitado"/>
            <TipoEvento Id="4" Nombre="Logout"/>
            <TipoEvento Id="5" Nombre="Insercion no exitosa"/>
            <TipoEvento Id="6" Nombre="Insercion exitosa"/>
            <TipoEvento Id="7" Nombre="Update no exitoso"/>
            <TipoEvento Id="8" Nombre="Update exitoso"/>
            <TipoEvento Id="9" Nombre="Intento de borrado"/>
            <TipoEvento Id="10" Nombre="Borrado exitoso"/>
            <TipoEvento Id="11" Nombre="Consulta con filtro de nombre"/>
            <TipoEvento Id="12" Nombre="Consulta con filtro de cedula"/>
            <TipoEvento Id="13" Nombre="Intento de insertar movimiento"/>
            <TipoEvento Id="14" Nombre="Insertar movimiento exitoso"/>
        </TiposEvento>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
            -- Inserción manual de IDs (ya que no tiene Identity)
            INSERT INTO dbo.TipoEvento (
                Id
                , Nombre
            )
            SELECT 
                T.Item.value('@Id', 'INT')
                , T.Item.value('@Nombre', 'VARCHAR(100)')
            FROM @xmlData.nodes('/Datos/TiposEvento/TipoEvento') AS T(Item);
        COMMIT TRANSACTION
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
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
            , 'sp_CargarTiposEventoXML'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
