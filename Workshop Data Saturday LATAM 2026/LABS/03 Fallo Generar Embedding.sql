/*
Falla con un Error HTTP 400 sin más detalle
*/
SELECT AI_GENERATE_EMBEDDINGS(content use model Ada2Embeddings)
FROM Fail

GO

/*
Falla igual pero captura todo el detalle de la respuesta del modelo
Superado el contexto
*/
DECLARE @text NVARCHAR(MAX)
	,@embedding VECTOR(1536)

SELECT @text = content FROM Fail

exec sp_GetEmbedding @text, @embedding OUTPUT

select @embedding