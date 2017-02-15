BEGIN TRAN

select a.id as 'ObjectID', isnull(a.name,'Heap') as 'IndexName', b.name as 'TableName',
stats_date (id,indid) as stats_last_updated_time
from sys.sysindexes as a
inner join sys.objects as b
on a.id = b.object_id
where b.type = 'U'

ORDER BY  stats_date (id,indid) desc
 
ROLLBACK