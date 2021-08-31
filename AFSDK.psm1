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
    #Create PI System instance using input AFservername
    $AfServer = [OSIsoft.AF.PISystems]::new()[$AfServerName]
    #Create empty list of databases
    $Afdatabases = [System.Collections.ArrayList]@()
    #Set default time range to 14d if user does not provide an argument
    if($inputRange -eq $null){
        $inputRange = "14d"
    }
    #Set default databases to "all" if user does not provide an argument
    if($databaseName -ne $null){
        $Afdatabases = $databaseName
    }
    else{
        $Afdatabases = $Afserver.Databases
    }

    foreach($AfDatabase in $Afdatabases) {
        #Create empty list of search tokens
        $searchTokens = [System.Collections.ArrayList]@()
        #Add search tokens to list
        $searchTokens.Add([OSIsoft.AF.Search.AFSearchToken]::new(
        [OSIsoft.AF.Search.AFSearchFilter]::Start,
        [OSIsoft.AF.Search.AFSearchOperator]::GreaterThan,
        [OSIsoft.AF.Time.AFTime]::new(-$inputRange)
        )) | Out-Null
        #Search all eventframes for using searchtokens
        [OSIsoft.AF.Search.AFEventFrameSearch]$AFEventFrameSearch = [OSIsoft.AF.Search.AFEventFrameSearch]::new($afDatabase, "EventFrameSearch", [OSIsoft.AF.Search.AFSearchToken[]]$searchTokens)
        $count = $AFEventFrameSearch.GetTotalCount()
        #output number of Event Frames found for sanity check
        Write-Host "$count EF's found."
        #Pull all eventframe objects in batches of 500
        $AFEventFrames = $AFEventFrameSearch.FindObjects(0, $true, 500)
        #Return list of EventFrame Objects
        return [OSIsoft.AF.EventFrame.AFEventFrame[]]$AFEventFrames
        
    }

function Stop-EventFrames {
    # Set the current time as the end time for a list of AF EventFrames.
}

function Get-PiVisionDisplayAfAttributes {}

function Get-PiPointProperties {}

function Convert-ObjectsToPsCustomObjects{
    <# 
    Generically converts Objects to PSCustom Objects to enable use with PowerShell functions like Export-Csv and Out-Gridview.
    Mandatory Parameter:
        -ObjectArray is the array of AFEventFrameObjects user wants to convert.
    Optional Parameters:
        -Properties is a user defined list of properties from the AFEventFrameObject that will be output. Default value is set to all.
    #>
    Param(
         [Parameter(ValueFromPipeline)]
         [Object[]]
         $ObjectArray,

         [Parameter(Mandatory=$False)]
         [String[]]
         $Properties
     )
    #Create empty list of PSCustomObjects
    $PSCustomObjects = [Collections.Generic.List[PSCustomObject]]::new()
    #Iterate through each Object in user-provided ObjectArray and populate fields with values.
    #Default fields are set to "All" if user does not provide a list of properties
     foreach ($object in $objectarray){
        #Creates an Ordered Dictionary for each object to preserve the order  
        $ObjDict = [Collections.Specialized.OrderedDictionary]::new()
        $defaultpropertyList = $object.PSObject.Properties.Name
        if($Properties -eq $null){
            foreach($property in $defaultpropertyList){
                $ObjDict.Add($property, $object.$property)
            }
            #Casts Ordered Dictionary into a PSCustomObject and adds it to a list of PSCustomObjects
            $PSCustomObjects.Add([PSCustomObject]$ObjDict)
        }
        else {
            #Same steps, but for when user provides list of properties as argument.
            foreach($property in $Properties){
                $ObjDict.Add($property, $object.$property)         
            }
            $PSCustomObjects.Add([PSCustomObject]$ObjDict)
        }
    }
 
 
     return $PSCustomObjects
}

