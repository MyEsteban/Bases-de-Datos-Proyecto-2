SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_CargarEmpleadosXML
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xmlData XML = '
    <Datos>
        <Empleados>
            <empleado Puesto="Camarero" ValorDocumentoIdentidad="6993943" Nombre="Kaitlyn Jensen" FechaContratacion="2017-12-07"/>
            <empleado Puesto="Albañil" ValorDocumentoIdentidad="1896802" Nombre="Robert Buchanan" FechaContratacion="2020-09-20"/>
            <empleado Puesto="Cajero" ValorDocumentoIdentidad="5095109" Nombre="Christina Ward" FechaContratacion="2015-09-13"/>
            <empleado Puesto="Fontanero" ValorDocumentoIdentidad="8403646" Nombre="Bradley Wright" FechaContratacion="2020-01-27"/>
            <empleado Puesto="Conserje" ValorDocumentoIdentidad="6019592" Nombre="Robert Singh" FechaContratacion="2017-02-01"/>
            <empleado Puesto="Asistente" ValorDocumentoIdentidad="4510358" Nombre="Ryan Mitchell" FechaContratacion="2018-06-08"/>
            <empleado Puesto="Asistente" ValorDocumentoIdentidad="7517662" Nombre="Candace Fox" FechaContratacion="2013-12-17"/>
            <empleado Puesto="Asistente" ValorDocumentoIdentidad="8326328" Nombre="Allison Murillo" FechaContratacion="2020-04-19"/>
            <empleado Puesto="Cuidador" ValorDocumentoIdentidad="2161775" Nombre="Jessica Murphy" FechaContratacion="2017-04-12"/>
            <empleado Puesto="Fontanero" ValorDocumentoIdentidad="2918773" Nombre="Nancy Newton PhD" FechaContratacion="2016-11-22"/>
            <empleado Puesto="Conductor" ValorDocumentoIdentidad="9772211" Nombre="Alicia Ortega" FechaContratacion="2021-05-14"/>
            <empleado Puesto="Recepcionista" ValorDocumentoIdentidad="6641189" Nombre="Pedro Salas" FechaContratacion="2019-03-21"/>
            <empleado Puesto="Niñera" ValorDocumentoIdentidad="3389054" Nombre="Sofía Herrera" FechaContratacion="2022-08-09"/>
        </Empleados>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dbo.Empleado (IdPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, EsActivo)
            SELECT 
                P.Id
                , T.Item.value('@ValorDocumentoIdentidad', 'VARCHAR(20)')
                , T.Item.value('@Nombre', 'VARCHAR(100)')
                , T.Item.value('@FechaContratacion', 'DATE')
                , 0, 1
            FROM @xmlData.nodes('/Datos/Empleados/empleado') AS T(Item)
            INNER JOIN dbo.Puesto P ON P.Nombre = T.Item.value('@Puesto', 'VARCHAR(100)');
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @outResultCode = 50008;
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message)
        VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), 'sp_CargarEmpleadosXML', ERROR_MESSAGE());
    END CATCH
END;
