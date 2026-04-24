-- 1. Revertir nombres en la tabla Movimiento
EXEC sp_rename 'dbo.Movimiento.IdPostByUser', 'IdUsuario', 'COLUMN';
EXEC sp_rename 'dbo.Movimiento.PostInIP', 'IpPostIn', 'COLUMN';

-- 2. Revertir nombres en la tabla BitacoraEvento
EXEC sp_rename 'dbo.BitacoraEvento.IdPostByUser', 'IdUsuario', 'COLUMN';
EXEC sp_rename 'dbo.BitacoraEvento.PostInIP', 'IpPostIn', 'COLUMN';

-- 3. Ajustar la tabla Empleado (reemplazar los que agregó esteban por los correctos)
ALTER TABLE dbo.Empleado DROP COLUMN IdPostByUser;
ALTER TABLE dbo.Empleado DROP COLUMN PostInIP;

ALTER TABLE dbo.Empleado 
ADD IdUsuario INT NULL
    , IpPostIn VARCHAR(50) NULL;
