/****** Object:  StoredProcedure [dbo].[sp_CargarTiposMovimientosXML]    Script Date: 28/4/2026 21:56:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_CargarTiposMovimientosXML] 
    @outResultCode INT OUTPUT 
AS
BEGIN
    SET NOCOUNT ON;

    -- XML segmentado verticalmente para evitar la línea larga
    DECLARE @xmlData XML = 
    '<Datos>
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
            INSERT INTO dbo.TipoMovimiento (
                Id
                , Nombre
                , TipoAccion
            )
            SELECT 
                T.Item.value('@Id', 'INT')
                , T.Item.value('@Nombre', 'VARCHAR(100)')
                , T.Item.value('@TipoAccion', 'VARCHAR(10)')
            FROM @xmlData.nodes('//TipoMovimiento') AS T(Item);
        COMMIT TRANSACTION
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION; 
            
        SET @outResultCode = 50008;
    END CATCH
END;
