USE [DataSatLATAM]
GO

/****** Object:  StoredProcedure [dbo].[sp_GetEmbedding]    Script Date: 03/08/2026 11:09:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   procedure [dbo].[sp_GetEmbedding]
@inputText nvarchar(max),
@embedding vector(1536) output
as
-- Iniciamos el bloque try-catch para manejar errores de SQL
begin try
    declare @retval int;
    declare @payload nvarchar(max) = json_object('input': @inputText);
    declare @response nvarchar(max)

    declare @url nvarchar(1000) = 'https://datasaturdaylatam-resource.cognitiveservices.azure.com/openai/deployments/text-embedding-ada-002/embeddings?api-version=2023-05-15' -- URL modelo (Azure AI Foundry ADA 2)
    exec @retval = sp_invoke_external_rest_endpoint
    @url = @url,
    @method = 'POST',
    @credential = [https://datasaturdaylatam-resource.cognitiveservices.azure.com], -- Nombre de la credencial (Endpoint Azure OpenAI)
    @payload = @payload,
    @response = @response output;
end try
-- Si ocurre un error de SQL, capturamos la información del error y la retornamos
begin catch
    select 
        'SQL' as error_source, 
        error_number() as error_code,
        error_message() as error_message
    return;
end catch

-- Si no hay error de SQL pero la llamada a la API de OpenAI falla, retornamos el error
if (@retval != 0) begin
    select 
        'OPENAI' as error_source, 
        json_value(@response, '$.result.error.code') as error_code,
        json_value(@response, '$.result.error.message') as error_message,
        @response as error_response
    return;
end;

-- Si todo es exitoso, extraemos el embedding del resultado y lo retornamos
set @embedding = cast(json_query(@response, '$.result.data[0].embedding') as vector(1536))

return @retval
GO


