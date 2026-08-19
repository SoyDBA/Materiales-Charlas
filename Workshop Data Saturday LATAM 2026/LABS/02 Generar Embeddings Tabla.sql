USE DataSatLATAM
GO

SELECT *
FROM Enfermedades;

-- Actualiza la columna embedding de la tabla Enfermedades 
-- utilizando el modelo Ada2Embeddings para generar los embeddings a partir de la columna descripcion_sintomas.
-- La función AI_GENERATE_EMBEDDINGS toma como entrada el texto de la columna descripcion_sintomas y
-- devuelve un vector de embeddings que se almacena en la columna embedding.
-- Sintaxis: AI_GENERATE_EMBEDDINGS ( source USE MODEL model_identifier )
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/ai-generate-embeddings-transact-sql?view=sql-server-ver17&tabs=request-headers

UPDATE Enfermedades
SET embedding = AI_GENERATE_EMBEDDINGS ( descripcion_sintomas USE MODEL Ada2Embeddings)
GO


SELECT *
FROM Enfermedades;


