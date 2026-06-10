-- Creacion de la base de datos
DROP DATABASE IF EXISTS db_gestion_incidencias
go
create database db_gestion_incidencias
go
USE db_gestion_incidencias
go

-- 1. Creación de la tabla Ciudadano
CREATE TABLE Ciudadano (
    codCiudadano bigint NOT NULL IDENTITY(1,1),
    dni char(8) NOT NULL UNIQUE,
    nombre varchar(50) NOT NULL,
    apellido varchar(50) NOT NULL,
    telefono varchar(15),
    email varchar(50),
    PRIMARY KEY (codCiudadano)
)

-- 2. Creación de la tabla Departamento
CREATE TABLE Departamento (
  codDepartamento int NOT NULL IDENTITY(1,1),
  nombreDepartamento varchar(100) NOT NULL,
  descripcionDpto varchar(100) NOT NULL,
  estado varchar(10) NOT NULL,
  PRIMARY KEY (codDepartamento)
)

-- 3. Creación de la tabla Empleado
CREATE TABLE Empleado(
  codEmpleado bigint NOT NULL IDENTITY(1,1),
  nombre varchar(50) DEFAULT NULL,
  apellido varchar(50) DEFAULT NULL,
  email varchar(50) DEFAULT NULL,
  fechaNac date DEFAULT NULL,
  direccion varchar(50) DEFAULT NULL,
  tipoEmp varchar(50) DEFAULT NULL,
  codDepartamento int NOT NULL,
  PRIMARY KEY (codEmpleado),
  CONSTRAINT FK_Empleado_Departamento FOREIGN KEY (codDepartamento) REFERENCES Departamento (codDepartamento)
)

-- 4. Creación de la tabla Incidencia 
CREATE TABLE Incidencia(
  codIncidencia bigint NOT NULL IDENTITY(1,1),
  descripcion varchar(250) NOT NULL,
  fechaRegistro datetime2 NOT NULL DEFAULT GETDATE(),
  nivelPrioridad varchar(10) NOT NULL, -- 'Bajo', 'Medio', 'Alto'
  categoria varchar(25) NOT NULL,    -- 'Seguridad Ciudadana', 'Servicios Publicos'
  estado varchar(20) NOT NULL DEFAULT 'Pendiente', -- 'Pendiente', 'En proceso', 'Solucionado', 'Cerrado'
  codCiudadano bigint NOT NULL,      -- Nueva FK
  codEmpleado bigint NULL,           -- Puede ser NULL hasta que Mesa de Servicios lo asigne
  PRIMARY KEY (codIncidencia),
  CONSTRAINT FK_Incidencia_Ciudadano FOREIGN KEY (codCiudadano) REFERENCES Ciudadano (codCiudadano),
  CONSTRAINT FK_Incidencia_Empleado FOREIGN KEY (codEmpleado) REFERENCES Empleado (codEmpleado)
)

-- 5. Creación de la tabla Atencion
CREATE TABLE Atencion(
  codAtencion bigint NOT NULL IDENTITY(1,1),
  acciones varchar(250) NOT NULL,
  fechaAtencion datetime2 NOT NULL,
  presupuesto float NOT NULL,
  detallePresupuesto varchar(255) NOT NULL,
  observaciones varchar(250) NOT NULL,
  codEmpleado bigint NOT NULL,
  codIncidencia bigint NOT NULL,
  PRIMARY KEY (codAtencion),
  CONSTRAINT FK_Atencion_Empleado FOREIGN KEY (codEmpleado) REFERENCES Empleado (codEmpleado),
  CONSTRAINT FK_Atencion_Incidencia FOREIGN KEY (codIncidencia) REFERENCES Incidencia (codIncidencia)
)
go

-- OTRAS RESTRICCIONES
ALTER TABLE Incidencia
ADD CONSTRAINT CK_Prioridad
CHECK (nivelPrioridad IN ('Bajo','Medio','Alto'));
go

ALTER TABLE Incidencia
ADD CONSTRAINT CK_Categoria
CHECK (categoria IN ('Seguridad Ciudadana','Servicios P�blicos'));
go

ALTER TABLE Incidencia
ADD CONSTRAINT CK_Estado
CHECK (estado IN ('Pendiente','En proceso','Solucionado','Cerrado'));
go

-- INSERT
INSERT INTO Ciudadano (dni, nombre, apellido, telefono, email) VALUES 
('12345678', 'Juan', 'P�rez', '999888777', 'juan@email.com'),
('87654321', 'Mar�a', 'L�pez', '988777666', 'maria@email.com')

INSERT INTO Departamento (nombreDepartamento, descripcionDpto, estado) VALUES 
('Servicios P�blicos', 'Limpieza y alumbrado', 'Activo'),
('Seguridad', 'Serenazgo y vigilancia', 'Activo')

INSERT INTO Empleado (nombre, apellido, email, codDepartamento) VALUES 
('Carlos', 'Ruiz', 'carlos@municasma.pe', 1),
('Ana', 'Torres', 'ana@municasma.pe', 2)

INSERT INTO Incidencia (descripcion, nivelPrioridad, categoria, codCiudadano) VALUES 
('Poste de luz sin foco en Plaza de Armas', 'Alto', 'Servicios P�blicos', 1),
('Actividad sospechosa en parque central', 'Medio', 'Seguridad Ciudadana', 2)
go

-- VISTAS TABLAS
select * from Incidencia
select * from Empleado
select * from Ciudadano
select * from Departamento
select * from Atencion
