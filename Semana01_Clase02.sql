use Northwind
go 

-- Reconocer las tablas que contiene
select * from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE='BASE TABLE'

-- Muestra los 10 primeros registros
select top 10 * from Customers

-- Declaracion de variable
declare @CutomerID char(5)
set @CutomerID = 'BLAUS'
-- Condicional
if exists (
	select * from Customers
	where CustomerID = @CutomerID
	)
	begin -- Inicio de un bloque
		-- Imprimir mensaje en consola
		print'El cliente existe en la DB'
	end -- fin de un bloque
else
	begin
		print'El cliente NO existe en la DB'
	end

/*
RQ 2014-2026 - Verificar si un producto tiene stock
Programador: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Fecha de cambio: xxxxxxxxxxxxxxxxxxxxxxxx
Motivo: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*/


declare @productoID int
declare @stock int

set @productoID = 18

select @stock = UnitsInStock
from Products
where ProductID = @productoID

if @stock = 0
	Begin
		print 'El producto NO tiene stock disponible'
	end
else if @stock between 1 and 20
	Begin
		print 'El producto tiene stock bajo'
	end
else 
	Begin
		print 'El producto tiene stock disponible'
	end

-- vista tabla Productos
select * from Products