-- CREATE INDEX IX_Users_UpVotes on Users (UpVotes) 

SET STATISTICS IO ON

SELECT top 100000 *
FROM [StackOverflow2010].[dbo].[Users]
WHERE UpVotes > 100

SELECT top 100000 [Id], [UpVotes]
FROM [StackOverflow2010].[dbo].[Users]
WHERE UpVotes > 100

/*

SET STATISTICS IO ON
SELECT top 100000 *
FROM [StackOverflow].[dbo].[Users]
WHERE DownVotes > 100

SELECT top 100000 [Id], DownVotes
FROM [StackOverflow].[dbo].[Users]
WHERE DownVotes > 100

*/