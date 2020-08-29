CREATE PROCEDURE [dbo].[sp_MailResults] @sendTo nvarchar(MAX)

AS

DECLARE @MAIL_BODY VARCHAR(MAX)
 
/* HEADER */
SET @MAIL_BODY = '<table border="1" align="center" cellpadding="2" cellspacing="0" style="color:black;font-family:consolas;text-align:center;">' +
    '<tr>
    <th>Alias</th>
    <th>Priority</th>
    <th>Finding</th>
    <th>DatabaseName</th>
    <th>Doc</th>
    <th>Details</th>
	<th>CheckDate</th>
	<th>InstanceName</th>
    </tr>'
 
/* ROWS */
SELECT
    @MAIL_BODY = @MAIL_BODY +
        '<tr>' +
        '<td>' + Alias + '</td>' +
		'<td>' + CAST(Priority AS VARCHAR(11)) + '</td>' +
		'<td>' + Finding + '</td>' +
		'<td>' + ISNULL(DatabaseName,'') + '</td>' +
		'<td>' + Details + '</td>' +
		'<td>' + URL + '</td>' +
        '<td>' + CAST(CONVERT(DATE,CheckDate) AS VARCHAR(30)) + '</td>' +
		'<td>' + ServerName + '</td>' +
        '</tr>'
FROM
    v_BlitzResults
ORDER BY
	Priority, Finding
 
SELECT @MAIL_BODY = @MAIL_BODY + '</table>'
 
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Data Factory Default Profile',
    @recipients = @sendTo,
    @subject = 'Daily Server Audit',
    @body = @MAIL_BODY,
    @body_format='HTML'
GO


