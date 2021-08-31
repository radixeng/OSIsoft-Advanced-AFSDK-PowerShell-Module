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
    $PiPoints = $InputAfAttributes.PIPoint.Where({$_ -ne $null})
    return [OSIsoft.AF.PI.PIPoint[]]$PiPoints
}

function Get-AllAfAnalyses {
    # Returns an IEnumerable of all AF Analyses from an AF Database or AF Server
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ParameterSetName="PiSystem")]
        [OSIsoft.AF.PISystem]
        $PiSystem,

        [Parameter(Mandatory, ParameterSetName="AfDatabase")]
        [OSIsoft.AF.AFDatabase]
        $AfDatabase
    )

    switch ($PSCmdlet.ParameterSetName) {
        PiSystem {
            $AfDatabases = $PiSystem.Databases
            Write-Debug "Finding AFAnalyses in $($AfDatabases.Count) AF Databases on $($PiSystem.Name)"
            $SearchResultsPerAfDatabase = [System.Collections.ArrayList]::new()
            foreach ($AfDatabase in $AfDatabases)
            {
                $AfDatabaseSearchResults = Get-AllAfAnalyses -AfDatabase $AfDatabase
                if ($AfDatabaseSearchResults.Count -gt 0)
                {
                    $SearchResultsPerAfDatabase.Add([OSIsoft.AF.Analysis.AFAnalysis[]]$AfDatabaseSearchResults) |Out-Null
                }
            }
            # Flatten list of lists.
            $SearchResults = $SearchResultsPerAfDatabase | ForEach-Object { $_ }
            return $SearchResults
        }
        AfDatabase {
            $Search = [OSIsoft.AF.Search.AFAnalysisSearch]::new($AfDatabase, "AfAnalysisSearch", "name:*")
            $Search.CacheTimeout = [TimeSpan]::FromMinutes(10)
            Write-Debug "$($Search.GetTotalCount()) AFAnalyses found."
            $SearchResults = $Search.FindObjects()
            return [OSIsoft.AF.Analysis.AFAnalysis[]]$SearchResults
        }
    }
}

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

