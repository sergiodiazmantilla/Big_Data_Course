use Northwind
go

/*
Crear un procedimiento almacenado que muestre 
el total de ventas de un producto determinado
*/

create or alter function fn_CalcularVentasProducto
(
	@ProductoID Int
)
Returns Money
AS
BEGIN
	declare @totalVentas money
	select @totalVentas = sum(unitprice*quantity*(1-Discount))
	from [dbo].[Order Details]
	where [ProductID]=@ProductoID

	return isnull(@totalVentas,0);
END
go

/*
Crear un procedimiento almacenado que reciba el codigo del producto y muestre:
1. codigo
2. nombre
3. precio unitario
4. stock actual
5. total vendido
6. clasificacion
*/

create or alter procedure usp_reporteProducto
	@IdProducto Int
AS
BEGIN
	select	p.ProductID Codigo,
			p.ProductName Nombre,
			p.UnitPrice Precio,
			p.UnitsInStock StockActual,
			[dbo].[fn_CalcularVentasProducto](p.ProductID) TotalVentas,
			case
				when [dbo].[fn_CalcularVentasProducto](p.ProductID) = 0 then 'Producto sin ventas'
				when [dbo].[fn_CalcularVentasProducto](p.ProductID) < 5000 then 'Producto de ventas bajas'
				when [dbo].[fn_CalcularVentasProducto](p.ProductID) between 5000 and 15000 then 'Producto de ventas medias'
				else 'Producto de ventas altas'
			end as ClasificacionVentas
	from [dbo].[Products] p
	where p.ProductID = @IdProducto
END

-- ejecutar procedimiento almacenado
exec usp_reporteProducto 5




