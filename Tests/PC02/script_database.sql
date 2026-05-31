------------------------------------------
-- ACTIVIDAD 1: CREACION DE BASE DE DATOS
------------------------------------------

IF DB_ID('ClinicaSQL') IS NOT NULL 
BEGIN 
	DROP DATABASE ClinicaSQL; 
END; 
GO

CREATE DATABASE ClinicaSQL; 
GO

USE ClinicaSQL; 
GO

-----------------------------------
-- ACTIVIDAD 2: CREACION DE TABLAS
-----------------------------------

CREATE TABLE Paciente 
( 
    IdPaciente INT IDENTITY(1,1) PRIMARY KEY, 
    DNI CHAR(8) NOT NULL UNIQUE, 
    Nombres VARCHAR(100) NOT NULL, 
    Apellidos VARCHAR(100) NOT NULL, 
    FechaNacimiento DATE NOT NULL, 
    Sexo CHAR(1) NOT NULL CHECK (Sexo IN ('M','F')), 
    Telefono VARCHAR(15) NULL, 
    Correo VARCHAR(100) NULL, 
    Direccion VARCHAR(200) NULL, 
    Estado BIT NOT NULL DEFAULT 1, 
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE() 
); 
GO 
 
CREATE TABLE Medico 
( 
    IdMedico INT IDENTITY(1,1) PRIMARY KEY, 
    CMP VARCHAR(15) NOT NULL UNIQUE, 
    Nombres VARCHAR(100) NOT NULL, 
    Apellidos VARCHAR(100) NOT NULL, 
    Telefono VARCHAR(15) NULL, 
    Correo VARCHAR(100) NULL, 
    Estado BIT NOT NULL DEFAULT 1, 
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE() 
); 
GO 
 
CREATE TABLE Especialidad 
( 
    IdEspecialidad INT IDENTITY(1,1) PRIMARY KEY, 
    NombreEspecialidad VARCHAR(100) NOT NULL UNIQUE, 
    Estado BIT NOT NULL DEFAULT 1 
); 
GO 
CREATE TABLE MedicoEspecialidad 
( 
    IdMedicoEspecialidad INT IDENTITY(1,1) PRIMARY KEY, 
    IdMedico INT NOT NULL, 
    IdEspecialidad INT NOT NULL, 
    FechaAsignacion DATETIME NOT NULL DEFAULT GETDATE(), 
    CONSTRAINT FK_MedicoEspecialidad_Medico 
        FOREIGN KEY (IdMedico) REFERENCES Medico(IdMedico), 
    CONSTRAINT FK_MedicoEspecialidad_Especialidad 
        FOREIGN KEY (IdEspecialidad) REFERENCES Especialidad(IdEspecialidad), 
    CONSTRAINT UQ_MedicoEspecialidad UNIQUE (IdMedico, IdEspecialidad) 
); 
GO 
 
CREATE TABLE CitaMedica 
( 
    IdCita INT IDENTITY(1,1) PRIMARY KEY, 
    IdPaciente INT NOT NULL, 
    IdMedico INT NOT NULL, 
    FechaCita DATE NOT NULL, 
    HoraCita TIME NOT NULL, 
    MotivoConsulta VARCHAR(250) NOT NULL, 
    EstadoCita VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA' 
        CHECK (EstadoCita IN ('PROGRAMADA','ATENDIDA','CANCELADA')), 
    CostoConsulta DECIMAL(10,2) NOT NULL CHECK (CostoConsulta >= 0), 
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(), 
    CONSTRAINT FK_CitaMedica_Paciente FOREIGN KEY (IdPaciente) REFERENCES Paciente(IdPaciente), 
    CONSTRAINT FK_CitaMedica_Medico FOREIGN KEY (IdMedico) REFERENCES Medico(IdMedico) 
); 
GO 
CREATE TABLE Atencion 
( 
    IdAtencion INT IDENTITY(1,1) PRIMARY KEY, 
    IdCita INT NOT NULL UNIQUE, 
    Diagnostico VARCHAR(300) NOT NULL, 
    Observaciones VARCHAR(500) NULL, 
    Peso DECIMAL(5,2) NULL, 
    Talla DECIMAL(5,2) NULL, 
    PresionArterial VARCHAR(20) NULL, 
    FechaAtencion DATETIME NOT NULL DEFAULT GETDATE(), 
    CONSTRAINT FK_Atencion_Cita FOREIGN KEY (IdCita) REFERENCES CitaMedica(IdCita) 
); 
GO 
 
CREATE TABLE Receta 
( 
    IdReceta INT IDENTITY(1,1) PRIMARY KEY, 
    IdAtencion INT NOT NULL, 
    Medicamento VARCHAR(150) NOT NULL, 
    Dosis VARCHAR(100) NOT NULL, 
    Frecuencia VARCHAR(100) NOT NULL, 
    DuracionDias INT NOT NULL CHECK (DuracionDias > 0), 
    Indicaciones VARCHAR(300) NULL, 
    CONSTRAINT FK_Receta_Atencion FOREIGN KEY (IdAtencion) REFERENCES Atencion(IdAtencion) 
); 
GO 
 
