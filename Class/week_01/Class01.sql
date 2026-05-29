-- CREAR UNA BASE DE DATOS LLAMADA "nombre_database"
CREATE DATABASE nombre_database

-- SECCIÓN: ARCHIVO DE DATOS PRINCIPAL (.mdf)
ON (
    -- Nombre lógico del archivo de datos dentro de SQL Server
    NAME = nombre_database_Data,

    -- Ruta física donde se guardará el archivo en tu disco duro
    -- Confirmar Ubicacion y existencia de las carpetas
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\nombre_database_Data.mdf',

    -- Tamaño inicial del archivo de datos
    SIZE = 50MB,

    -- Tamaño máximo que puede crecer el archivo
    MAXSIZE = 100MB,

    -- Cuánto crecerá cada vez que necesite más espacio
    FILEGROWTH = 10MB
)

-- SECCIÓN: ARCHIVO DE LOG (registro de transacciones)
LOG ON (
    -- Nombre lógico del archivo de log
    NAME = nombre_database_Log,

    -- Ruta física del archivo de log (.ldf)
	-- Confirmar Ubicacion y existencia de las carpetas
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\nombre_database_Log.ldf',

    -- Tamaño inicial del log
    SIZE = 10MB,

    -- Tamaño máximo del log
    MAXSIZE = 50MB,

    -- Crecimiento del log cuando se llene
    FILEGROWTH = 5MB
)