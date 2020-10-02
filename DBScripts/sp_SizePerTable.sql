USE Master
GO

IF OBJECT_ID('dbo.sp_SizePerTable') IS NULL
  EXEC ('CREATE PROCEDURE dbo.sp_SizePerTable AS RETURN 0;');
GO

ALTER PROCEDURE [dbo].[sp_SizePerTable]
AS

    SELECT 
        t.Name AS TableName,
        s.Name AS SchemaName,
        MAX(p.partition_number) AS PartitionCount,
		FORMAT(c.ColumnCounts,'N0') AS ColumnCount,
        FORMAT(SUM(p.rows),'N0') AS [RowCount],
        FORMAT(CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)),'N0') AS TotalSpaceMB,
        FORMAT(CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)),'N0') AS UsedSpaceMB, 
        FORMAT(CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)),'N0') AS UnusedSpaceMB
    FROM 
        sys.tables t
	INNER JOIN 
        sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN
		(SELECT Count(*) AS ColumnCounts, TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS
		GROUP BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME) c ON c.TABLE_CATALOG = db_name() AND c.TABLE_SCHEMA = s.Name AND c.TABLE_NAME = t.Name
	 INNER JOIN      
        sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
        sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
    INNER JOIN 
        sys.allocation_units a ON p.partition_id = a.container_id
    WHERE 
        t.NAME NOT LIKE 'dt%' 
        AND t.is_ms_shipped = 0
        AND i.OBJECT_ID > 255 
    GROUP BY 
        t.Name, s.Name, c.ColumnCounts
    ORDER BY
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) Desc

RETURN
GO

EXEC sp_ms_marksystemobject sp_SizePerTable
GO