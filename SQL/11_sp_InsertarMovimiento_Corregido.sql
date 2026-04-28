/****** Object:  StoredProcedure [dbo].[sp_InsertarMovimiento]    Script Date: 28/4/2026 09:05:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_InsertarMovimiento]
    @inIdEmpleado INT
    , @inIdTipoMovimiento INT
    , @inMonto DECIMAL(18, 2)
    , @inIdUsuario INT
    , @inIpPostIn VARCHAR(64)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NuevoSaldo DECIMAL(18, 2);
    DECLARE @FechaActual DATETIME = GETDATE();
    DECLARE @TipoAccion VARCHAR(16);

    BEGIN TRY
        SET @outResultCode = 0;

        -- 1. Obtenemos la acción (Crédito/Débito) del tipo de movimiento
        SELECT @TipoAccion = TipoAccion 
        FROM dbo.TipoMovimiento 
        WHERE Id = @inIdTipoMovimiento;

        -- 2. Calculamos el Nuevo Saldo según la acción
        IF (@TipoAccion = 'Debito')
        BEGIN
            -- Si es débito, restamos el monto al saldo actual
            SELECT @NuevoSaldo = SaldoVacaciones - @inMonto 
            FROM dbo.Empleado 
            WHERE Id = @inIdEmpleado;
        END
        ELSE
        BEGIN
            -- Si es crédito (o cualquier otro), sumamos
            SELECT @NuevoSaldo = SaldoVacaciones + @inMonto 
            FROM dbo.Empleado 
            WHERE Id = @inIdEmpleado;
        END

        BEGIN TRANSACTION;
            -- 3. Inserción en Movimiento
            INSERT INTO dbo.Movimiento (
                IdEmpleado
                , IdTipoMovimiento
                , Fecha
                , Monto
                , NuevoSaldo
                , IdUsuario
                , IpPostIn
                , PostTime
            )
            VALUES (
                @inIdEmpleado
                , @inIdTipoMovimiento
                , @FechaActual
                , @inMonto
                , @NuevoSaldo
                , @inIdUsuario
                , @inIpPostIn
                , @FechaActual
            );

            -- 4. Actualización del maestro Empleado
            UPDATE dbo.Empleado 
            SET SaldoVacaciones = @NuevoSaldo 
            WHERE Id = @inIdEmpleado;

            -- 5. Bitácora
            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
                , PostTime
            )
            VALUES (
                16
                , CONCAT('Mov registrado. Tipo: ', @TipoAccion, ' Emp ID: ', @inIdEmpleado)
                , @inIdUsuario
                , @inIpPostIn
                , @FechaActual
            );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @outResultCode = 50009;
        -- 5. REGISTRO DE ERROR EN TABLA ADMINISTRATIVA
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
            , 'sp_InsertarMovimiento'
            , ERROR_MESSAGE()
            , GETDATE()
        );
    END CATCH
END;
