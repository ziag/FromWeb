-- Query details about objects allocated in TEMPDB. This must be run in context of TEMPDB database.
USE TEMPDB;
select distinct
 DB_NAME() AS database_name
, o.type_desc object_type
, o.name AS object_name
, o.create_date AS object_created
, si.name as index_name
, case si.index_id 
   when 0 then 'HEAP' 
   when 1 then 'CLUSTERED' 
   else 'NONCLUSTERED' 
   end AS index_type
, row_count
, ((ps.reserved_page_count * 8024) / 1024 / 1024) as reserved_mb
, trace.HostName
, trace.LoginName
, trace.SPID
, trace.ApplicationName
from sys.dm_db_partition_stats ps 
LEFT JOIN sys.tables  AS o ON o.object_id = ps.OBJECT_ID 
left join sys.indexes si on si.object_id = o.object_id and si.index_id = ps.index_id
LEFT JOIN ::fn_trace_gettable(
   ( 
   SELECT LEFT(path, LEN(path)-CHARINDEX('\', REVERSE(path))) + '\Log.trc' 
   FROM    sys.traces 
   WHERE   is_default = 1 
   ), DEFAULT) trace
   on trace.ObjectID = ps.object_id 
   and trace.DatabaseName = 'tempdb'
where is_ms_shipped = 0 
order by reserved_mb desc;
