/****** Object:  StoredProcedure [dbo].[sp_CargarPuestosXML]    Script Date: 28/4/2026 21:52:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_CargarPuestosXML] 
    @outResultCode INT OUTPUT 
AS
BEGIN
    SET NOCOUNT ON;

    -- XML segmentado para evitar la línea horizontal larga
    DECLARE @xmlData XML = 
    '<Datos>
        <Puestos>
            <Puesto Nombre="Cajero" SalarioxHora="11.00"/>
            <Puesto Nombre="Camarero" SalarioxHora="10.00"/>
            <Puesto Nombre="Cuidador" SalarioxHora="13.50"/>
            <Puesto Nombre="Conductor" SalarioxHora="15.00"/>
            <Puesto Nombre="Asistente" SalarioxHora="11.00"/>
            <Puesto Nombre="Recepcionista" SalarioxHora="12.00"/>
            <Puesto Nombre="Fontanero" SalarioxHora="13.00"/>
            <Puesto Nombre="Niñera" SalarioxHora="12.00"/>
            <Puesto Nombre="Conserje" SalarioxHora="11.00"/>
            <Puesto Nombre="Albañil" SalarioxHora="10.50"/>
        </Puestos>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dbo.Puesto (
                Id
                , Nombre
                , SalarioxHora
            )
            SELECT 
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
                , T.Item.value('@Nombre', 'VARCHAR(100)')
                , T.Item.value('@SalarioxHora', 'DECIMAL(10,2)')
            FROM @xmlData.nodes('//Puesto') AS T(Item);
        COMMIT TRANSACTION
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION; 
            
        SET @outResultCode = 50008;
    END CATCH
END;
