use Northwind
go

select top 10
	CustomerID,
	CompanyName,
	ContactName,
	ContactTitle
from Customers

------------------------
-- USO DE TRY / CATCH
------------------------
begin try
	insert into [dbo]. [Customers]
	(
		[CustomerID],
		[CompanyName],
		[ContactName],
		[Country]
	)
	values
	(
		'PER0154',
		'EMPRESA LOS INCAS',
		'JUAN PEREZ',
		'PERU'
	)
end try

begin catch
	PRINT 'OCURRIO UN ERROR';
	PRINT ERROR_MESSAGE();

end catch