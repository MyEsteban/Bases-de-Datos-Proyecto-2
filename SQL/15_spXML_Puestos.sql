SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_CargarPuestosXML
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xmlData XML = '
    <Datos>
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
            INSERT INTO dbo.Puesto (Nombre, SalarioxHora)
            SELECT 
                T.Item.value('@Nombre', 'VARCHAR(100)')
                , T.Item.value('@SalarioxHora', 'DECIMAL(10,2)')
            FROM @xmlData.nodes('/Datos/Puestos/Puesto') AS T(Item);
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @outResultCode = 50008;
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message)
        VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), 'sp_CargarPuestosXML', ERROR_MESSAGE());
    END CATCH
END;
