DROP TABLE IF EXISTS foo
CREATE TABLE foo
(foo1 int PRIMARY KEY not null
,foo2 int null);
GO

INSERT INTO foo VALUES (1,10),(2,20),(3,30);
GO

BEGIN TRAN
UPDATE foo 
SET foo2=foo2+10

SELECT * FROM sys.dm_tran_locks WHERE request_session_id = @@SPID AND resource_type in ('PAGE','RID','KEY','XACT');


--COMMIT
--ROLLBACK

/*
BEGIN TRAN
UPDATE foo 
SET foo2=foo2+10
WHERE foo1 = 2;

ROLLBACK
*/