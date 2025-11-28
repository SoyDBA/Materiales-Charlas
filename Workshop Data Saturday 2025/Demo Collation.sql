USE AdventureWorks2022
GO

SET STATISTICS TIME, IO ON

declare @nv nvarchar(50) = N'Brown'

SELECT 'CONSULTA 1'
Select BusinessEntityID, FirstName, MiddleName from Person.Person where LastName = @nv

SELECT 'CONSULTA 2'
Select BusinessEntityID, FirstName, MiddleName from Person.Person where LastName = @nv COLLATE SQL_Latin1_General_CP1_CS_AS

/* Consulta 1: Seek, Consulta 2: Scan */

IF NOT EXISTS(SELECT 1
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Person'
                and TABLE_SCHEMA = 'Person'
                 and TABLE_CATALOG = 'AdventureWorks2022'
                 AND COLUMN_NAME = 'LastNameSearch')
BEGIN

	-- Creamos la columna calculada
	ALTER TABLE Person.Person
	ADD LastNameSearch as (LastName) COLLATE SQL_Latin1_General_CP1_CS_AS
END
	   
--declare @nv nvarchar(50) = N'Brown'
SELECT 'CONSULTA 2'
Select BusinessEntityID, FirstName, MiddleName from Person.Person where LastName = @nv COLLATE SQL_Latin1_General_CP1_CS_AS

-- Deshabilitamos este índice para esta prueba porque siempre vamos a buscar por el Search.
ALTER INDEX [IX_Person_LastName_FirstName_MiddleName] ON Person.Person DISABLE;

-- Creamos el nuevo indice
CREATE NONCLUSTERED INDEX [ix_person_LastNameSearch_FirstName_MiddleName] ON [Person].[Person]
(
	[LastNameSearch] ASC,
	[FirstName] ASC,
	[MiddleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
		
SELECT 'CONSULTA 3'
Select BusinessEntityID, FirstName, MiddleName from Person.Person where LastNameSearch = @nv

-- Deshabilitamos este índice para esta prueba porque siempre vamos a buscar por el Search.
ALTER INDEX [IX_Person_LastName_FirstName_MiddleName] ON Person.Person REBUILD;
DROP INDEX [ix_person_LastNameSearch_FirstName_MiddleName] ON Person.Person;

ALTER TABLE Person.Person
DROP COLUMN LastNameSearch;






