-- 1. Procedimiento para Consultar Puestos
CREATE PROCEDURE [dbo].[sp_ConsultarPuestos]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        Id
        , Nombre
        , SalarioxHora
    FROM dbo.Puesto
    ORDER BY Nombre ASC;
END;
GO

-- 2. Procedimiento para Obtener Empleado por ID
CREATE PROCEDURE [dbo].[sp_ObtenerEmpleadoPorId]
    @inId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        Id
        , Nombre
        , ValorDocumentoIdentidad
        , IdPuesto
        , FechaContratacion
        , SaldoVacaciones
    FROM dbo.Empleado 
    WHERE (Id = @inId);
END;
GO

-- 3. Procedimiento para Consultar Tipos de Movimiento
CREATE PROCEDURE [dbo].[sp_ConsultarTiposMovimiento]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        Id
        , Nombre
        , TipoAccion
    FROM dbo.TipoMovimiento
    ORDER BY Nombre ASC;
END;
GO
