using Assembly OSIsoft.AFSDK

Import-Module ".\AFSDK.psm1"

# TODO: Get all Analyses

$AfAnalysis = [OSIsoft.AF.AFObject]::FindObject("\\GRD001P-APP029\PI System Health Monitoring (Radix)\Test\Analyses[Analysis2]")

[OSIsoft.AF.Analysis.AFAnalysis[]]$AFAnalysis | Get-AfAnalysesInputPiPoints