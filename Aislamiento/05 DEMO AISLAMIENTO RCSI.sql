-- 1. Configuración inicial de la base de datos y habilitación de RCSI
DROP DATABASE IF EXISTS DEMOGUAY;
CREATE DATABASE DEMOGUAY;
ALTER DATABASE DEMOGUAY SET ALLOW_SNAPSHOT_ISOLATION ON;
ALTER DATABASE DEMOGUAY SET READ_COMMITTED_SNAPSHOT ON;
GO
USE [DEMOGUAY];
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

-- 3. Ejemplo de transacción de escritura que simula un cambio en los datos
BEGIN TRAN;
UPDATE [FrasesDeEmpresa] 
    SET sentencia = 'TODO es urgente'
    WHERE id = 1;

-- Realizar lectura usando RCSI (en otra sesión o contexto paralelo)
-- Esta lectura no bloqueará ni se verá bloqueada por la transacción de escritura en progreso.
SELECT * FROM [FrasesDeEmpresa] 

-- Opcional: ROLLBACK para revertir cambios
-- ROLLBACK;
GO

-- 4. Limpieza
DROP TABLE IF EXISTS [FrasesDeEmpresa];
GO
