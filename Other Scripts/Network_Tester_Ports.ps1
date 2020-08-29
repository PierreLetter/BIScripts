#Edited by Pierre Letter based on the work of Pawel Janowicz @ https://www.powershellbros.com/

$Servers = Get-Content -Path "FOFTester_Sources.txt"
$DestinationServ = "server.domain"
$Array = @()
$Ports = Get-Content -Path "FOFTester_Ports.txt"
 
Foreach($Server in $Servers)
{
    $Obejct = $null
    $FQDN = $null
    $Server = $Server.Trim()
 
    Write-Host Processing $Server -ForegroundColor Green
     
    #Check FQDN for remote computer 
    $FQDN = ([System.Net.Dns]::GetHostByName(("$Server")))
 
    If(!$FQDN)
    {
        Write-Host "$Server does not exist"
    }
    Else
    {
        # Create a custom object 
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -Name "Source name" -Value $server
        $Object | Add-Member -MemberType NoteProperty -Name "Destination name" -Value $DestinationServ
 
        Foreach($Port in $Ports)
        {
            $Test = $null
            Try
            {
                $Test = Invoke-Command  -ComputerName $Server -ErrorAction Stop -ScriptBlock{param($Port,$DestinationServ) Test-netconnection -Port $Port -cn $DestinationServ -InformationLevel Quiet } -ArgumentList $Port,$DestinationServ
                If($Test)
                {
                    $Object | Add-Member -MemberType NoteProperty -Name "$Port" -Value $Test
                }
            }
            Catch
            {
                Write-Warning $_.Exception.Message
                $Object | Add-Member -MemberType NoteProperty -Name "$Port" -Value "null"
            }
        }
        $Array += $Object  
 
    }
}
Write-Host "Results:" -Foreground Yellow
$Array | Format-Table -Wrap -AutoSize
$Array | Export-Csv -Path FOFTest.csv -NoTypeInformation