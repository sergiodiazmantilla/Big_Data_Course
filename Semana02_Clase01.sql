USE [Northwind]
GO

-- Clasificacion de productos segun Stock
/*
	condicion				clasificación
	Stock igual a 0			Sin Stock
	Stock entre 1 y 10		Stock Bajo
	Stock entre 11 y 25		Stock Medio
	Stock entre 26 y 60		Stock Normal
	Stock entre 61 y 70		Stock Alto
	Mayor a 71				Stock Muy alto

*/
SELECT 
	[ProductID] AS CodigoProducto,
	[ProductName] as [Nombre Producto],
	[UnitsInStock] as Unidades,
	CASE
		when [UnitsInStock]=0 then 'Sin Stock'
		when [UnitsInStock] BETWEEN 1 AND 10 then 'Stock Bajo'
		when [UnitsInStock] BETWEEN 11 AND 25 then 'Stock Medio'
		when [UnitsInStock] BETWEEN 26 AND 60 then 'Stock Normal'
		when [UnitsInStock] BETWEEN 61 AND 70 then 'Stock Alto'
		ELSE 'Stock muy Alto'
	END AS [Clasificacion]
FROM [dbo].[Products]
ORDER BY [UnitsInStock]

-- Mostrar los productos menores a un stock determinado
declare @NivelStock int;
set @NivelStock=0
while @NivelStock<=80
begin
	print '==================================';
	print 'PRODUCTOS CON STOCK MAYOR O IGUAL A : '+CAST(@NivelStock AS varchar(20));
	print '==================================';
	SELECT 
		[ProductID] AS CodigoProducto,
		[ProductName] as [Nombre Producto],
		[UnitsInStock] as Unidades
	FROM [dbo].[Products]
	WHERE [UnitsInStock]>=@NivelStock
	ORDER BY [UnitsInStock] ASC
 
	set @NivelStock=@NivelStock+20;
end

-- Actualizar el stock de los productos con stock determinado
GO
DECLARE @stockminimo int;
DECLARE @incremento int;
declare @corrida int;
 
set @stockminimo=100;
set @incremento=20;
set @corrida=1;
select * from Products
while exists ( 
				select 1 
				from [dbo].[Products] 
				where [UnitsInStock]<@stockminimo 
				)
begin
	print '==================================';
	print 'CORRIDA NUMERO : '+CAST(@CORRIDA AS varchar(20));
	print 'ACTUALIZANDO PRODUCTOS CON STOCK MENOR A :'+CAST(@STOCKMINIMO AS varchar(20)) ;	
	print '==================================';	
	
	UPDATE [dbo].[Products]
	SET [UnitsInStock]=[UnitsInStock]+20
	WHERE [UnitsInStock]<@stockminimo;
 
	SELECT 
		[ProductID] AS CodigoProducto,
		[ProductName] as [Nombre Producto],
		[UnitsInStock] as Unidades
	FROM [dbo].[Products]
	WHERE [UnitsInStock]<@stockminimo
	ORDER BY [UnitsInStock] ASC;
 
	SET @corrida=@corrida+1;
end
select * from Products


/*ACTUALIZAR EL STOCK DE LOS PRODUCTOS
	SE HA DEFINIDO QUE TODO PRODUCTO DEBE DE TENER UN STOCK MINIMO DE 100 PRODUCTOS
*/
go
CREATE OR ALTER PROCEDURE USP_ActualizarStock
	@stockminimo int,
	@incremento int,
	@corrida int
AS
BEGIN
	
	select * from Products
	while exists ( 
				select 1 
				from [dbo].[Products] 
				where [UnitsInStock]<@stockminimo 
				)
	begin
		print '==================================';
		print 'CORRIDA NUMERO : '+CAST(@CORRIDA AS varchar(20));
		print 'ACTUALIZANDO PRODUCTOS CON STOCK MENOR A :'+CAST(@STOCKMINIMO AS varchar(20)) ;	
		print '==================================';	
	
		UPDATE [dbo].[Products]
		SET [UnitsInStock]=[UnitsInStock]+20
		WHERE [UnitsInStock]<@stockminimo;
 
		SELECT 
			[ProductID] AS CodigoProducto,
			[ProductName] as [Nombre Producto],
			[UnitsInStock] as Unidades
		FROM [dbo].[Products]
		WHERE [UnitsInStock]<@stockminimo
		ORDER BY [UnitsInStock] ASC;
 
		SET @corrida=@corrida+1;
		
		PRINT 'PROCESO TERMINADO, TODOS LOS PRODUCTOS HAN ALCANZADO EL STOCK MINIMO'
		SELECT 
			[ProductID] AS CodigoProducto,
			[ProductName] as [Nombre Producto],
			[UnitsInStock] as Unidades
		FROM [dbo].[Products]
		ORDER BY [UnitsInStock] ASC;
	end;
end

-- Ejecutar procedimiento almacenado
EXEC USP_ActualizarStock 
		@STOCKMINIMO=200,
		@INCREMENTO=20,
		@CORRIDA=1

go

-- Crear un procedimiento almacenado que cuenta la cantidad de pedidos po año
create or alter procedure usp_contarPedidosAnio
	@anioInicio INT,
	@AnioFin int,
	@incremento int,
	@totalpedidos int OUTPUT
AS
BEGIN
 
	declare @cantAnio int;
	set @totalpedidos=0
	while @anioInicio<=@AnioFin
		begin
			SELECT @cantAnio=COUNT(*)
			FROM [dbo].[Orders]
			WHERE YEAR([OrderDate])=@anioInicio
 
			PRINT 'AÑO CONSULTADO : '+CAST(@ANIOINICIO AS VARCHAR(20));
 
			PRINT 'CANTIDAD DE PEDIDOS : '+CAST(@CANTANIO AS VARCHAR(20));
 
			SET @totalpedidos=@totalpedidos+@cantAnio;
			
			SET @anioInicio=@anioInicio+@incremento;
		end;
END;
 
-- declarar variabe
DECLARE @ResultadoTotal as int;
--Ejecutar procedimiento almacenado
exec usp_contarPedidosAnio
	@anioinicio=1996,
	@aniofin=1998,
	@incremento=1,
	@totalpedidos=@resultadototal OUTPUT;
 
select @ResultadoTotal as TotalPedidosEncontrados