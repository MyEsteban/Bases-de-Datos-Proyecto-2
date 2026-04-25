SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_CargarCatalogoErroresXML
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xmlData XML = '
    <Datos>
        <Error>
            <error Codigo="50001" Descripcion="Username no existe"/>
            <error Codigo="50002" Descripcion="Password no existe"/>
            <error Codigo="50003" Descripcion="Login deshabilitado"/>
            <error Codigo="50004" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en inserción"/>
            <error Codigo="50005" Descripcion="Empleado con mismo nombre ya existe en inserción"/>
            <error Codigo="50006" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en actualizacion"/>
            <error Codigo="50007" Descripcion="Empleado con mismo nombre ya existe en actualización"/>
            <error Codigo="50008" Descripcion="Error de base de datos"/>
            <error Codigo="50009" Descripcion="Nombre de empleado no alfabético"/>
            <error Codigo="50010" Descripcion="Valor de documento de identidad no alfabético"/>
            <error Codigo="50011" Descripcion="Monto del movimiento rechazado pues si se aplicar el saldo seria negativo."/>
        </Error>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
            INSERT INTO dbo.Error (Codigo, Descripcion)
            SELECT 
                T.Item.value('@Codigo', 'INT')
                , T.Item.value('@Descripcion', 'VARCHAR(250)')
            FROM @xmlData.nodes('/Datos/Error/error') AS T(Item);
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @outResultCode = 50008;
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message)
        VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), 'sp_CargarCatalogoErroresXML', ERROR_MESSAGE());
    END CATCH
END;
