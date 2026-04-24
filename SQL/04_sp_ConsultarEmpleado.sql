CREATE PROCEDURE dbo.sp_ConsultarEmpleado
    @inNombre VARCHAR(100) = NULL,
    @inDocumento VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        E.Id,
        E.Nombre,
        E.ValorDocumentoIdentidad,
        E.FechaContratacion,
        E.SaldoVacaciones,
        E.EsActivo,
        P.Nombre AS NombrePuesto,
        P.SalarioxHora
    FROM dbo.Empleado E
    INNER JOIN dbo.Puesto P
        ON E.IdPuesto = P.Id
    WHERE
        E.EsActivo = 1
        AND (@inNombre IS NULL OR E.Nombre LIKE '%' + @inNombre + '%')
        AND (@inDocumento IS NULL OR E.ValorDocumentoIdentidad = @inDocumento);
END;