/****** Object:  StoredProcedure [dbo].[sp_CargarCatalogoErroresXML]    Script Date: 28/4/2026 21:47:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_CargarCatalogoErroresXML] @outResultCode INT OUTPUT AS
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
            -- Aquí NO usamos IDENTITY_INSERT porque dejamos que el Id (PK) se genere solo
            INSERT INTO dbo.Error (Codigo, Descripcion)
            SELECT 
                T.Item.value('@Codigo', 'INT'), 
                T.Item.value('@Descripcion', 'VARCHAR(250)')
            FROM @xmlData.nodes('//error') AS T(Item);
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; SET @outResultCode = 50008;
    END CATCH
END;
