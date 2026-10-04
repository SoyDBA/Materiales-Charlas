USE master;
--ALTER DATABASE DemoRendimiento SET COMPATIBILITY_LEVEL = 150;
USE DemoRendimiento;
DBCC FREEPROCCACHE;
EXEC dbo.usp_ResumenVentasCliente @ClienteId = 5000;
EXEC dbo.usp_ResumenVentasCliente @ClienteId = 1;



-- Chat con copilot:
-- Estoy haciendo unas consultas en la base de datos DemoRendimiento y a veces va bien y otras va lento. Puedes revisar que pasa?
