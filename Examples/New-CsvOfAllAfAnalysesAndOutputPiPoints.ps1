using Assembly OSIsoft.AFSDK

Import-Module ".\AFSDK.psm1"

$PI_SYSTEM_NAME = "PI_SYSTEM_NAME"
$OUTPUT_FILE_PATH = ".\$PI_SYSTEM_NAME AfAnalysesWithOutputPiPoints $(Get-Date -Format "yyyy-MM-dd").csv"

$PiSystem = [OSIsoft.AF.PISystem]::CreatePISystem($PI_SYSTEM_NAME)

$AfAnalyses = Get-AllAfAnalyses -PiSystem $PiSystem

$TableRows = [Collections.Generic.List[PSCustomObject]]::new()

foreach ($AfAnalysis in $AfAnalyses) {
    Write-Host "Finding PI Points for $($AfAnalysis.Name)"
    $PiPoints = $AfAnalysis | Get-AfAnalysesOutputPiPoints
    foreach ($PiPoint in $PiPoints)
    {
        $RowData = [Collections.Specialized.OrderedDictionary]::new()
        try {
            $RowData.Add("AFAnalysisPath", $AfAnalysis.GetPath())
            $RowData.Add("OutputPIPointPath", $PiPoint.GetPath())
        } catch {
            Write-Host "Whoops"
        }
        $TableRows.Add([PSCustomObject]$RowData)
    }
}

$TableRows | Export-CSV $OUTPUT_FILE_PATH -NoTypeInformation
$TableRows | Out-GridView
