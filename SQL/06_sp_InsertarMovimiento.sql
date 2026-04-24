CREATE PROCEDURE dbo.sp_InsertarMovimiento
    @inIdEmpleado INT,
    @inIdTipoMovimiento INT,
    @inMonto DECIMAL(10,2),
    @inFecha DATE,
    @inIdPostByUser INT,
    @inPostInIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @saldoActual DECIMAL(10,2),
        @nuevoSaldo DECIMAL(10,2),
        @tipoAccion VARCHAR(10);

    BEGIN TRY

        SELECT
            @saldoActual = SaldoVacaciones
        FROM dbo.Empleado
        WHERE Id = @inIdEmpleado;

        SELECT
            @tipoAccion = TipoAccion
        FROM dbo.TipoMovimiento
        WHERE Id = @inIdTipoMovimiento;

        -- Crédito o Débito
        IF @tipoAccion = 'Credito'
            SET @nuevoSaldo = @saldoActual + @inMonto;
        ELSE
            SET @nuevoSaldo = @saldoActual - @inMonto;

        -- Validar saldo negativo
        IF @nuevoSaldo < 0
        BEGIN
            SET @outResultCode = 50010;
            RETURN;
        END

        BEGIN TRANSACTION

            INSERT INTO dbo.Movimiento (
                IdEmpleado,
                IdTipoMovimiento,
                Fecha,
                Monto,
                NuevoSaldo,
                IdPostByUser,
                PostInIP
            )
            VALUES (
                @inIdEmpleado,
                @inIdTipoMovimiento,
                @inFecha,
                @inMonto,
                @nuevoSaldo,
                @inIdPostByUser,
                @inPostInIP
            );

            UPDATE dbo.Empleado
            SET SaldoVacaciones = @nuevoSaldo
            WHERE Id = @inIdEmpleado;

            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento,
                Descripcion,
                IdPostByUser,
                PostInIP
            )
            VALUES (
                4,
                'Movimiento insertado correctamente',
                @inIdPostByUser,
                @inPostInIP
            );

        COMMIT TRANSACTION

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @outResultCode = 50008;

        INSERT INTO dbo.DBError (
            UserName,
            Number,
            State,
            Severity,
            Line,
            [Procedure],
            Message
        )
        VALUES (
            'sp_InsertarMovimiento',
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE()
        );

    END CATCH
END;