USE [DataSatLATAM]
GO

-- Generar los chunks a partir de la tabla Fail y almacenarlos en la tabla FailChunks
-- La función de tabla AI_GENERATE_CHUNKS se utiliza para dividir el contenido de cada fila en la tabla Fail en chunks de tamaño fijo
-- Puede incluir un porcentaje de solapamiento de caracteres entre chunks.
-- Sintaxis de la función AI_GENERATE_CHUNKS:
-- AI_GENERATE_CHUNKS (SOURCE = text_expression
--                    , CHUNK_TYPE = FIXED
--                    [ , CHUNK_SIZE = numeric_expression ]
--                    [ , OVERLAP = numeric_expression ]
--                    [ , ENABLE_CHUNK_SET_ID = numeric_expression ]
-- )
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/ai-generate-chunks-transact-sql?view=sql-server-ver17

SELECT
    f.id,
    c.chunk_order,
    c.chunk_offset,
    c.chunk_length,
    c.chunk
FROM Fail f
CROSS APPLY AI_GENERATE_CHUNKS(
    source = f.content,
    chunk_type = FIXED,
    chunk_size = 5000,
    overlap = 2 -- 2% de solapamiento entre chunks (100 caracteres)
) c;


-- Crear la tabla FailChunks para almacenar los chunks generados a partir de la tabla Fail
CREATE TABLE FailChunks (
    chunk_id bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    source_row_id int NOT NULL,
    chunk_order bigint NOT NULL,
    chunk_offset bigint NOT NULL,
    chunk_length int NOT NULL,
    chunk_text nvarchar(max) NOT NULL,
    chunk_embedding vector(1536) NULL,
    created_at datetime2(3) NOT NULL CONSTRAINT DF_FailChunks_created_at DEFAULT sysutcdatetime()
);
GO


-- Insertar los registros en la tabla FailChunks a partir de los chunks generados de la tabla Fail
INSERT INTO FailChunks
(
    source_row_id,
    chunk_order,
    chunk_offset,
    chunk_length,
    chunk_text,
    chunk_embedding
)
SELECT
    f.id,
    c.chunk_order,
    c.chunk_offset,
    c.chunk_length,
    c.chunk,
    AI_GENERATE_EMBEDDINGS(c.chunk USE MODEL Ada2Embeddings)
FROM Fail f
CROSS APPLY AI_GENERATE_CHUNKS(
    source = f.content,
    chunk_type = FIXED,
    chunk_size = 5000,
    overlap = 2
) c;


-- Consultar los registros insertados en la tabla FailChunks para verificar que se hayan generado correctamente
SELECT *
FROM FailChunks
ORDER BY chunk_id;
GO
