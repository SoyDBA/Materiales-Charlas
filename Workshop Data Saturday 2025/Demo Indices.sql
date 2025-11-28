SELECT top 100000 [Id], [UpVotes]
FROM [StackOverflow2010].[dbo].[Users]
WHERE UpVotes > 100

SELECT top 100000 [Id], [UpVotes]
FROM [StackOverflow2010].[dbo].[Users] WITH (INDEX(0))
WHERE UpVotes > 100