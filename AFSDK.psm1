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
    # From an AF Database or from an AF Server (use parameter sets), retrieve an array of EventFrames that are open.
}

function Stop-EventFrames {
    # Set the current time as the end time for a list of AF EventFrames.
}

function Get-PiVisionDisplayAfAttributes {}

function Get-PiPointProperties {}

function Convert-ObjectsToPsCustomObjects{
    # Generically converts Objects to PSCustom Objects to enable use with PowerShell functions like Export-Csv and Out-Gridview.
}

