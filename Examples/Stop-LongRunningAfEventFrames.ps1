# For currently running AF EventFrames that have lasted beyond a certain time period, set the current datetime as the endtime.
# Before committing these changes, back up these AFEventFrames to a csv (in their running state).

using assembly osisoft.AFSDK

function Get-OpenAFEventFrames {
    <#
    From an AF Database or from an AF Server (use parameter sets), retrieve an array of EventFrames that are open.
    Mandatory Parameter: AFServerName - Specifies what AF Server to search.
    Optional Paramaters:
        -inputRange specifies time range in PI acceptable time formats (ex: "14d") default is set to 2 weeks.
        -databaseName specifies a certain database within AFServerName parameter if you only want to search one database.
    #> 

    Param(
        [Parameter(Mandatory=$true, ParameterSetName='AfServer')]
        [OSIsoft.AF.PISystem] #turn into [osisoft.af.pisystems]
        $AfServer,
       
        [Parameter(mandatory=$true, ParameterSetName='AfDatabase')]
        [OSIsoft.AF.AFDatabase]
        $AfDatabase,

        [Parameter(Mandatory=$false)]
        [string]
        $LongerThan
    )
    switch ($PSCmdlet.ParameterSetName)
    {
        'AfServer' {
            $AfServerEfs = [System.Collections.Generic.List[OSIsoft.AF.EventFrame.AFEventFrame]]::new()
            foreach($AfDatabase in $AfServer.Databases)
            {
                $AfDatabaseEfs = Get-OpenAFEventFrames -afDatabase $AfDatabase -LongerThan $LongerThan
                for ($i=0; $i -lt $AfDatabaseEFs.Count; $i++)
                {
                    $AfServerEFs.Add($AFDatabaseEfs[$i]) | Out-Null
                }
            }
            return [OSIsoft.AF.EventFrame.AFEventFrame[]]$AfServerEfs
        }
        'AfDatabase' {
            
            $searchTokens = [System.Collections.Generic.List[OSIsoft.AF.Search.AFSearchToken]]::new()
            #Add search tokens to list
            if ($LongerThan)
            {
                $searchTokens.Add([OSIsoft.AF.Search.AFSearchToken]::new(
                    [OSIsoft.AF.Search.AFSearchFilter]::Start,
                    [OSIsoft.AF.Search.AFSearchOperator]::GreaterThan,
                    [OSIsoft.AF.Time.AFTime]::new("*-$LongerThan")
                )) | Out-Null
            }

            $searchTokens.Add([OSIsoft.AF.Search.AFSearchToken]::new(
                [OSIsoft.AF.Search.AFSearchFilter]::InProgress,
                [OSIsoft.AF.Search.AFSearchOperator]::Equal,
                $true
            )) | Out-Null

            [OSIsoft.AF.Search.AFEventFrameSearch]$AFEventFrameSearch = [OSIsoft.AF.Search.AFEventFrameSearch]::new($afDatabase, "EventFrameSearch", [System.Collections.Generic.List[OSIsoft.AF.Search.AFSearchToken]]$searchTokens)
            $count = $AFEventFrameSearch.GetTotalCount()
            Write-Host "$count EF's found in $afdatabase."

            $AFEventFrames = [Linq.Enumerable]::ToArray(
                $AFEventFrameSearch.FindObjects(0, $true, 500)
            )
            return [OSIsoft.AF.EventFrame.AFEventFrame[]]$AfEventFrames

        }
    
    }
}

function Stop-AfEventFrames {
    Param(
        [Parameter(Mandatory=$true)]
        [OSIsoft.AF.EventFrame.AFEventFrame[]]
        $AFEventFrames,

        [Parameter(Mandatory=$false)]
        [string]
        $LogFilePath
        # TODO: Find a way to validate the log file path to make sure it is a valid one.
        # Can incorporate own log function if available.
    )
   
    for ($i = 0; $i -lt $AFEventFrames.Count; $i++) {
        # $afeventframes[$i].CheckOut()
        [osisoft.af.eventframe.AFeventframe]$AFEventFrames[$i].undocheckout($true)
        [OSIsoft.AF.EventFrame.AFEventFrame]$Afeventframes[$i].setendTime("*")
        $afeventframes[$i].CheckIn() 
    }
}

$afserver = [OSIsoft.AF.PISystems]::new()["GRD001P-APP029"]

# $AFdatabases = [osisoft.af.afdatabase[]]($Afserver.databases | where-object {$_.Name -like "PI System Health Monitoring (Radix)"})
# $Afserver.databases[0].GetType()
$AFdatabases = [OSIsoft.AF.AFDatabase[]]$Afserver.databases

foreach($afDatabase in $afDatabases) {
    $AFOpenEventFrames = Get-OpenAfEventFrames -AfDatabase $afDatabase -LongerThan "14d"

    Stop-AfEventFrames -afeventframes $AfOpenEventFrames
}
