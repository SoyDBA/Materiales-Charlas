DROP TABLE IF EXISTS Empleados
CREATE TABLE Empleados (
	ID INT NOT NULL,
	Sueldo INT NOT NULL)
GO

INSERT INTO Empleados VALUES (1,1000),(2,2000)
GO

BEGIN TRAN
UPDATE Empleados
SET Sueldo = 1100
WHERE ID = 1

--SELECT * FROM sys.dm_tran_locks WHERE request_session_id = @@SPID AND resource_type in ('PAGE','RID','KEY','XACT');


ROLLBACK

SELECT * FROM EMPLEADOS


UPDATE Empleados
SET Sueldo = Sueldo + ((Sueldo*10)/100)
WHERE Sueldo = 2000



/*

-- DEMO 2

DROP TABLE IF EXISTS Empleados
CREATE TABLE Empleados (
	ID INT NOT NULL,
	Sueldo INT NOT NULL)
GO

INSERT INTO Empleados VALUES (1,1000)
GO

BEGIN TRAN
UPDATE Empleados
SET Sueldo = 1100
WHERE ID = 1


UPDATE Empleados
SET Sueldo = Sueldo + ((Sueldo*10)/100)
WHERE Sueldo < 1001

UPDATE Empleados
SET Sueldo = Sueldo + ((Sueldo*10)/100)
WHERE Sueldo > 1001
*/