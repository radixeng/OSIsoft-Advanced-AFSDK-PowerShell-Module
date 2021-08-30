# Check to ensure OSIsoft's AFSDK is loaded.
if (
    ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {$_.GetName().Name -eq "OSIsoft.AFSDK"}).Count -ne 1
) {
    throw "OSIsoft.AFSDK assembly not found." # TODO: Make this a missing assembly reference.
}

function Get-AfAnalysesInputPiPoints {
    # Returns a list of PI Points that act as inputs for a list of Analyses.
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [OSIsoft.AF.Analysis.AFAnalysis[]]
        $AfAnalyses
    )
    $InputAfAttributes = $AfAnalyses.AnalysisRule.GetConfiguration().GetInputs()
    # TODO: Ensure no duplicates are returned
    $PiPoints = $InputAfAttributes.PIPoint.Where({$_ -ne $null})
    return [OSIsoft.AF.PI.PIPoint[]]$PiPoints
}

function Get-AfAnalysesOutputPiPoints {
    # Returns a list of PI Points that receive data from a list of Analyses.
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [OSIsoft.AF.Analysis.AFAnalysis[]]
        $AfAnalyses
    )
    $InputAfAttributes = $AfAnalyses.AnalysisRule.GetConfiguration().GetOutputs()
    # TODO: Ensure no duplicate PI Points are returned
    $PiPoints = $InputAfAttributes.PIPoint.Where({$_ -ne $null})
    return [OSIsoft.AF.PI.PIPoint[]]$PiPoints
}

function Get-AllAfAnalysesFromAfServer {}

function Get-OpenAFEventFrames {
    <#
    From an AF Database or from an AF Server (use parameter sets), retrieve an array of EventFrames that are open.
    Mandatory Parameter: AFServerName - Specifies what AF Server to search.
    Optional Paramaters:
        -inputRange specifies time range in PI acceptable time formats (ex: "14d") default is set to 2 weeks.
        -databaseName specifies a certain database within AFServerName parameter if you only want to search one database.
    #> 

    Param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName)]
        [string]
        $AfServerName,

        [Parameter(Mandatory=$false)]
        [string]
        $inputRange,

        [Parameter(mandatory =$false)]
        [string]
        $databaseName
    )
    #find af database object using servername
    
    $AfServer = [OSIsoft.AF.PISystems]::new()[$AfServerName]
    
    #$AfDatabase = $AfServer.Databases["PI System Health Monitoring (Radix)"]
    $Afdatabases = [System.Collections.ArrayList]@()
    
    if($databaseName -ne $null){
        $Afdatabases = $databaseName
    }
    else{
        $Afdatabases = $Afserver.Databases
    }

    foreach($AfDatabase in $Afdatabases) {
                  
        $searchTokens = [System.Collections.ArrayList]@()

        $searchTokens.Add([OSIsoft.AF.Search.AFSearchToken]::new(
        [OSIsoft.AF.Search.AFSearchFilter]::Start,
        [OSIsoft.AF.Search.AFSearchOperator]::GreaterThan,
        [OSIsoft.AF.Time.AFTime]::new(-$inputRange)
        )) | Out-Null
        
        [OSIsoft.AF.Search.AFEventFrameSearch]$AFEventFrameSearch = [OSIsoft.AF.Search.AFEventFrameSearch]::new($afDatabase, "EventFrameSearch", [OSIsoft.AF.Search.AFSearchToken[]]$searchTokens)
        $count = $AFEventFrameSearch.GetTotalCount()

        Write-Host "$count EF's found."

        $AFEventFrames = $AFEventFrameSearch.FindObjects(0, $true, 500)

        return [OSIsoft.AF.EventFrame.AFEventFrame[]]$AFEventFrames
        
    }

function Stop-EventFrames {
    # Set the current time as the end time for a list of AF EventFrames.
}

function Get-PiVisionDisplayAfAttributes {}

function Get-PiPointProperties {}

function Convert-ObjectsToPsCustomObjects{
    # Generically converts Objects to PSCustom Objects to enable use with PowerShell functions like Export-Csv and Out-Gridview.
}

