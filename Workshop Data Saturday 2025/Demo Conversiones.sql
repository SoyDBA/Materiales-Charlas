SET STATISTICS IO,TIME ON
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-ver17#j-use-convert-with-datetime-data-in-different-formats

SELECT COUNT(1) FROM Posts WHERE convert(nvarchar(10),CreationDate,103) = '05/06/2010'

SELECT COUNT(1) FROM Posts WHERE CreationDate = '20100605'



SELECT COUNT(1) FROM Users WHERE UpVotes = '200'

SELECT COUNT(1) FROM Users WHERE UpVotes = 200


SELECT COUNT(1) FROM Users WHERE convert(Varchar(11),UpVotes) = '200'
