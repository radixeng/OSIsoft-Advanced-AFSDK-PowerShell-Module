# Check to ensure OSIsoft's AFSDK is loaded.
if (
    ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {$_.GetName().Name -eq "OSIsoft.AFSDK"}).Count -ne 1
) {
    throw "OSIsoft.AFSDK assembly not found." # TODO: Make this a missing assembly reference.
}
[OSIsoft.AF.AF]

[Regex]::Match("OSIsoft.AFSDK", "OSIsoft.AFSDK").Success
"OSIsoft.AFSDK" -eq "OSIsoft.AFSDk"
function Get-AfAnalysisInputPiPoints {
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
    return [OSIsoft.AF.PI.PIPoints]$PiPoints
}

function Get-AfAnalysisOutputPiPoints {
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
    return [OSIsoft.AF.PI.PIPoints]$PiPoints
}

function Get-AllAfAnalysesFromAfServer {}

function Get-OpenAFEventFrames {}

function Get-PiVisionDisplayAfAttributes {}

function Get-PiPointProperties {}
