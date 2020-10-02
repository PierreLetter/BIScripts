CREATE PROCEDURE [dbo].[sp_MailBlitzResults] @sendTo nvarchar(MAX)
AS

DECLARE @MAIL_BODY VARCHAR(MAX) = '';
DECLARE @IssueCount NUMERIC(12,0) = 0;
DECLARE @ReportDate NVARCHAR(30) = '';

/* Blitz Results Mail */
/* Show Report Date */
SELECT @ReportDate = CAST(CONVERT(DATE,MIN(CheckDate)) AS NVARCHAR(30))
FROM BlitzResults
WHERE DATEDIFF(d,CheckDate,GETDATE()) < 1;

SELECT @MAIL_BODY = @MAIL_BODY + '<P> Report date: <B>' + @ReportDate + '</B></P><P/>';

/* Get Number of issues*/
SELECT @IssueCount = COUNT(*)
FROM BlitzResults
WHERE DATEDIFF(d,CheckDate,GETDATE()) < 1
    AND Priority BETWEEN 1 AND 199

IF @IssueCount > 50
	BEGIN
		SELECT @MAIL_BODY = @MAIL_BODY + '<P>There are <B>' + cast(@IssueCount as nvarchar(10)) + '</B> issues with Priority < 200. This is the top 50.</P><P/>';
	END;
ELSE
	BEGIN
		SELECT @MAIL_BODY = @MAIL_BODY + '<P>There are <B>' + cast(@IssueCount as nvarchar(10)) + '</B> issues with Priority < 200.</P><P/>';
	END;

/* BlitzResults Table*/ 
/* HEADER */
SELECT @MAIL_BODY = @MAIL_BODY + '<table border="1" align="center" cellpadding="2" cellspacing="0" style="color:black;font-size:12px;font-family:consolas;text-align:center;">' +
    '<tr>
    <th>Alias</th>
    <th>Priority</th>
    <th>Finding</th>
    <th>DatabaseName</th>
    <th>Details</th>
    <th>Doc</th>
    </tr>';
 
/* ROWS */
SELECT TOP 50
    @MAIL_BODY = @MAIL_BODY +
        '<tr ' +
		CASE WHEN FindingsGroup = 'Backup' THEN 'bgcolor= "FFCDCD"' 
			 WHEN FindingsGroup IN ('Reliability','DBCC Events') THEN 'bgcolor= "FFEED4"'
             WHEN FindingsGroup = 'Performance' THEN 'bgcolor= "DADFFF"'
		END
        +'>' +
        '<td>' + Alias + '</td>' +
		'<td>' + CAST(Priority AS VARCHAR(11)) + '</td>' +
		'<td>' + Finding + '</td>' +
		'<td>' + ISNULL(DatabaseName,'') + '</td>' +
		'<td>' + Details + '</td>' +
		'<td>' + URL + '</td>' +
        '</tr>'
FROM BlitzResults
    LEFT OUTER JOIN BlitzServerMapping ON BlitzServerMapping.ServerName = [BlitzResults].ServerName
WHERE DATEDIFF(d,CheckDate,GETDATE()) < 1
    AND Priority BETWEEN 1 AND 199
ORDER BY
	Priority, Finding;
 
SELECT @MAIL_BODY = @MAIL_BODY + '</table>';
SELECT @MAIL_BODY = @MAIL_BODY + '<P/><P> There are <B>' + cast(COUNT(*) as nvarchar(10)) + '</B> performance and monitoring at Priority = 200.</P>'
FROM [BlitzResults]
  WHERE DATEDIFF(d,CheckDate,GETDATE()) < 1
  AND Priority = 200
  AND FindingsGroup IN ('Performance','Monitoring');

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Data Factory Default Profile',
    @recipients = @sendTo,
    @subject = 'Server Audit',
    @body = @MAIL_BODY,
    @body_format='HTML';

/* Disk Size Mail */
SET @MAIL_BODY = '';

/* Show Report Date */
SELECT @MAIL_BODY = @MAIL_BODY + '<P> Report date: <B>' + @ReportDate + '</B></P><P/>';

/*Size Table*/
/* HEADER */
SELECT @MAIL_BODY = @MAIL_BODY  + '<table border="1" align="center" cellpadding="1" cellspacing="1" style="color:black;font-size:14px;font-family:consolas;text-align:center;">' +
    '<tr>
    <th>Alias</th>
    <th>Finding</th>
    <th>Details</th>
	<th>CheckDate</th>
    <th>InstanceName</th>
    </tr>';
 
/* ROWS */
SELECT
    @MAIL_BODY = @MAIL_BODY +
        '<tr>' +
        '<td>' + Alias + '</td>' +
		'<td>' + Finding + '</td>' +
		'<td>' + Details + '</td>' +
        '<td>' + CAST(CONVERT(DATE,CheckDate) AS VARCHAR(30)) + '</td>' +
        '<td>' + BlitzResults.ServerName + '</td>' +
        '</tr>'
FROM
    BlitzResults
    INNER JOIN BlitzServerMapping ON BlitzServerMapping.ServerName = BlitzResults.ServerName
WHERE
	DATEDIFF(d,CheckDate,GETDATE()) < 1
    AND Priority = 250
	AND (Finding = 'Data Size' OR Finding Like 'Drive % Space');

SELECT @MAIL_BODY = @MAIL_BODY + '</table>';

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Data Factory Default Profile',
    @recipients = @sendTo,
    @subject = 'Server Disk Report',
    @body = @MAIL_BODY,
    @body_format='HTML';

GO