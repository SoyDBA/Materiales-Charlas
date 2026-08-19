/*
    Workshop: RAG seguro en SQL Server
    Lab 09 - Observabilidad del RAG

    Objetivo:
    - Crear las tablas de log del RAG.
    - Guardar tiempos, tokens, pregunta, respuesta y errores.
    - Guardar el detalle de los documentos recuperados y su similitud.

    Prerrequisitos:
    - Base de datos DataSatLATAM.
    - dbo.ModeloPrecio creada y poblada.
    - Ejecutar despues de los labs 01-07.

    Orden:
    1. Ejecutar este script una vez.
    2. Ejecutar 09_b SP RAG Observabilidad.sql.
    3. Consultar los logs con las consultas del final.
*/

USE [DataSatLATAM];
GO

-- Una fila por ejecucion del RAG.
IF OBJECT_ID(N'dbo.RAGLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RAGLog
    (
        Id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_RAGLog PRIMARY KEY CLUSTERED,
        Usuario NVARCHAR(128) NOT NULL,
        Pregunta NVARCHAR(MAX) NOT NULL,
        FechaHoraInicio DATETIME2(3) NOT NULL,
        FechaHoraEmbedding DATETIME2(3) NULL,
        FechaHoraRecuperado DATETIME2(3) NULL,
        FechaHoraRespuesta DATETIME2(3) NULL,
        DuracionEmbeddingMs AS DATEDIFF(MILLISECOND, FechaHoraInicio, FechaHoraEmbedding),
        DuracionRecuperacionMs AS DATEDIFF(MILLISECOND, FechaHoraEmbedding, FechaHoraRecuperado),
        DuracionLLMMs AS DATEDIFF(MILLISECOND, FechaHoraRecuperado, FechaHoraRespuesta),
        DuracionTotalMs AS DATEDIFF(MILLISECOND, FechaHoraInicio, FechaHoraRespuesta),
        Respuesta NVARCHAR(MAX) NULL,
        ErrorMensaje NVARCHAR(500) NULL,
        TokensEmbedding INT NULL,
        TokensLLMEntrada INT NULL,
        TokensLLMSalida INT NULL
    );
END;
GO

-- Una fila por documento utilizado como contexto en cada ejecucion.
IF OBJECT_ID(N'dbo.RAGLogDetalle', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RAGLogDetalle
    (
        Id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_RAGLogDetalle PRIMARY KEY CLUSTERED,
        IdLog INT NOT NULL
            CONSTRAINT FK_RAGLogDetalle_RAGLog
                REFERENCES dbo.RAGLog(Id),
        Posicion INT NOT NULL,
        IdDocumento INT NOT NULL,
        Titulo VARCHAR(1000) NULL,
        Url VARCHAR(1000) NULL,
        DistanciaCoseno FLOAT NULL,
        Similitud DECIMAL(10, 6) NULL
    );
END;
GO

-- Verifica que los precios necesarios existan antes de calcular costes.
SELECT Modelo, TipoToken, PrecioPorMillon, Moneda
FROM dbo.ModeloPrecio
WHERE (Modelo = N'text-embedding-ada-002' AND TipoToken = N'embedding')
   OR (Modelo = N'gpt-4o-2024-1120' AND TipoToken IN (N'input', N'output'))
ORDER BY Modelo, TipoToken;
GO

-- Consultas de observabilidad.
SELECT TOP (20)
    Id,
    Usuario,
    Pregunta,
    FechaHoraInicio,
    DuracionEmbeddingMs,
    DuracionRecuperacionMs,
    DuracionLLMMs,
    DuracionTotalMs,
    TokensEmbedding,
    TokensLLMEntrada,
    TokensLLMSalida,
    ErrorMensaje
FROM dbo.RAGLog
ORDER BY Id DESC;
GO

SELECT TOP (50)
    d.IdLog,
    d.Posicion,
    d.IdDocumento,
    d.Titulo,
    d.DistanciaCoseno,
    d.Similitud
FROM dbo.RAGLogDetalle AS d
ORDER BY d.IdLog DESC, d.Posicion;
GO

-- Coste estimado por ejecucion usando dbo.ModeloPrecio.
SELECT TOP (20)
    l.Id,
    l.Pregunta,
    l.TokensEmbedding,
    l.TokensLLMEntrada,
    l.TokensLLMSalida,
    CAST(
        l.TokensEmbedding * pe.PrecioPorMillon / 1000000.0
        AS DECIMAL(12, 8)
    ) AS CosteEmbedding,
    CAST(
        l.TokensLLMEntrada * pi.PrecioPorMillon / 1000000.0
        AS DECIMAL(12, 8)
    ) AS CosteLLMEntrada,
    CAST(
        l.TokensLLMSalida * po.PrecioPorMillon / 1000000.0
        AS DECIMAL(12, 8)
    ) AS CosteLLMSalida,
    CAST(
        l.TokensEmbedding * pe.PrecioPorMillon / 1000000.0 +
        l.TokensLLMEntrada * pi.PrecioPorMillon / 1000000.0 +
        l.TokensLLMSalida * po.PrecioPorMillon / 1000000.0
        AS DECIMAL(12, 8)
    ) AS CosteTotal
FROM dbo.RAGLog AS l
LEFT JOIN dbo.ModeloPrecio AS pe
    ON pe.Modelo = N'text-embedding-ada-002'
    AND pe.TipoToken = N'embedding'
    AND pe.VigenciaHasta IS NULL
LEFT JOIN dbo.ModeloPrecio AS pi
    ON pi.Modelo = N'gpt-4o-2024-1120'
    AND pi.TipoToken = N'input'
    AND pi.VigenciaHasta IS NULL
LEFT JOIN dbo.ModeloPrecio AS po
    ON po.Modelo = N'gpt-4o-2024-1120'
    AND po.TipoToken = N'output'
    AND po.VigenciaHasta IS NULL
ORDER BY l.Id DESC;
GO
