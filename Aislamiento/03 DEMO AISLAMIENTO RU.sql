-- 1. Configuración inicial de la base de datos
USE master
GO

DROP DATABASE IF EXISTS DEMO_RU;
CREATE DATABASE DEMO_RU;
GO
USE [DEMO_RU];
GO

-- 2. Crear tabla de ejemplo
DROP TABLE IF EXISTS [FrasesDeEmpresa];
CREATE TABLE [FrasesDeEmpresa] (id int PRIMARY KEY, sentencia varchar(255));
GO
INSERT INTO [FrasesDeEmpresa] 
    VALUES 
    (1,'Esto es urgente'), 
    (2,'Si funciona no lo toques');
GO

-- 3. Transacciones con READ UNCOMMITTED para evitar bloqueos
-- Configuramos el nivel de aislamiento a READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRAN;
UPDATE [FrasesDeEmpresa] 
    SET sentencia = 'TODO es urgente'
    WHERE id = 1;

-- Realizar lectura bajo READ UNCOMMITTED
SELECT * FROM [FrasesDeEmpresa];

-- Opcional: ROLLBACK para revertir cambios
-- ROLLBACK;
GO

-- 4. Restablecemos el nivel de aislamiento por defecto si es necesario
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

-- 5. Limpieza
DROP TABLE IF EXISTS [FrasesDeEmpresa];
GO
