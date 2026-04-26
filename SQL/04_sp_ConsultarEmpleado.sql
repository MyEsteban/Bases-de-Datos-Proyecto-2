CREATE OR ALTER PROCEDURE dbo.sp_ConsultarEmpleado
    @inNombre VARCHAR(100)
    , @inDocumentoIdentidad VARCHAR(20)
    , @inIdUsuario INT -- Usuario que realiza la consulta para la bitácora
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. Registro en Bitácora (R7)
        -- Se registra antes de la consulta para dejar traza del intento
        INSERT INTO dbo.BitacoraEvento (
            IdTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
            , PostTime
        )
        VALUES (
            11 -- IdTipoEvento para 'Consulta con filtro'
            , CONCAT('Consulta Empleados. Filtros - Nombre: ', ISNULL(@inNombre, 'N/A'), ', Doc: ', ISNULL(@inDocumentoIdentidad, 'N/A'))
            , @inIdUsuario
            , @inIpPostIn
            , GETDATE()
        );

        -- 2. Consulta con Filtros (R2)
        -- Se usa alias obligatorio y paréntesis en condiciones
        SELECT 
            E.Id
            , E.Nombre
            , E.ValorDocumentoIdentidad
            , P.Nombre AS Puesto
            , E.SaldoVacaciones
            , E.FechaContratacion
            , E.EsActivo
        FROM dbo.Empleado AS E
        INNER JOIN dbo.Puesto AS P 
            ON (E.IdPuesto = P.Id)
        WHERE ((@inNombre IS NULL) OR (E.Nombre LIKE '%' + @inNombre + '%'))
          AND ((@inDocumentoIdentidad IS NULL) OR (E.ValorDocumentoIdentidad = @inDocumentoIdentidad))
          AND (E.EsActivo = 1) -- Solo empleados activos según lógica usual
        ORDER BY E.Nombre ASC;

    END TRY
    BEGIN CATCH
        SET @outResultCode = 50008; -- Error de base de datos
        
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
            , 'sp_ConsultarEmpleados'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
GO