CREATE TABLE Pago 
( 
    IdPago INT IDENTITY(1,1) PRIMARY KEY, 
    IdCita INT NOT NULL, 
    Monto DECIMAL(10,2) NOT NULL CHECK (Monto >= 0), 
    MetodoPago VARCHAR(30) NOT NULL 
        CHECK (MetodoPago IN ('EFECTIVO','TARJETA','YAPE','PLIN','TRANSFERENCIA')), 
    EstadoPago VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' 
        CHECK (EstadoPago IN ('PENDIENTE','PAGADO','ANULADO')), 
    FechaPago DATETIME NULL, 
    CONSTRAINT FK_Pago_Cita FOREIGN KEY (IdCita) REFERENCES CitaMedica(IdCita) 
); 
GO

-----------------------------------------
-- ACTIVIDAD 3: CARGA DE DATOS DE PRUEBA
-----------------------------------------

INSERT INTO Especialidad (NombreEspecialidad) VALUES ('Medicina General'),('Cardiología'),('Pediatría'),('Dermatología'),('Traumatología'); 

INSERT INTO Medico (CMP, Nombres, Apellidos, Telefono, Correo) 
VALUES 
('CMP1001', 'Carlos', 'Ramírez Soto', '987111111', 'carlos.ramirez@clinica.com'), 
('CMP1002', 'Ana', 'Torres León', '987222222', 'ana.torres@clinica.com'), 
('CMP1003', 'Luis', 'Paredes Gómez', '987333333', 'luis.paredes@clinica.com'), 
('CMP1004', 'María', 'Salazar Pérez', '987444444', 'maria.salazar@clinica.com'); 
 
INSERT INTO Paciente (DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Correo, Direccion) 
VALUES 
('74125836', 'José', 'Mendoza Ruiz', '1990-05-12', 'M', '999111111', 'jose@gmail.com', 'Lima'), 
('85236974', 'Lucía', 'Fernández Díaz', '1988-10-21', 'F', '999222222', 'lucia@gmail.com', 
'Callao'), 
('96374125', 'Pedro', 'Castillo Rojas', '2001-02-17', 'M', '999333333', 'pedro@gmail.com', 'Surco'), 
('15975348', 'Rosa', 'Gutiérrez Flores', '1995-08-09', 'F', '999444444', 'rosa@gmail.com', 
'Miraflores'), 
('25845697', 'Miguel', 'Vargas Peña', '1979-03-30', 'M', '999555555', 'miguel@gmail.com', 'San 
Borja'); 
INSERT INTO MedicoEspecialidad (IdMedico, IdEspecialidad) 
VALUES (1,1),(2,2),(3,3),(4,4),(1,5); 
 
INSERT INTO CitaMedica (IdPaciente, IdMedico, FechaCita, HoraCita, MotivoConsulta, EstadoCita, 
CostoConsulta) 
VALUES 
(1,1,'2026-04-01','09:00','Dolor de cabeza','ATENDIDA',80.00), 
(2,2,'2026-04-01','10:00','Dolor en el pecho','ATENDIDA',150.00), 
(3,3,'2026-04-02','11:30','Control pediátrico','PROGRAMADA',90.00), 
(4,4,'2026-04-03','15:00','Alergia en la piel','ATENDIDA',120.00), 
(5,1,'2026-04-03','16:00','Dolor de rodilla','CANCELADA',100.00), 
(1,2,'2026-04-05','08:30','Palpitaciones','PROGRAMADA',150.00), 
(2,1,'2026-04-05','09:15','Chequeo general','PROGRAMADA',80.00); 
 
INSERT INTO Atencion (IdCita, Diagnostico, Observaciones, Peso, Talla, PresionArterial) 
VALUES 
(1,'Cefalea tensional','Paciente estable',70.5,1.72,'120/80'), 
(2,'Posible arritmia','Solicitar electrocardiograma',68.0,1.65,'130/85'), 
(4,'Dermatitis alérgica','Evitar contacto con sustancia irritante',59.5,1.60,'110/70'); 
INSERT INTO Receta (IdAtencion, Medicamento, Dosis, Frecuencia, DuracionDias, Indicaciones) 
VALUES 
(1,'Paracetamol 500mg','1 tableta','Cada 8 horas',3,'Tomar después de alimentos'), 
(2,'Aspirina 100mg','1 tableta','Cada 24 horas',30,'No suspender sin indicación médica'), 
(3,'Cetirizina 10mg','1 tableta','Cada 24 horas',5,'Tomar por la noche'); 
 
INSERT INTO Pago (IdCita, Monto, MetodoPago, EstadoPago, FechaPago) 
VALUES 
(1,80.00,'EFECTIVO','PAGADO',GETDATE()), 
(2,150.00,'TARJETA','PAGADO',GETDATE()), 
(3,0.00,'EFECTIVO','PENDIENTE',NULL), 
(4,120.00,'YAPE','PAGADO',GETDATE()), 
(5,0.00,'EFECTIVO','ANULADO',NULL), 
(6,0.00,'PLIN','PENDIENTE',NULL), 
(7,0.00,'TRANSFERENCIA','PENDIENTE',NULL); 
GO
