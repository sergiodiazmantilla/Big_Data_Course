use Northwind
go 

-------------------------------------
-- VER TABLAS
-------------------------------------

select name
from sys.tables
-------------------------------

select t.name
from sys.tables t
-------------------------------

select s.name Esquema, t.name Tabla
from sys.tables t
inner join sys.schemas s
	on t.schema_id=s.schema_id
order by s.name, t.name
------------------------------------

select TABLE_NAME
from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'base table'

----------------------------------------
-- VER TIPO DE DATO
----------------------------------------

exec sp_help 'orders'
-----------------------------------------

select
	COLUMN_NAME as Columna,
	DATA_TYPE as TipoDato,
	CHARACTER_MAXIMUM_LENGTH as Longitud,
	IS_NULLABLE as Permiteulos
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='orders'
-----------------------------------------

select * from dbo.Customers

/*Para la empresa X, se desea crear un SP con t=sql que cada vezz que 
cliente, este debe de guardarse en una tabla de auditoria*/

-- tabla para registrar la autoria
create table Auditoria_Cliente(
	Auditoria_ID int identity (1, 1) primary key,
	CustomerID nchar(5),
	CompanyName nvarchar(40),
	ContactName nvarchar(30),
	ContactTitle nvarchar(30),
	Accion nvarchar(100),
	Usuario nvarchar(50),
	FechaRegistro datetime,
	Observacion varchar(500)
)
go

-- procedimiento almacenado
create or alter procedure usp_RegistrarCliente
	@CustomerID nchar(5),	@CompanyName nvarchar(40),	@ContactName nvarchar(30),	@ContactTitle nvarchar(30)
AS
BEGIN
	
	BEGIN TRY
		BEGIN TRANSACTION
		
		INSERT INTO Customers(
			CustomerID,	CompanyName,ContactName,ContactTitle
		)
		values
		(
			@CustomerID,@CompanyName, 	@ContactName,@ContactTitle
		);
		-------
		INSERT INTO Auditoria_Cliente
		(
			CustomerID,	CompanyName,ContactName,ContactTitle,Accion ,Usuario ,	FechaRegistro,	Observacion
		)
		VALUES(
			@CustomerID, @CompanyName, 	 @ContactName, 	@ContactTitle,		'INSERT',			SYSTEM_USER,	GETDATE(),
			'Se insertó correctamente un nuevo cliente en la tabla customer'
		);
 
		COMMIT TRANSACTION;
		print 'Cliente registrado correctamente en la tabla customer y en la tabla auditoria'
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRANSACTION
		print 'Ocurrio un error, la operacion ha sido cancelada'
		print error_message();
	END CATCH
 
END;

-- Ejecucion de SP 
exec usp_RegistrarCliente
	@CustomerID ='CL009',	
	@CompanyName ='Arrocera del NorteArrocera del NorteArrocera del NorteArrocera del Norte',	
	@ContactName ='Artemio Calderon',	
	@ContactTitle ='Saul Mendoza'

go

-- Ver tabla
select * from Auditoria_Cliente

