SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_CargarMovimientosXML
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @xmlData XML = '
    <Datos>
        <Movimientos>
            <movimiento ValorDocId="7517662" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-01-18" Monto="2" PostByUser="hardingmicheal" PostInIP="42.142.119.153" PostTime="2024-01-18 18:47:14"/>
            <movimiento ValorDocId="6993943" IdTipoMovimiento="Bono vacacional" Fecha="2024-10-31" Monto="1" PostByUser="mgarrison" PostInIP="156.92.82.57" PostTime="2024-10-31 12:43:18"/>
            <movimiento ValorDocId="8326328" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-11-22" Monto="7" PostByUser="andersondeborah" PostInIP="218.213.110.232" PostTime="2024-11-22 00:23:53"/>
            <movimiento ValorDocId="4510358" IdTipoMovimiento="Reversion de Credito" Fecha="2024-07-03" Monto="3" PostByUser="hardingmicheal" PostInIP="143.42.131.166" PostTime="2024-07-03 17:07:39"/>
            <movimiento ValorDocId="8403646" IdTipoMovimiento="Reversion de Credito" Fecha="2024-12-07" Monto="8" PostByUser="zkelly" PostInIP="155.44.100.105" PostTime="2024-12-07 15:44:30"/>
            <movimiento ValorDocId="8326328" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-11-26" Monto="10" PostByUser="hardingmicheal" PostInIP="141.163.255.56" PostTime="2024-11-26 09:33:41"/>
            <movimiento ValorDocId="6993943" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-11-20" Monto="6" PostByUser="hardingmicheal" PostInIP="4.176.52.1" PostTime="2024-11-20 23:31:41"/>
            <movimiento ValorDocId="2918773" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-10-30" Monto="10" PostByUser="zkelly" PostInIP="220.164.108.231" PostTime="2024-10-30 03:55:57"/>
            <movimiento ValorDocId="2161775" IdTipoMovimiento="Reversion Debito" Fecha="2024-06-13" Monto="2" PostByUser="hardingmicheal" PostInIP="135.223.57.22" PostTime="2024-06-13 13:28:39"/>
            <movimiento ValorDocId="8403646" IdTipoMovimiento="Bono vacacional" Fecha="2024-01-01" Monto="6" PostByUser="zkelly" PostInIP="150.250.94.62" PostTime="2024-01-01 05:17:10"/>
            <movimiento ValorDocId="2918773" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-07-12" Monto="6" PostByUser="hardingmicheal" PostInIP="218.191.123.15" PostTime="2024-07-12 09:10:16"/>
            <movimiento ValorDocId="5095109" IdTipoMovimiento="Reversion de Credito" Fecha="2024-12-27" Monto="14" PostByUser="hardingmicheal" PostInIP="136.103.23.170" PostTime="2024-12-27 12:59:03"/>
            <movimiento ValorDocId="6993943" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-04-08" Monto="1" PostByUser="jgonzalez" PostInIP="158.48.100.86" PostTime="2024-04-08 01:24:38"/>
            <movimiento ValorDocId="8403646" IdTipoMovimiento="Bono vacacional" Fecha="2024-08-25" Monto="8" PostByUser="jgonzalez" PostInIP="204.0.219.231" PostTime="2024-08-25 16:24:07"/>
            <movimiento ValorDocId="5095109" IdTipoMovimiento="Bono vacacional" Fecha="2024-03-07" Monto="7" PostByUser="andersondeborah" PostInIP="208.0.4.33" PostTime="2024-03-07 08:19:28"/>
            <movimiento ValorDocId="9772211" IdTipoMovimiento="Cumplir mes" Fecha="2024-02-14" Monto="4" PostByUser="martinezlisa" PostInIP="10.10.10.10" PostTime="2024-02-14 08:11:00"/>
            <movimiento ValorDocId="6641189" IdTipoMovimiento="Bono vacacional" Fecha="2024-02-28" Monto="3" PostByUser="floresdaniel" PostInIP="10.10.10.11" PostTime="2024-02-28 09:20:15"/>
            <movimiento ValorDocId="3389054" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-03-12" Monto="5" PostByUser="perezmaria" PostInIP="10.10.10.12" PostTime="2024-03-12 14:05:45"/>
            <movimiento ValorDocId="9772211" IdTipoMovimiento="Reversion de Credito" Fecha="2024-04-03" Monto="2" PostByUser="torresluis" PostInIP="10.10.10.13" PostTime="2024-04-03 11:30:05"/>
            <movimiento ValorDocId="6641189" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-04-19" Monto="1" PostByUser="mgarrison" PostInIP="172.16.0.21" PostTime="2024-04-19 16:42:31"/>
            <movimiento ValorDocId="3389054" IdTipoMovimiento="Reversion Debito" Fecha="2024-05-02" Monto="3" PostByUser="jgonzalez" PostInIP="172.16.0.22" PostTime="2024-05-02 07:18:09"/>
            <movimiento ValorDocId="5095109" IdTipoMovimiento="Cumplir mes" Fecha="2024-05-18" Monto="6" PostByUser="andersondeborah" PostInIP="172.16.0.23" PostTime="2024-05-18 18:22:40"/>
            <movimiento ValorDocId="4510358" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-06-09" Monto="4" PostByUser="hardingmicheal" PostInIP="172.16.0.24" PostTime="2024-06-09 12:10:55"/>
            <movimiento ValorDocId="6019592" IdTipoMovimiento="Bono vacacional" Fecha="2024-06-25" Monto="2" PostByUser="martinezlisa" PostInIP="172.16.0.25" PostTime="2024-06-25 09:44:03"/>
            <movimiento ValorDocId="7517662" IdTipoMovimiento="Reversion de Credito" Fecha="2024-07-11" Monto="5" PostByUser="floresdaniel" PostInIP="172.16.0.26" PostTime="2024-07-11 13:55:27"/>
            <movimiento ValorDocId="8403646" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-08-08" Monto="4" PostByUser="perezmaria" PostInIP="172.16.0.27" PostTime="2024-08-08 15:00:00"/>
            <movimiento ValorDocId="6993943" IdTipoMovimiento="Cumplir mes" Fecha="2024-09-14" Monto="7" PostByUser="torresluis" PostInIP="172.16.0.28" PostTime="2024-09-14 10:25:18"/>
            <movimiento ValorDocId="2161775" IdTipoMovimiento="Reversion Debito" Fecha="2024-10-05" Monto="1" PostByUser="zkelly" PostInIP="172.16.0.29" PostTime="2024-10-05 08:12:49"/>
            <movimiento ValorDocId="2918773" IdTipoMovimiento="Bono vacacional" Fecha="2024-11-03" Monto="2" PostByUser="martinezlisa" PostInIP="172.16.0.30" PostTime="2024-11-03 17:33:12"/>
            <movimiento ValorDocId="8326328" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-12-18" Monto="8" PostByUser="floresdaniel" PostInIP="172.16.0.31" PostTime="2024-12-18 19:47:59"/>
        </Movimientos>
    </Datos>';

    BEGIN TRY
        BEGIN TRANSACTION
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
            SELECT 
                E.Id
                , TM.Id  -- Obtenemos el ID del tipo de movimiento por su nombre
                , T.Item.value('@Fecha', 'DATE')
                , T.Item.value('@Monto', 'DECIMAL(10,2)')
                , 0      -- Saldo inicial en 0 para la carga
                , U.Id   -- Obtenemos el ID del usuario por su username
                , T.Item.value('@PostInIP', 'VARCHAR(50)')
                , T.Item.value('@PostTime', 'DATETIME')
            FROM @xmlData.nodes('/Datos/Movimientos/movimiento') AS T(Item)
            INNER JOIN dbo.Empleado E ON E.ValorDocumentoIdentidad = T.Item.value('@ValorDocId', 'VARCHAR(20)')
            INNER JOIN dbo.Usuario U ON U.Username = T.Item.value('@PostByUser', 'VARCHAR(50)')
            INNER JOIN dbo.TipoMovimiento TM ON TM.Nombre = T.Item.value('@IdTipoMovimiento', 'VARCHAR(100)');
            
        COMMIT TRANSACTION
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
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
            , 'sp_CargarMovimientosXML'
            , ERROR_MESSAGE()
        );
    END CATCH
END;
