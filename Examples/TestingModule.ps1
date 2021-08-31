using assembly osisoft.AFSDK

Import-Module "C:\Users\Owner\Scripts\github\osisoft-advanced-afsdk-powershell-module\AFSDK.psm1"

#  $AfAnalyses = [OSIsoft.AF.AFObject]::FindObject("\\GRD001P-APP029\PI System Health Monitoring (Radix)\Test\Analyses[Analysis2]")

#  [OSIsoft.AF.Analysis.AFAnalysis[]]$AfAnalysisPoints = $AfAnalyses | Get-AfAnalysesInputPiPoints 
[OSIsoft.AF.Analysis.AFAnalysis[]]$AfAnalysisPoints = Get-AfAnalysesInputPiPoints -AfServerName "GRD001P-APP029" -afdatabasename "PI System Health Monitoring (Radix)" -afelementname "Test" -afanalysisname "Analysis2"


write-host $AfAnalysisPoints


# $PiPoints = [System.Collections.ArrayList] @("Happy", "Funny", "Sad", "Silly", "Obnoxious", "Happy")

# $uniquePiPoints = [System.Collections.ArrayList]@()
# foreach ($pipoint in $AfAnalysisPoints) {
#     if($uniquePiPoints -notcontains $pipoint){
#         $uniquePiPoints.add($PiPoint)
#     }
# }