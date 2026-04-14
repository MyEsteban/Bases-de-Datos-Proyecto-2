-- =============================================
-- PROYECTO: CONTROL DE VACACIONES
-- CREACIÓN DE TABLAS
-- =============================================

-- 1. TABLA USUARIO (Se crea primero para poder ser referenciada)
CREATE TABLE dbo.Usuario (
    Id INT PRIMARY KEY IDENTITY(1,1)
    , Username VARCHAR(50) NOT NULL
    , Password VARCHAR(50) NOT NULL
);

-- 2. TABLA PUESTO
CREATE TABLE dbo.Puesto (
    Id INT PRIMARY KEY
    , Nombre VARCHAR(100) NOT NULL
    , SalarioxHora MONEY NOT NULL
);

-- 3. TABLA EMPLEADO
CREATE TABLE dbo.Empleado (
    Id INT PRIMARY KEY IDENTITY(1,1)
    , IdPuesto INT NOT NULL
    , ValorDocumentoIdentidad VARCHAR(20) NOT NULL
    , Nombre VARCHAR(100) NOT NULL
    , FechaContratacion DATE NOT NULL
    , SaldoVacaciones DECIMAL(10,2) DEFAULT 0
    , EsActivo BIT DEFAULT 1
    , CONSTRAINT FK_Empleado_Puesto FOREIGN KEY (IdPuesto) 
        REFERENCES dbo.Puesto(Id)
);

-- 4. TABLA TIPO MOVIMIENTO
CREATE TABLE dbo.TipoMovimiento (
    Id INT PRIMARY KEY
    , Nombre VARCHAR(100) NOT NULL
    , TipoAccion VARCHAR(10) NOT NULL -- 'Credito' o 'Debito'
);

-- 5. TABLA MOVIMIENTO (Con FK a Usuario)
CREATE TABLE dbo.Movimiento (
    Id INT PRIMARY KEY IDENTITY(1,1)
    , IdEmpleado INT NOT NULL
    , IdTipoMovimiento INT NOT NULL
    , Fecha DATE NOT NULL
    , Monto DECIMAL(10,2) NOT NULL
    , NuevoSaldo DECIMAL(10,2) NOT NULL
    , IdUsuario INT NOT NULL -- Se define NOT NULL para la integridad
    , IpPostIn VARCHAR(50)
    , PostTime DATETIME DEFAULT GETDATE()
    , CONSTRAINT FK_Mov_Empleado FOREIGN KEY (IdEmpleado) 
        REFERENCES dbo.Empleado(Id)
    , CONSTRAINT FK_Mov_TipoMovimiento FOREIGN KEY (IdTipoMovimiento) 
        REFERENCES dbo.TipoMovimiento(Id)
    , CONSTRAINT FK_Movimiento_Usuario FOREIGN KEY (IdUsuario) 
        REFERENCES dbo.Usuario(Id) -- Línea agregada para integridad referencial
);

-- 6. TABLA TIPO EVENTO
CREATE TABLE dbo.TipoEvento (
    Id INT PRIMARY KEY
    , Nombre VARCHAR(100) NOT NULL
);

-- 7. TABLA BITACORA EVENTO
CREATE TABLE dbo.BitacoraEvento (
    Id INT PRIMARY KEY IDENTITY(1,1)
    , idTipoEvento INT NOT NULL
    , Descripcion VARCHAR(MAX)
    , IdUsuario INT
    , IpPostIn VARCHAR(50)
    , PostTime DATETIME DEFAULT GETDATE()
    , CONSTRAINT FK_Bitacora_TipoEvento FOREIGN KEY (idTipoEvento) 
        REFERENCES dbo.TipoEvento(Id)
    , CONSTRAINT FK_BitacoraEvento_Usuario FOREIGN KEY (IdUsuario) 
        REFERENCES dbo.Usuario(Id) -- Línea agregada para integridad referencial
);

-- 8. TABLA DBERROR
CREATE TABLE dbo.DBError (
    Id INT PRIMARY KEY IDENTITY(1,1)
    , UserName VARCHAR(50)
    , Number INT
    , State INT
    , Severity INT
    , Line INT
    , [Procedure] VARCHAR(200)
    , Message VARCHAR(MAX)
    , DateTime DATETIME DEFAULT GETDATE()
);

-- 9. TABLA ERROR
CREATE TABLE dbo.Error (
    Id INT PRIMARY KEY IDENTITY(1,1)
    , Codigo INT NOT NULL
    , Descripcion VARCHAR(MAX) NOT NULL
);
