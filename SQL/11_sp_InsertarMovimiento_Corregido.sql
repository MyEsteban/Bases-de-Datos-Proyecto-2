/****** Object:  StoredProcedure [dbo].[sp_InsertarMovimiento]    Script Date: 24/4/2026 14:59:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_InsertarMovimiento]
    @inIdEmpleado INT
    , @inIdTipoMovimiento INT
    , @inMonto DECIMAL(10,2)
    , @inFecha DATE
    , @inIdUsuario INT
    , @inIpPostIn VARCHAR(50)
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @saldoActual DECIMAL(10,2)
        , @nuevoSaldo DECIMAL(10,2)
        , @tipoAccion VARCHAR(10);

    BEGIN TRY
        -- Obtener saldo actual y tipo de acción
        SELECT
            @saldoActual = SaldoVacaciones
        FROM dbo.Empleado
        WHERE Id = @inIdEmpleado;

        SELECT
            @tipoAccion = TipoAccion
        FROM dbo.TipoMovimiento
        WHERE Id = @inIdTipoMovimiento;

        -- Calcular nuevo saldo según el tipo de acción
        IF @tipoAccion = 'Credito'
            SET @nuevoSaldo = @saldoActual + @inMonto;
        ELSE
            SET @nuevoSaldo = @saldoActual - @inMonto;

        -- Validar que el saldo no resulte negativo
        IF @nuevoSaldo < 0
        BEGIN
            SET @outResultCode = 50011;
            RETURN;
        END

        BEGIN TRANSACTION
            -- Registrar el movimiento
            INSERT INTO dbo.Movimiento (
                IdEmpleado
                , IdTipoMovimiento
                , Fecha
                , Monto
                , NuevoSaldo
                , IdUsuario
                , IpPostIn
            )
            VALUES (
                @inIdEmpleado
                , @inIdTipoMovimiento
                , @inFecha
                , @inMonto
                , @nuevoSaldo
                , @inIdUsuario
                , @inIpPostIn
            );

            -- Actualizar el saldo en la tabla Empleado
            UPDATE dbo.Empleado
            SET SaldoVacaciones = @nuevoSaldo
            WHERE Id = @inIdEmpleado;

            -- Registrar en bitácora
            INSERT INTO dbo.BitacoraEvento (
                idTipoEvento
                , Descripcion
                , IdUsuario
                , IpPostIn
            )
            VALUES (
                4
                , 'Movimiento insertado correctamente'
                , @inIdUsuario
                , @inIpPostIn
            );

        COMMIT TRANSACTION

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @outResultCode = 50008;

        INSERT INTO dbo.DBError (
            UserName
            , Number
            , State
            , Severity
            , Line
            , [Procedure]
            , Message
        )
        VALUES (
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ERROR_PROCEDURE()
            , ERROR_MESSAGE()
        );
    END CATCH
END;
