<#
.Synopsis
    Upload PowerBI reports to PBiRS
.DESCRIPTION
    Upload PowerBI reports to PBiRS and optionally change the 1st data source connection string and credentials
.PARAMETER portalURL
    Specify the URL of the target portal
.PARAMETER sourceFolder
    Specify the folder in which the reports are stored
.PARAMETER targetFolder
    Specify the folder to push the reports in
.PARAMETER connectionString
    Specify the connection String (optional)
.PARAMETER login
    Specify the account to set for the connection
.PARAMETER password
    Specify the account password (SecureString)

    Author: Pierre LETTER on 2020-07-08
    Based on work found on https://www.blue-granite.com/blog/power-bi-report-server-devops
.EXAMPLE
   ./"PowerBI Backup.ps1" "https://servername.company/Reports" "C:\Temp\PBiReports" "/REPORTS/xxx/"
#>

Param(
  [parameter(Mandatory=$true)][String]$portalURL
  ,[parameter(Mandatory=$true)][String]$sourceFolder
  ,[parameter(Mandatory=$true)][String]$targetFolder
  ,[parameter(Mandatory=$false)][String]$connectionString = 'Keep'
  ,[parameter(Mandatory=$false)][String]$login
  ,[parameter(Mandatory=$false)][SecureString]$password
  )
Write-Host "Target portal: $portalURL"
Write-Host "Source Folder: $sourceFolder"
Write-Host "Target Folder: $targetFolder"
Write-Host "Data Source: $connectionString"
Write-Host "Service Account: $login"

#Create new web session to your Power BI Report portal
$session = New-RsRestSession -ReportPortalUri $portalURL;
$LocalPath = $sourceFolder;

#We use SSDT for deploying SSRS reports. Therefore, we're only using PowerShell for Power BI & Excel reports
#That said, there is nothing preventing you from deploying all report types via PowerShell. Simply remove the "Include" parameter below.

$reports = Get-ChildItem -Path $LocalPath -Recurse -Include "*.pbix";

#Loop through selected reports
ForEach ($report in $reports)
{
   #Deploy the report to the server
   Write-RsRestCatalogItem -Path $report.FullName -RsFolder "$targetFolder" -Overwrite -WebSession $session;
   #Change datasource if specified
  if ($connectionString -ne 'Keep') {
    $reportPath = $targetFolder + "/" + $report.BaseName
    $dataSources = Get-RsRestItemDataSource -RsItem "$reportPath" -WebSession $session
    $dataSources[0].ConnectionString = $connectionString
    $dataSources[0].DataModelDataSource.AuthType = 'Windows'
    $dataSources[0].DataModelDataSource.Username = $login
    $dataSources[0].DataModelDataSource.Secret = ConvertFrom-SecureString $password
    Set-RsRestItemDataSource -RsItem "$reportPath" -RsItemType "PowerBIReport" -DataSources $dataSources -WebSession $session
  } 
} 