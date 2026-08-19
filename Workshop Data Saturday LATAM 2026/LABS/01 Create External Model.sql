--========================================
-- Habilitar llamadas API
--========================================
USE master;
GO
sp_configure 'external rest endpoint enabled', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

USE [DataSatLATAM]
GO
-- Master Key
if not exists(select * from sys.symmetric_keys where [name] = '##MS_DatabaseMasterKey##')
begin
    create master key encryption by password = N'Contras3ñ@';
end
go

/*

OPEN MASTER KEY DECRYPTION BY PASSWORD = 'Contras3ñ@'

ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = 'Contras3ñ@'

*/


/*
    Create database credentials to store API key
*/
if exists(select * from sys.[database_scoped_credentials] where name = 'https://datasaturdaylatam-resource.cognitiveservices.azure.com')
begin
	drop database scoped credential [https://datasaturdaylatam-resource.cognitiveservices.azure.com];
end
create database scoped credential [https://datasaturdaylatam-resource.cognitiveservices.azure.com]
with identity = 'HTTPEndpointHeaders', secret = '{"api-key": "<APIKEYDELMODELO>"}';
go


/*
    Setup external model to allow embedding model usage
    Note: <deployment-id> needs to be replaced with the deployment name of your embedding model in Azure OpenAI
*/
if  exists(select * from sys.external_models where [name] = 'Ada2Embeddings')
begin
	drop external model [Ada2Embeddings];
end
go

create external model Ada2Embeddings
with ( 
    location = 'https://datasaturdaylatam-resource.cognitiveservices.azure.com/openai/deployments/text-embedding-ada-002/embeddings?api-version=2023-05-15',
    credential = [https://datasaturdaylatam-resource.cognitiveservices.azure.com],
    api_format = 'Azure OpenAI',
    model_type = embeddings,
    model = 'embeddings'
);
go

select * from sys.external_models where [name] = 'Ada2Embeddings'
go

SELECT AI_GENERATE_EMBEDDINGS('Hola mundo' use model Ada2Embeddings) AS Embedding;