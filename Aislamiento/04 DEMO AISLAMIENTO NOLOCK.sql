DROP DATABASE IF EXISTS DEMO_NOLOCK
CREATE DATABASE DEMO_NOLOCK
GO
USE [DEMO_NOLOCK]
GO


-------------------------------------------------------------------------------------
-- NOLOCK
-------------------------------------------------------------------------------------


drop table if exists [objetos]
create table [objetos] (id varbinary(8) primary key, nombre varchar(100))

GO

insert into objetos
select top 100 newid(), name from sys.sysobjects
GO 100

select count(1) from objetos

while 1=1
begin
update objetos set id=newid()
end

drop table if exists [recuento]
create table [recuento] (recuento int)
GO

while 1=1
begin
insert into [recuento]
	select count(1) from objetos WITH (NOLOCK)
end

select * from recuento where recuento!=10000



-------------------------------------------------------------------------------------
-- NOLOCK 2
-------------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.SingleRow;
CREATE TABLE dbo.SingleRow
(
    RowID int NOT NULL,
    LOB1 varchar(max) NOT NULL,
    LOB2 varchar(max) NOT NULL,
    CONSTRAINT pk_SingleRow PRIMARY KEY CLUSTERED(RowID)
);

INSERT dbo.SingleRow(RowID,LOB1,LOB2) VALUES(1,
  REPLICATE(CONVERT(varchar(max),'X'),16100),
  REPLICATE(CONVERT(varchar(max),'X'),16100));

    select * from SingleRow


SET NOCOUNT ON;

DECLARE @AllXs varchar(max) = REPLICATE(CONVERT(varchar(max), 'X'), 16100),
        @AllYs varchar(max) = REPLICATE(CONVERT(varchar(max), 'Y'), 16100); 

WHILE 1 = 1
BEGIN
    UPDATE dbo.SingleRow
    SET LOB1 = @AllYs, LOB2 = @AllYs
    WHERE RowID = 1;

    UPDATE dbo.SingleRow
    SET LOB1 = @AllXs, LOB2 = @AllXs
    WHERE RowID = 1;
END;
--
DECLARE @bad_row int = 0, 
        @bad_tuple int = 0,
        @LOB1 varchar(max) = '',
        @LOB2 varchar(max) = '',
        @AllXs varchar(max) = REPLICATE(CONVERT(varchar(max), 'X'), 16100),
        @AllYs varchar(max) = REPLICATE( CONVERT(varchar(max), 'Y'), 16100);

WHILE @bad_row + @bad_tuple < 2
BEGIN
    SELECT @LOB1 = LOB1, @LOB2 = LOB2
      FROM dbo.SingleRow WITH(NOLOCK)
      WHERE RowID = 1;

    IF @LOB1 <> @LOB2 AND (@LOB1 IN (@AllXs,@AllYs)) AND (@LOB2 IN (@AllXs,@AllYs))
    BEGIN
      -- corrupt row (one column before an update, one column after update)
      SET @bad_row = 1;
      PRINT 'Corrupt row. LOB1 = ' + LEFT(@LOB1, 10) + '...' + RIGHT(@LOB1, 10)
          + '..., LOB2 = ' + LEFT(@LOB2, 10) + '...' + RIGHT(@LOB2, 10);
    END

    IF @LOB1 NOT IN (@AllXs, @AllYs) 
    BEGIN
      -- corrupt tuple (one LOB page from before an update, one LOB page from after)
      SET @bad_tuple = 1;
      PRINT 'Corrupt value. LOB1 = ' + LEFT(@LOB1, 10) + '...' + RIGHT(@LOB1, 10);
    END
END;


