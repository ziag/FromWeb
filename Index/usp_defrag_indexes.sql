 --CREATE PROCEDURE [dbo].[usp_defrag_indexes]
declare	@dbname sysname= 'Sigart', @fillfactor int = 80, @fragthreshold int = 30
--AS
	declare @query nvarchar(max)
	if (DB_ID(@dbname)) is NULL
	begin
		print 'Invalid database name.'
		return 0
	end
	if @dbname = 'tempdb'
	begin
		print 'TEMPDB cannot be indexed reliably.'
		return 0
	end
	if (select COUNT(*) from master.dbo.sysdatabases where name = @dbname and cmptlevel < 90) > 0
	begin
		print 'Only SQL 2005 databases and up allowed.'
		return 0
	end
	

	print '----- Beginning defragging of: ' + quotename(@dbname) + ' at '
		+ CONVERT(varchar(19), getdate(), 121);
	if (@fillfactor < 0 or @fillfactor > 100)		-- defaults to common 80% fillfactor
		set @fillfactor = 80
	if (@fragthreshold < 0 or @fragthreshold > 100)	-- prevents silliness
		set @fragthreshold = 30
	set @query =
	'USE ' + QUOTENAME(@dbname) + ';
	SET NOCOUNT ON;
	DECLARE @objectid int;
	DECLARE @indexid int;
	DECLARE @partitioncount bigint;
	DECLARE @schemaname nvarchar(130); 
	DECLARE @objectname nvarchar(130); 
	DECLARE @indexname nvarchar(130); 
	DECLARE @partitionnum bigint;
	DECLARE @partitions bigint;
	DECLARE @frag float;
	DECLARE @command nvarchar(4000); 
	DECLARE @lock_esc int;
	
	-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function 
	-- and convert object and index IDs to names.

	SELECT
		A.object_id AS objectid,
		A.index_id AS indexid,
		A.partition_number AS partitionnum,
		A.avg_fragmentation_in_percent AS frag,
		B.lock_escalation AS lock_escalation
	INTO #work_to_do
	FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, ''LIMITED'') as A
		inner join sys.tables as B on B.object_id = A.object_id
	WHERE A.avg_fragmentation_in_percent >= 10.0 AND A.index_id > 0 and A.page_count > 500

	-- Declare the cursor for the list of partitions to be processed.
	DECLARE partitions CURSOR FOR SELECT * FROM #work_to_do;

	-- Open the cursor.
	OPEN partitions;

	-- Loop through the partitions.
	WHILE (1=1)
		BEGIN;
			FETCH NEXT
			   FROM partitions
			   INTO @objectid, @indexid, @partitionnum, @frag, @lock_esc;
			IF @@FETCH_STATUS < 0 BREAK;
			SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
			FROM sys.objects AS o
			JOIN sys.schemas as s ON s.schema_id = o.schema_id
			WHERE o.object_id = @objectid;
			SELECT @indexname = QUOTENAME(name)
			FROM sys.indexes
			WHERE  object_id = @objectid AND index_id = @indexid;
			SELECT @partitioncount = count (*)
			FROM sys.partitions
			WHERE object_id = @objectid AND index_id = @indexid;

			IF @partitioncount > 1 and @frag < ' +cast(@fragthreshold as varchar(3)) + '
			SET @command = N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + 
				N'' REORGANIZE PARTITION='' + CAST(@partitionnum AS nvarchar(10));
			ELSE
			IF @partitioncount > 1 and @frag >= ' + cast(@fragthreshold as varchar(3)) + '
			SET @command = N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + 
				N'' REBUILD PARTITION='' + CAST(@partitionnum AS nvarchar(10));
			ELSE 
			IF @frag < ' +cast(@fragthreshold as varchar(3)) + '
			SET @command = N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + 
				N'' REORGANIZE'';
			ELSE				
			IF @frag >= ' +cast(@fragthreshold as varchar(3)) + '
			SET @command = N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + 
				N'' REBUILD WITH (ONLINE=ON, FILLFACTOR = ' + cast(@fillfactor as varchar(3)) + ')'';
				
			IF CAST(SERVERPROPERTY(''Edition'') AS VARCHAR(MAX)) LIKE ''%Standard%''
				SET @command = REPLACE(@command, ''ONLINE=ON'', ''ONLINE=OFF'')

			IF @lock_esc <> 0 -- if lock escalation is disabled, a reorganize is not possible, so this fixes it 
				SET @command = REPLACE(@command, ''REORGANIZE'', ''REBUILD'');
				
			BEGIN TRY
				EXEC (@command);
				PRINT N''Executed: '' + @command;
			END TRY
			BEGIN CATCH -- if the rebuild fails, generally because ONLINE=ON was a problem
				IF @command like ''%line[_]item %''
					SET @command = REPLACE(@command, ''REORGANIZE'', ''REBUILD'')
				SET @command = REPLACE(@command, ''ONLINE=ON'', ''ONLINE=OFF'')
				exec (@command)
				print N''Executed (CATCH with ONLINE = OFF): '' + @command
			END CATCH
		END

	-- Close and deallocate the cursor.
	CLOSE partitions;
	DEALLOCATE partitions;

	-- Drop the temporary table.
	DROP TABLE #work_to_do;'
	-- print (@query)
	exec (@query)

	print '----- Ending defragging of: ' + quotename(@dbname) + ' at '
		+ CONVERT(varchar(19), getdate(), 121);
	print '';
GO
