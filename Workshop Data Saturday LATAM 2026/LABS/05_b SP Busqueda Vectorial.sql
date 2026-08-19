/*
    Workshop: RAG seguro en SQL Server
    Lab 05b - Stored procedure de búsqueda vectorial exacta

    Objetivo:
    - Encapsular la búsqueda del Lab 05 en un procedimiento almacenado.
    - Recibir una pregunta y el número de respuestas a recuperar.
    - Devolver los contenidos más próximos mediante VECTOR_DISTANCE.

    Prerrequisitos:
    - Base de datos DataSatLATAM.
    - External model Ada2Embeddings.
    - dbo.wikipedia_articles_embeddings cargada con embeddings.

    Orden:
    - Ejecutar después de 05 Vector Distance.sql.
*/

USE [DataSatLATAM];
GO

CREATE OR ALTER PROCEDURE dbo.usp_BuscarVectorial
    @Pregunta NVARCHAR(MAX),
    @NumeroRespuestas INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmbeddingPregunta VECTOR(1536);

    SET @EmbeddingPregunta = AI_GENERATE_EMBEDDINGS(
        @Pregunta USE MODEL Ada2Embeddings
    );

    SELECT TOP (@NumeroRespuestas)
        e.id,
        e.title,
        VECTOR_DISTANCE(
            'cosine',
            e.content_vector_ada2,
            @EmbeddingPregunta
        ) AS DistanciaCoseno,
        CAST(
            1 - VECTOR_DISTANCE(
                'cosine',
                e.content_vector_ada2,
                @EmbeddingPregunta
            )
            AS DECIMAL(10, 6)
        ) AS Similitud,
        e.Content
    FROM dbo.wikipedia_articles_embeddings AS e
    WHERE e.content_vector_ada2 IS NOT NULL
    ORDER BY DistanciaCoseno ASC;
END;
GO

-- Ejemplo de ejecucion
EXEC dbo.usp_BuscarVectorial
    @Pregunta = N'¿Qué es el aprendizaje automático y para qué se utiliza?',
    @NumeroRespuestas = 5;
GO

-- Prueba cambiando la pregunta y el numero de respuestas.
-- EXEC dbo.usp_BuscarVectorial
--     @Pregunta = N'¿Cómo funciona una base de datos relacional?',
--     @NumeroRespuestas = 3;
