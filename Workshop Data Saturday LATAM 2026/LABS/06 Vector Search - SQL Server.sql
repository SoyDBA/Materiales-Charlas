/*
    Workshop: RAG seguro en SQL Server
    Lab 06 - Índice vectorial y búsqueda aproximada

    Objetivo:
    - Repetir la búsqueda del Lab 05 con VECTOR_SEARCH.
    - Comparar el resultado de la búsqueda aproximada con VECTOR_DISTANCE.
    - Observar el efecto de aplicar un filtro relacional después de recuperar
      candidatos vectoriales.

    Prerrequisitos:
    - Base de datos DataSatLATAM.
    - External model Ada2Embeddings.
    - dbo.wikipedia_articles_embeddings cargada con embeddings.
    - PREVIEW_FEATURES habilitado en la base de datos.
    - Índice vectorial preparado previamente por el instructor.

    Nota:
    - El bloque de creación del índice es formativo y está comentado.
    - La demo no crea el índice durante la sesión para evitar tiempos de espera.
    - VECTOR_SEARCH devuelve una distancia menor para los vecinos más próximos.
    - En SQL Server 2025, VECTOR_SEARCH requiere PREVIEW_FEATURES = ON.
*/

USE [DataSatLATAM];
GO

/*
-- Bloque formativo: el instructor puede ejecutarlo antes del workshop.
-- Ejecutar una sola vez en DataSatLATAM:

ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

-- La tabla debe permanecer sin cambios mientras el índice vectorial esté creado.

CREATE VECTOR INDEX IX_wikipedia_content_vector_ada2
ON dbo.wikipedia_articles_embeddings (content_vector_ada2)
WITH (
    METRIC = 'cosine',
    TYPE = 'DISKANN'
);
GO
*/

-- 1. Genera el embedding de la pregunta.
DECLARE @Pregunta NVARCHAR(MAX) =
    N'¿Qué es el aprendizaje automático y para qué se utiliza?';

DECLARE @EmbeddingPregunta VECTOR(1536);

SET @EmbeddingPregunta = AI_GENERATE_EMBEDDINGS(
    @Pregunta USE MODEL Ada2Embeddings
);

-- 2. Recupera vecinos mediante VECTOR_SEARCH.
SELECT -- TOP (5) WITH APPROXIMATE 
    e.id,
    e.title,
    s.distance AS DistanciaCoseno,
    CAST(1 - s.distance AS DECIMAL(10, 6)) AS Similitud,
    LEFT(e.Content, 500) AS Contenido
FROM VECTOR_SEARCH(
    TABLE = dbo.wikipedia_articles_embeddings AS e,
    COLUMN = content_vector_ada2,
    SIMILAR_TO = @EmbeddingPregunta,
    METRIC = 'cosine'
    , TOP_N = 5 
) AS s
ORDER BY s.distance ASC;
GO

-- 3. Compara con la búsqueda exacta del Lab 05.
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
    LEFT(e.Content, 500) AS Contenido
FROM dbo.wikipedia_articles_embeddings AS e
WHERE e.content_vector_ada2 IS NOT NULL
ORDER BY DistanciaCoseno ASC;
GO

-- 4. Ejemplo de post-filtering.
-- El filtro se aplica después de recuperar los candidatos vectoriales.
-- Si no aparecen cinco filas, aumenta TOP (5) en la consulta vectorial.
DECLARE @Pregunta NVARCHAR(MAX) =
    N'¿Qué es el aprendizaje automático y para qué se utiliza?';

DECLARE @EmbeddingPregunta VECTOR(1536);

SET @EmbeddingPregunta = AI_GENERATE_EMBEDDINGS(
    @Pregunta USE MODEL Ada2Embeddings
);

SELECT TOP (5) WITH APPROXIMATE
    e.id,
    e.title,
    s.distance AS DistanciaCoseno,
    LEFT(e.Content, 500) AS Contenido
FROM VECTOR_SEARCH(
    TABLE = dbo.wikipedia_articles_embeddings AS e,
    COLUMN = content_vector_ada2,
    SIMILAR_TO = @EmbeddingPregunta,
    METRIC = 'cosine'
) AS s
WHERE e.title LIKE 'A%'
ORDER BY s.distance ASC;
GO

-- 5. Prueba con otra pregunta y observa si cambian los resultados.
-- N'¿Cómo funciona una base de datos relacional?'
-- N'¿Qué características tiene la inteligencia artificial?'
