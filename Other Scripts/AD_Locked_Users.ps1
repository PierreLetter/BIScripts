#Setup arrays
    $LockedUsers = @()
    $SourceEvents = @()
 
    #Searches for the domain controller with the role of a PDC emulator.
    $PDCServer = (Get-AdDomain).PDCEmulator
 
    #=======================================================================
    #Checking locked users
    Search-ADAccount -LockedOut | Select-Object -first 10 | ForEach-Object{
        $Object = New-Object PSObject -Property ([ordered]@{ 
            Name         = $_.name
            Locked       = $_.lockedout
            UPN          = $_.UserPrincipalName        
        })
        $LockedUsers += $Object
    }
    "Currently locked users:"
    $LockedUsers | Format-Table -AutoSize -Wrap
    $Users =  $LockedUsers.Name
 
    #=======================================================================
    #Checking lockout source
    Try{
        $SourceEvents = Foreach ($User in $Users){
            Invoke-Command -cn $PDCServer {param($User)
                $Object = @{}| Select-Object Username,TimeCreated,Source
                $Object.Username = $User
 
                #Search for first event ID 4740 in security log - source in the ‘Caller Computer Name’ column.
                $Events = Get-WinEvent -FilterHashtable @{LogName="Security";ID="4740"} | Where-Object {$_.message -match $User} | Select-Object -first 1
                If($Events){ 
                    $Object.Source = $Events.properties.value[1]
                    $Object.timecreated = $Events.timecreated
                }
                Else{ 
                    $Object.Source = " - "
                    $Object.timecreated = " - "
                }
                $Object
            } -ArgumentList $User -ErrorAction stop | Select-Object @{n='ServerName';e={$_.pscomputername}},Username,TimeCreated,Source
        }
    }
    Catch [System.Exception]{
        Write-host "Error" -backgroundcolor red -foregroundcolor yellow
        $_.Exception.Message
    }
    "Lockout source found in $PDCServer :"
    $SourceEvents | Format-Table -AutoSize -Wrap