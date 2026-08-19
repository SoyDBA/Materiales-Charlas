/*
    Workshop: RAG seguro en SQL Server
    Lab 06b - Stored procedure de búsqueda vectorial

    Objetivo:
    - Ampliar el procedimiento del Lab 05b.
    - Elegir entre búsqueda exacta y aproximada mediante @Indice.
    - Mantener el mismo resultado para reutilizarlo en el RAG.

    Parámetros:
    - @Pregunta: texto que se quiere buscar.
    - @NumeroRespuestas: número de resultados que se recuperan.
    - @Indice = 0: búsqueda exacta con VECTOR_DISTANCE.
    - @Indice = 1: búsqueda aproximada con VECTOR_SEARCH.

    Prerrequisitos:
    - Base de datos DataSatLATAM.
    - External model Ada2Embeddings.
    - dbo.wikipedia_articles_embeddings cargada con embeddings.
    - Índice vectorial v2 creado sobre content_vector_ada2 para @Indice = 1.
*/

USE [DataSatLATAM];
GO

CREATE OR ALTER PROCEDURE dbo.usp_BuscarVectorial
    @Pregunta NVARCHAR(MAX),
    @NumeroRespuestas INT,
    @Indice BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmbeddingPregunta VECTOR(1536);

    SET @EmbeddingPregunta = AI_GENERATE_EMBEDDINGS(
        @Pregunta USE MODEL Ada2Embeddings
    );

    IF @Indice = 1
    BEGIN
        SELECT --TOP (@NumeroRespuestas) WITH APPROXIMATE
            e.id,
            e.title,
            s.distance AS DistanciaCoseno,
            CAST(1 - s.distance AS DECIMAL(10, 6)) AS Similitud,
            e.Content
        FROM VECTOR_SEARCH(
            TABLE = dbo.wikipedia_articles_embeddings AS e,
            COLUMN = content_vector_ada2,
            SIMILAR_TO = @EmbeddingPregunta,
            METRIC = 'cosine'
            , TOP_N = @NumeroRespuestas
        ) AS s
        ORDER BY s.distance ASC;
    END;
    ELSE
    BEGIN
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
END;
GO

-- Búsqueda exacta con VECTOR_DISTANCE.
EXEC dbo.usp_BuscarVectorial
    @Pregunta = N'¿Qué es el aprendizaje automático y para qué se utiliza?',
    @NumeroRespuestas = 5,
    @Indice = 0;
GO

-- Búsqueda aproximada con VECTOR_SEARCH.
EXEC dbo.usp_BuscarVectorial
    @Pregunta = N'¿Qué es el aprendizaje automático y para qué se utiliza?',
    @NumeroRespuestas = 5,
    @Indice = 1;
GO
