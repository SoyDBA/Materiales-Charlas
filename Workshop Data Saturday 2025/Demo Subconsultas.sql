SET STATISTICS TIME,IO ON

SELECT Id, AcceptedAnswerId, AnswerCount, 
	(SELECT top 1 DisplayName FROM Users WHERE OwnerUserId = Id) 
from posts


SELECT Posts.Id, Posts.AcceptedAnswerId, Posts.AnswerCount, Users.DisplayName
FROM Posts
LEFT JOIN Users 
	ON Posts.OwnerUserId = Users.Id

/*
CREATE NONCLUSTERED INDEX IX_Posts_OwnerUserId_INCLUDES
ON [dbo].[Posts] ([OwnerUserId]) INCLUDE ([AcceptedAnswerId],[AnswerCount],[LastEditorUserId])
GO

CREATE INDEX IX_Users_Reputation ON Users (Reputation) INCLUDE (DisplayName)
*/

SELECT Posts.Id, Posts.AcceptedAnswerId, Posts.AnswerCount
	, UserOwner.DisplayName AS OwnerName
	, UserEditor.DisplayName AS EditorName
FROM Posts
INNER JOIN Users AS UserOwner
	ON Posts.OwnerUserId = UserOwner.Id
INNER JOIN Users AS UserEditor
	ON Posts.LastEditorUserId = UserEditor.Id
WHERE
	UserOwner.Reputation > 100
		OR UserEditor.Reputation > 100

