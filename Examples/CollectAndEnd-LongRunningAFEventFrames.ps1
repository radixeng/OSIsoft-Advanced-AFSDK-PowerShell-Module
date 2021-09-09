using Assembly OSIsoft.AFSDK

$Today = Get-Date -Format "yyyy-MM-dd"
$OutputFileDir = "..\..\..\Scripts"
$OutputFileName = "AnalysisDependencies_$PI_SYSTEM_NAME_$Today.csv"
$OutputFilePath = Join-Path $OutputFileDir $OutputFileName

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
        [OSIsoft.AF.PISystem]
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
        if($null -eq $Properties){
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



$afserver = [osisoft.af.pisystems]::new()["GRD001P-APP029"]

# $afdatabase = $afserver.databases |where-object {$_.name -eq "PI System Health Monitoring (Radix)"}

$AFOpenEventFrames = Get-OpenAfEventFrames -AfServer $afserver -LongerThan "14d"

$AfOpenEventFramesPS = Convert-ObjectsToPsCustomObjects $AfOpenEventFrames

# $afopeneventframesPS | Export-Csv -Path $OutputFilePath
[PSCustomObject[]]$AfOpenEventFramesPS | Out-GridView
