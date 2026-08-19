/*
    Workshop: RAG seguro en SQL Server
    Lab 05 - Búsqueda vectorial exacta

    Objetivo:
    - Generar el embedding de una pregunta.
    - Compararlo con los embeddings del contenido.
    - Recuperar los 5 registros más próximos mediante VECTOR_DISTANCE.

    Prerrequisitos:
    - Base de datos DataSatLATAM.
    - External model Ada2Embeddings.
    - dbo.wikipedia_articles_embeddings cargada con embeddings.

    Orden:
    - Ejecutar después de los labs 01-04.
    - Este lab prepara la recuperación que utilizaremos en el RAG completo.

    Nota:
    - En esta primera versión la búsqueda es exacta.
    - Una distancia menor significa mayor proximidad semántica.
*/

USE [DataSatLATAM];
GO

-- 1. Escribe una pregunta y genera su embedding.
DECLARE @Pregunta NVARCHAR(MAX) =
    N'¿Qué es el aprendizaje automático y para qué se utiliza?';

DECLARE @EmbeddingPregunta VECTOR(1536);

SET @EmbeddingPregunta = AI_GENERATE_EMBEDDINGS(
    @Pregunta USE MODEL Ada2Embeddings
);

SELECT
    @Pregunta AS Pregunta,
    @EmbeddingPregunta AS EmbeddingPregunta;
GO

-- 2. Recupera los cinco contenidos más próximos.
DECLARE @Pregunta NVARCHAR(MAX) =
    N'¿Qué es el aprendizaje automático y para qué se utiliza?';

DECLARE @EmbeddingPregunta VECTOR(1536);

SET @EmbeddingPregunta = AI_GENERATE_EMBEDDINGS(
    @Pregunta USE MODEL Ada2Embeddings
);

SELECT TOP (5)
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
        AS decimal(10, 6)
    ) AS Similitud,
    LEFT(e.Content, 500) AS Contenido
FROM dbo.wikipedia_articles_embeddings AS e
WHERE e.content_vector_ada2 IS NOT NULL
ORDER BY DistanciaCoseno ASC;
GO

-- 3. Cambia la pregunta y vuelve a ejecutar el bloque anterior.
-- Ejemplos:
-- N'¿Cómo funciona una base de datos relacional?'
-- N'¿Qué características tiene la inteligencia artificial?'
-- N'¿Cómo se almacena y procesa la información?'
