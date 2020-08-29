CREATE VIEW [dbo].[v_BlitzResults]
AS

SELECT ISNULL(Alias, BlitzResults.[ServerName]) as Alias
      ,[Priority]
      ,[FindingsGroup]
      ,[Finding]
      ,[DatabaseName]
      ,[URL]
      ,[Details]
      ,[QueryPlan]
      ,[QueryPlanFiltered]
      ,[CheckID]
	  ,[CheckDate]
	  ,[BlitzResults].[ServerName]
  FROM [BlitzResults]
  LEFT OUTER JOIN BlitzServerMapping ON BlitzServerMapping.[ServerName] = [BlitzResults].[ServerName]
  WHERE DATEDIFF(d,Checkdate,GETDATE()) < 1
  AND Priority > 0
  AND (
	Priority < 200
	OR Finding = 'Data Size'
	OR Finding Like 'Drive % Space'
	)