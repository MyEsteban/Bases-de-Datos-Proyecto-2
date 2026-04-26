-- =============================================
-- ACTUALIZACIÓN DE SALDOS BASADA EN MOVIMIENTOS
-- =============================================
BEGIN TRY
    BEGIN TRANSACTION;

    -- Usamos un Common Table Expression (CTE) para calcular el saldo neto por empleado
    WITH SaldoCalculado AS (
        SELECT 
            M.IdEmpleado,
            SUM(CASE 
                WHEN TM.TipoAccion = 'Credito' THEN M.Monto 
                WHEN TM.TipoAccion = 'Debito' THEN -M.Monto 
                ELSE 0 
            END) AS SaldoFinal
        FROM dbo.Movimiento M
        INNER JOIN dbo.TipoMovimiento TM ON M.IdTipoMovimiento = TM.Id
        GROUP BY M.IdEmpleado
    )
    UPDATE E
    SET E.SaldoVacaciones = S.SaldoFinal
    FROM dbo.Empleado E
    INNER JOIN SaldoCalculado S ON E.Id = S.IdEmpleado;

    COMMIT TRANSACTION;
    PRINT 'Saldos de vacaciones actualizados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error al actualizar saldos: ' + ERROR_MESSAGE();
END CATCH;
GO
