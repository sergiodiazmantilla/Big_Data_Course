use ClinicaSQL
go

----------------------------------------------------
-- ACTIVIDAD 4: CONSULTAS EN Transact SQL
-----------------------------------------------------

-- Ejercicio 1. Listar citas con paciente y médico 
SELECT  
    c.IdCita, 
    p.Nombres + ' ' + p.Apellidos AS Paciente, 
    m.Nombres + ' ' + m.Apellidos AS Medico, 
    c.FechaCita, 
    c.HoraCita, 
    c.MotivoConsulta, 
    c.EstadoCita 
FROM CitaMedica c 
INNER JOIN Paciente p ON c.IdPaciente = p.IdPaciente 
INNER JOIN Medico m ON c.IdMedico = m.IdMedico 
ORDER BY c.FechaCita, c.HoraCita; 

-- Ejercicio 2. Contar citas por médico 
SELECT  
    m.Nombres + ' ' + m.Apellidos AS Medico, 
    COUNT(c.IdCita) AS TotalCitas 
FROM Medico m 
LEFT JOIN CitaMedica c ON m.IdMedico = c.IdMedico 
GROUP BY m.Nombres, m.Apellidos; 

--Ejercicio 3. Mostrar médicos con su especialidad 
SELECT  
    m.Nombres + ' ' + m.Apellidos AS Medico, 
    e.NombreEspecialidad 
FROM MedicoEspecialidad me 
INNER JOIN Medico m ON me.IdMedico = m.IdMedico 
INNER JOIN Especialidad e ON me.IdEspecialidad = e.IdEspecialidad;
go

-----------------------------------------------
-- ACTIVIDAD 5: ESTRUCTURA DE CONTROL DE FLUJO
-----------------------------------------------

-- Ejercicio 4. Uso de IF...ELSE 
DECLARE @IdCita INT = 1; 
DECLARE @EstadoPago VARCHAR(20); 
 
SELECT @EstadoPago = EstadoPago 
FROM Pago 
WHERE IdCita = @IdCita; 
 
IF @EstadoPago = 'PAGADO' 
    PRINT 'La cita ya fue cancelada.'; 
ELSE 
    PRINT 'La cita aún tiene deuda pendiente.'; 

-- Ejercicio 5. Uso de CASE 
SELECT 
    IdCita, 
    EstadoCita, 
    CASE 
        WHEN EstadoCita = 'PROGRAMADA' THEN 'Pendiente de atención' 
        WHEN EstadoCita = 'ATENDIDA' THEN 'Atención finalizada' 
        WHEN EstadoCita = 'CANCELADA' THEN 'Cita anulada' 
        ELSE 'Estado desconocido' 
    END AS Descripcion 
FROM CitaMedica; 

-- Ejercicio 6. Uso de WHILE 
DECLARE @Contador INT = 1; 
 
WHILE @Contador <= 5 
BEGIN 
    PRINT 'Procesando registro número: ' + CAST(@Contador AS VARCHAR(10)); 
    SET @Contador = @Contador + 1; 
END 
go

---------------------------------------------------
-- ACTIVIDAD 6: MANEJO DE ERRORES CON TRY... CATCH
---------------------------------------------------

BEGIN TRY 
    INSERT INTO CitaMedica 
    ( 
        IdPaciente, IdMedico, FechaCita, HoraCita, 
        MotivoConsulta, EstadoCita, CostoConsulta 
    ) 
    VALUES 
    (99, 1, '2026-04-10', '10:00', 'Consulta de prueba', 'PROGRAMADA', 100); 
 
    PRINT 'Cita registrada correctamente.'; 
END TRY 
BEGIN CATCH 
    PRINT 'Se produjo un error al registrar la cita.'; 
    PRINT ERROR_MESSAGE(); 
END CATCH 
go

-------------------------------------------
-- ACTIVIDAD 7: PROCEDIMIENTOS ALMACENADOS
-------------------------------------------

-- Ejercicio 7. Registrar pacientes 
CREATE PROCEDURE sp_RegistrarPaciente 
    @DNI CHAR(8), 
    @Nombres VARCHAR(100), 
    @Apellidos VARCHAR(100), 
    @FechaNacimiento DATE, 
    @Sexo CHAR(1), 
    @Telefono VARCHAR(15), 
    @Correo VARCHAR(100), 
    @Direccion VARCHAR(200) 
AS 
BEGIN 
    INSERT INTO Paciente 
    ( 
        DNI, Nombres, Apellidos, FechaNacimiento, 
        Sexo, Telefono, Correo, Direccion 
    ) 
    VALUES 
    ( 
        @DNI, @Nombres, @Apellidos, @FechaNacimiento, 
        @Sexo, @Telefono, @Correo, @Direccion 
    ); 
END; 
GO

