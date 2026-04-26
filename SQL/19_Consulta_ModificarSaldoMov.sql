-- =============================================
-- ACTUALIZACIÓN DE NUEVO SALDO (HISTÓRICO)
-- =============================================
BEGIN TRY
    BEGIN TRANSACTION;

    -- Calculamos el saldo acumulado fila por fila
    WITH CalculoSaldo AS (
        SELECT 
            M.Id,
            SUM(CASE 
                WHEN TM.TipoAccion = 'Credito' THEN M.Monto 
                WHEN TM.TipoAccion = 'Debito' THEN -M.Monto 
                ELSE 0 
            END) OVER (
                PARTITION BY M.IdEmpleado 
                ORDER BY M.Fecha, M.Id -- Ordenamos por fecha e ID para consistencia
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS SaldoProgresivo
        FROM dbo.Movimiento M
        INNER JOIN dbo.TipoMovimiento TM ON M.IdTipoMovimiento = TM.Id
    )
    UPDATE M
    SET M.NuevoSaldo = C.SaldoProgresivo
    FROM dbo.Movimiento M
    INNER JOIN CalculoSaldo C ON M.Id = C.Id;

    COMMIT TRANSACTION;
    PRINT 'Columna NuevoSaldo en Movimientos actualizada con éxito.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error en actualización de movimientos: ' + ERROR_MESSAGE();
END CATCH;
GO
