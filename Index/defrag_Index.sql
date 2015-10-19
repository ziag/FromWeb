/* Originally created by Microsoft */
/* Error corrected by Pinal Dave (http://www.SQLAuthority.com) */
-- Specify your Database Name

-- Declare variables
SET NOCOUNT ON;

DECLARE @tablename VARCHAR(128);
DECLARE @execstr VARCHAR(255);
DECLARE @objectid INT;
DECLARE @indexid INT;
DECLARE @frag decimal;
DECLARE @maxfrag decimal;
-- Decide on the maximum fragmentation to allow for.

SELECT @maxfrag = 30.0;
-- Declare a cursor.
DECLARE tables CURSOR FOR
	SELECT CAST(TABLE_SCHEMA AS VARCHAR(100)) +'.'+ CAST(TABLE_NAME AS VARCHAR(100))AS Table_Name
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_TYPE = 'BASE TABLE';

-- Create the table.
CREATE TABLE #fraglist (ObjectName CHAR(255),
						ObjectId INT,
						IndexName CHAR(255),
						IndexId INT,
						Lvl INT,
						CountPages INT,
						CountRows INT,
						MinRecSize INT,
						MaxRecSize INT,
						AvgRecSize INT,
						ForRecCount INT,
						Extents INT,
						ExtentSwitches INT,
						AvgFreeBytes INT,
						AvgPageDensity INT,
						ScanDensity decimal,
						BestCount INT,
						ActualCount INT,
						LogicalFrag decimal,
						ExtentFrag decimal);
-- Open the cursor.
OPEN tables;
-- Loop through all the tables in the database.
FETCH NEXT
FROM tables
INTO @tablename;


WHILE @@FETCH_STATUS = 0
BEGIN;
-- Do the showcontig of all indexes of the table
	INSERT INTO #fraglist
	EXEC ('DBCC SHOWCONTIG (''' + @tablename + ''') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS');
	FETCH NEXT
	FROM tables
	INTO @tablename;
END;
-- Close and deallocate the cursor.
CLOSE tables;
DEALLOCATE tables;
-- Declare the cursor for the list of indexes to be defragged.
DECLARE indexes CURSOR FOR
	SELECT ObjectName,
		   ObjectId, 
		   IndexId, 
		   LogicalFrag
	FROM #fraglist
	WHERE LogicalFrag >= @maxfrag
	AND INDEXPROPERTY (ObjectId, IndexName, 'IndexDepth') > 0;
-- Open the cursor.
OPEN indexes;
-- Loop through the indexes.
FETCH NEXT
FROM indexes
INTO @tablename, @objectid, @indexid, @frag;
WHILE @@FETCH_STATUS = 0
BEGIN;
PRINT 'Executing DBCC INDEXDEFRAG (0, ' + RTRIM(@tablename) + ',' + RTRIM(@indexid) + ') - fragmentation currently ' + RTRIM(CONVERT(VARCHAR(15),@frag)) + '%';

SELECT @execstr = 'DBCC INDEXDEFRAG (0, ' + RTRIM(@objectid) + ',' + RTRIM(@indexid) + ')';
EXEC (@execstr);
FETCH NEXT
FROM indexes
INTO @tablename, @objectid, @indexid, @frag;
END;
-- Close and deallocate the cursor.
CLOSE indexes;
DEALLOCATE indexes;
-- Delete the temporary table.
DROP TABLE #fraglist;
GO