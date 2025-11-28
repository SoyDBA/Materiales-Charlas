-- CREATE INDEX IX_Posts_CreationDate on Posts ([CreationDate]) 
-- CREATE INDEX IX_Users_UpVotes on Users (UpVotes) 

SET STATISTICS IO,TIME ON

SELECT COUNT(1) FROM Posts WHERE YEAR(CreationDate) = 2010

SELECT COUNT(1) FROM Posts WHERE CreationDate BETWEEN '20100101' AND '20110101'

------------------------------------------------------------------------------------

SELECT COUNT(1) FROM [Users] WHERE UpVotes + 1 = 101

SELECT COUNT(1) FROM [Users] WHERE UpVotes = 100