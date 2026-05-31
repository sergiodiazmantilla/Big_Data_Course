use ClinicaSQL
go

-------------------------------------------------------------------
-- ACTIVIDADES PROPUESTAS PARA LOS ESTUDIANTES
-------------------------------------------------------------------

----------------------------------------------------------------
--16.1. Crear un procedimiento almacenado para cancelar una cita
CREATE PROCEDURE sp_CancelarCita
 @IdCita INT
AS
BEGIN
 IF EXISTS (SELECT 1 FROM CitaMedica WHERE IdCita = @IdCita AND EstadoCita = 'PROGRAMADA')
 BEGIN
  UPDATE CitaMedica
  SET EstadoCita = 'CANCELADA'
  WHERE IdCita = @IdCita

  UPDATE Pago
  SET EstadoPago = 'ANULADO'
  WHERE IdCita = @IdCita

  PRINT 'La cita y el pago asociado han sido cancelados.'
 END
 ELSE
 BEGIN
  PRINT 'AVISO: La cita no existe o ya no se puede cancelar (puede estar ATENDIDA o ya CANCELADA).'
 END
END
GO

-- Consulta previa
SELECT * FROM [dbo].[CitaMedica] WHERE IdCita = '6'
SELECT * FROM [dbo].[Pago] WHERE IdCita = '6'

--Ejecucion de SP
EXEC sp_CancelarCita @IdCita = 6
GO

-------------------------------------------------------------------
--16.2. Crear una función que devuelva el total pagado por una cita
CREATE FUNCTION fn_TotalPagadoPorCita (
 @IdCita INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
 DECLARE @Total DECIMAL(10,2);
 SELECT @Total = ISNULL(SUM(Monto), 0)
 FROM Pago
 WHERE IdCita = @IdCita AND EstadoPago = 'PAGADO'
 RETURN @Total
END
GO

-- Consulta
SELECT dbo.fn_TotalPagadoPorCita(1) AS TotalPagado
go

-------------------------------------------------------------------------------------------------------
--16.3. Crear un trigger que registre automáticamente la fecha de pago cuando el estado cambie a PAGADO
CREATE TRIGGER trg_RegistrarFechaPago ON Pago
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF UPDATE(EstadoPago)
 BEGIN
  UPDATE P
  SET P.FechaPago = GETDATE()
  FROM Pago P
  INNER JOIN inserted I ON P.IdPago = I.IdPago
  WHERE I.EstadoPago = 'PAGADO'
  AND P.FechaPago IS NULL
 END
END
GO

------------------------------------------------------------------------------------
--16.4. Crear una transacción que registre una atención y una receta al mismo tiempo
CREATE PROCEDURE sp_RegistrarAtencionYReceta
 @IdCita INT,
 @Diagnostico VARCHAR(300),
 @Observaciones VARCHAR(500),
 @Peso DECIMAL(5,2),
 @Talla DECIMAL(5,2),
 @PresionArterial VARCHAR(20),
 @Medicamento VARCHAR(150),
 @Dosis VARCHAR(100),
 @Frecuencia VARCHAR(100),
 @DuracionDias INT,
 @Indicaciones VARCHAR(300)
AS
BEGIN
 BEGIN TRY
  BEGIN TRANSACTION

  DECLARE @NuevoIdAtencion INT

  INSERT INTO Atencion (IdCita, Diagnostico, Observaciones, Peso, Talla, PresionArterial)
  VALUES (@IdCita, @Diagnostico, @Observaciones, @Peso, @Talla, @PresionArterial)

  SET @NuevoIdAtencion = SCOPE_IDENTITY()

  INSERT INTO Receta (IdAtencion, Medicamento, Dosis, Frecuencia, DuracionDias, Indicaciones)
  VALUES (@NuevoIdAtencion, @Medicamento, @Dosis, @Frecuencia, @DuracionDias, @Indicaciones)

  COMMIT TRANSACTION

  PRINT 'La atención y la receta se registraron correctamente.'

 END TRY
 BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
   ROLLBACK TRANSACTION
  END

  PRINT 'No se guardó ni la atención ni la receta.'
  PRINT 'Mensaje de error del sistema: ' + ERROR_MESSAGE()
 END CATCH
END
GO

-- Ejecucion Transaccion
EXEC sp_RegistrarAtencionYReceta
 @IdCita = 10,
 @Diagnostico = 'Esguince de tobillo',
 @Observaciones = 'Paciente presenta inflamación moderada y hematoma localizado',
 @Peso = 74.0,
 @Talla = 1.72,
 @PresionArterial = '120/80',
 @Medicamento = 'Ibuprofeno 400mg',
 @Dosis = '1 tableta',
 @Frecuencia = 'Cada 8 horas',
 @DuracionDias = 7,
 @Indicaciones = 'Tomar siempre después de los alimentos'
GO

------------------------------------------------------------------------------------------------
--16.5. Crear una consulta que muestre los pacientes, el médico que los atendió y el diagnóstico
SELECT
 (SELECT Nombres + ' ' + Apellidos
  FROM Paciente
  WHERE IdPaciente = C.IdPaciente) AS NombrePaciente,

 (SELECT Nombres + ' ' + Apellidos
  FROM Medico
  WHERE IdMedico = C.IdMedico) AS NombreMedico,

 (SELECT Diagnostico
  FROM Atencion
  WHERE IdCita = C.IdCita) AS Diagnostico,

 C.FechaCita
FROM CitaMedica C
WHERE C.IdCita IN (SELECT IdCita FROM Atencion)
GO
