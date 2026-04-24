ALTER TABLE dbo.Empleado
ADD CONSTRAINT UQ_Empleado_Documento UNIQUE (ValorDocumentoIdentidad);

ALTER TABLE dbo.Empleado
ADD CONSTRAINT UQ_Empleado_Nombre UNIQUE (Nombre);

ALTER TABLE dbo.Error
ADD CONSTRAINT UQ_Error_Codigo UNIQUE (Codigo);

ALTER TABLE dbo.Empleado
ADD IdPostByUser INT NULL,
    PostInIP VARCHAR(50) NULL,
    PostTime DATETIME DEFAULT GETDATE();

EXEC sp_rename 'dbo.Movimiento.IdUsuario', 'IdPostByUser', 'COLUMN';

EXEC sp_rename 'dbo.Movimiento.IpPostIn', 'PostInIP', 'COLUMN';

EXEC sp_rename 'dbo.BitacoraEvento.IdUsuario', 'IdPostByUser', 'COLUMN';

EXEC sp_rename 'dbo.BitacoraEvento.IpPostIn', 'PostInIP', 'COLUMN';