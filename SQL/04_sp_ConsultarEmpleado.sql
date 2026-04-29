ALTER PROCEDURE [dbo].[sp_ConsultarEmpleado]
    @inNombre VARCHAR(100)
    , @inDocumentoIdentidad VARCHAR(20)
    , @inIdUsuario INT
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. Registro en Bitácora (R7)
        INSERT INTO dbo.BitacoraEvento (
            IdTipoEvento
            , Descripcion
            , IdUsuario
            , IpPostIn
            , PostTime
        )
        VALUES (
            11 
            , CONCAT('Consulta Empleados. Filtros - Nombre: ', ISNULL(@inNombre, 'N/A'), ', Doc: ', ISNULL(@inDocumentoIdentidad, 'N/A'))
            , @inIdUsuario
            , @inIpPostIn
            , GETDATE()
        );

        -- 2. Consulta con búsqueda parcial (LIKE)
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
        WHERE (
                (@inNombre IS NULL OR @inNombre = '') 
                OR (E.Nombre LIKE '%' + @inNombre + '%')
              )
          AND (
                (@inDocumentoIdentidad IS NULL OR @inDocumentoIdentidad = '') 
                OR (E.ValorDocumentoIdentidad LIKE '%' + @inDocumentoIdentidad + '%')
              )
          AND (E.EsActivo = 1)
        ORDER BY E.Nombre ASC;

    END TRY
    BEGIN CATCH
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
            , 'sp_ConsultarEmpleado'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