EXEC sp_RegistrarPaciente 
    '45678912', 
    'Elena',
    'Ríos Torres', 
    '1992-11-15', 
    'F', 
    '999888777', 
    'elena@gmail.com', 
    'San Miguel'; 
go

select * from Paciente
go

--Ejercicio 8. Listar citas por médico 
CREATE PROCEDURE sp_ListarCitasPorMedico 
    @IdMedico INT 
AS 
BEGIN 
    SELECT 
        c.IdCita, 
        p.Nombres + ' ' + p.Apellidos AS Paciente, 
        c.FechaCita, 
        c.HoraCita, 
        c.MotivoConsulta, 
        c.EstadoCita 
    FROM CitaMedica c 
    INNER JOIN Paciente p ON c.IdPaciente = p.IdPaciente 
    WHERE c.IdMedico = @IdMedico; 
END; 
GO 
 
EXEC sp_ListarCitasPorMedico 1; 
go
-----------------------------------
-- ACTIVIDAD 8: FUNCIONES
-----------------------------------

-- Ejercicio 9. Calcular edad del paciente 
CREATE FUNCTION fn_CalcularEdad (@FechaNacimiento DATE) 
RETURNS INT 
AS 
BEGIN 
    DECLARE @Edad INT; 
    SET @Edad = DATEDIFF(YEAR, @FechaNacimiento, GETDATE()); 
 
    IF DATEADD(YEAR, @Edad, @FechaNacimiento) > GETDATE() 
        SET @Edad = @Edad - 1; 
 
    RETURN @Edad; 
END; 
GO 
 
SELECT IdPaciente, Nombres, Apellidos, 
		dbo.fn_CalcularEdad(FechaNacimiento) AS Edad 
FROM Paciente;
go

-- Ejercicio 10. Contar citas por paciente 
CREATE FUNCTION fn_CantidadCitasPaciente (@IdPaciente INT) 
RETURNS INT 
AS 
BEGIN 
    DECLARE @Cantidad INT; 
 
    SELECT @Cantidad = COUNT(*) 
    FROM CitaMedica  
    WHERE IdPaciente = @IdPaciente; 
 
    RETURN @Cantidad; 
END; 
GO 
 
SELECT IdPaciente, Nombres, Apellidos, 
       dbo.fn_CantidadCitasPaciente(IdPaciente) AS TotalCitas 
FROM Paciente;
go

-----------------------------------
-- ACTIVIDAD 9: TRIGGERS
-----------------------------------

CREATE TRIGGER trg_EvitarEliminarMedicoConCitas 
ON Medico 
INSTEAD OF DELETE 
AS 
BEGIN 
    IF EXISTS ( 
        SELECT 1 
        FROM CitaMedica c 
        INNER JOIN deleted d ON c.IdMedico = d.IdMedico 
    ) 
        RAISERROR('No se puede eliminar un médico con citas registradas.', 16, 1); 
    ELSE 
        DELETE FROM Medico 
        WHERE IdMedico IN (SELECT IdMedico FROM deleted); 
END; 
GO 
 
DELETE FROM Medico 
WHERE IdMedico = 1;
go

-----------------------------------
-- ACTIVIDAD 10: TRANSACCIONES
-----------------------------------

BEGIN TRY 
    BEGIN TRANSACTION; 
 
    INSERT INTO CitaMedica 
    ( 
        IdPaciente, IdMedico, FechaCita, HoraCita, 
        MotivoConsulta, EstadoCita, CostoConsulta 
    ) 
    VALUES 
    (3, 2, '2026-04-15', '10:30', 'Consulta cardiológica', 'PROGRAMADA', 150.00); 
 
    DECLARE @NuevaCita INT = SCOPE_IDENTITY(); 
 
    INSERT INTO Pago 
    ( 
        IdCita, Monto, MetodoPago, EstadoPago, FechaPago 
    ) 
    VALUES 
    (@NuevaCita, 150.00, 'TARJETA', 'PAGADO', GETDATE()); 
 
    COMMIT TRANSACTION; 
    PRINT 'Transacción completada correctamente.'; 
END TRY 
BEGIN CATCH 
	ROLLBACK TRANSACTION; 
	PRINT 'La transacción fue revertida.'; 
	PRINT ERROR_MESSAGE(); 
END CATCH 
go

select * from CitaMedica
go
-----------------------------------------------------------
-- ACTIVIDAD 11: COMBINACIÓN DE FUNCIONES Y PROCEDIMIENTOS
-----------------------------------------------------------

CREATE PROCEDURE sp_ListarPacientesConEdad 
AS 
BEGIN 
	SELECT 
		IdPaciente, 
		DNI, 
		Nombres, 
		Apellidos, 
		FechaNacimiento, 
		dbo.fn_CalcularEdad(FechaNacimiento) AS Edad 
	FROM Paciente; 
END; 
GO 
EXEC sp_ListarPacientesConEdad;
go
