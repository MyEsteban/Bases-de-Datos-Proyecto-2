SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_CargarTiposMovimientosXML
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xmlData XML = '
    <Datos>
        <TiposMovimientos>
            <TipoMovimiento Id="1" Nombre="Cumplir mes" TipoAccion="Credito"/>
            <TipoMovimiento Id="2" Nombre="Bono vacacional" TipoAccion="Credito"/>
            <TipoMovimiento Id="3" Nombre="Reversion Debito" TipoAccion="Credito"/>
            <TipoMovimiento Id="4" Nombre="Disfrute de vacaciones" TipoAccion="Debito"/>
            <TipoMovimiento Id="5" Nombre="Venta de vacaciones" TipoAccion="Debito"/>
            <TipoMovimiento Id="6" Nombre="Reversion de Credito" TipoAccion="Debito"/>
        </TiposMovimientos>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dbo.TipoMovimiento (Id, Nombre, TipoAccion)
            SELECT 
                T.Item.value('@Id', 'INT')
                , T.Item.value('@Nombre', 'VARCHAR(100)')
                , T.Item.value('@TipoAccion', 'VARCHAR(10)')
            FROM @xmlData.nodes('/Datos/TiposMovimientos/TipoMovimiento') AS T(Item);
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @outResultCode = 50008;
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message)
        VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), 'sp_CargarTiposMovimientosXML', ERROR_MESSAGE());
    END CATCH
END;
