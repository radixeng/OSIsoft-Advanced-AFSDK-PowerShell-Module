# For currently running AF EventFrames that have lasted beyond a certain time period, set the current datetime as the endtime.
# Before committing these changes, back up these AFEventFrames to a csv (in their running state).

using assembly osisoft.AFSDK

Import-Module ".\AFSDK.psm1"

$afserver = [OSIsoft.AF.PISystems]::new()["GRD001P-APP029"]

# $AFdatabases = $Afserver.databases | where-object {$_.database -eq "PI System Health Monitoring (Radix)"}
# $Afserver.databases[0].GetType()
$AFdatabases = [OSIsoft.AF.AFDatabase[]]($Afserver.databases | where-object {
    $_.Name -like "PI System Health Monitoring (Radix)" # "PI System Health Monitoring (Radix)"
})
$afeventframeslist = [System.Collections.ArrayList]::new()

for ($i = 0; $i -lt 1; $i++) {
    [osisoft.af.Time.AFTime]$time = "*-14d"
    $afeventframe = [OSIsoft.AF.EventFrame.AFEventFrame]::new($AFdatabases, "EventFrameTestRPG_$i")
    $afeventframe.SetStartTime($time)
    $afeventframe.CheckIn()
    $afeventframeslist.add($afeventframe)|Out-Null
}

$searchtokens = [System.Collections.ArrayList]::new()

$searchtokens.add([Osisoft.AF.Search.AFSearchToken]::new(
    [osisoft.af.search.AFSearchFilter]::Name,
    [osisoft.af.search.AFSearchOperator]::Equal,
    "EventFrameTestRPG_*"
))
$searchtokens.add([Osisoft.AF.Search.AFSearchToken]::new(
    [osisoft.af.search.AFSearchFilter]::InProgress,
    [osisoft.af.search.AFSearchOperator]::Equal,
    $true
))

foreach($afDatabase in $afDatabases) {
    $AFEventFrameSearch = [osisoft.af.search.AFEventFrameSearch]::new($AFdatabase,"EventFrameSearch_Test", $searchtokens)
    
    $count = $AFEventFrameSearch.gettotalCount()
    Write-Host "Found $count event frames"
    [OSIsoft.AF.EventFrame.AFEventFrame[]]$AFEventFrameResults = $Afeventframesearch.findObjects(0,$true,500)
    
    $AFEvenFrameResults[]
    # $AFEventFrameResults.Gettype()
    
    # foreach($AfEventFrame in $AfeventframeResults){
    #     [OSIsoft.AF.EventFrame.AFEventFrame]$Afeventframe.setendTime("*")
    #     $afeventframe.CheckIn()
    # }
    
    Stop-AfEventFrames -afeventframes $AFEventFrameResults
    
    # $afeventframes_stopped = Stop-AfEventFrames -afeventframes $AFEventFrameResults
    
    # $afeventframes_stopped.checkin()
    
    
    $AFEventFrameSearch = [osisoft.af.search.AFEventFrameSearch]::new($AFdatabase,"EventFrameSearch_Test", $searchtokens)
    
    $count = $AFEventFrameSearch.gettotalCount()
    
    Write-Host "After finishing the Stop-AFeventFrame Function I found $count event frames"
}

$afdb = $afdatabases[0]
$afeventframeslist[0].Database.CheckIn()
$afDb.Refresh()