<#------------------------------------------------------------------------------
    Jason McClary
    mcclarj@mail.amc.edu
    22 June 2016
    
    Description:
    Check Log files for push status
    
    Arguments:
    If blank script runs against local computer
    Multiple computer names can be passed as a list separated by spaces:
        ServerBootTimes.ps1 computer1 computer2 anotherComputer
    A text file with a list of computer names can also be passed
        ServerBootTimes.ps1 comp.txt
        
    Tasks:
    - Create a file that lists Computer name 

        
--------------------------------------------------------------------------------
                                CONSTANTS
------------------------------------------------------------------------------#>
#Date/ Time Stamp - http://ss64.com/bash/date.html#format
$dtStamp = $(Get-Date -UFormat "%Y%b%d") + "_" + $(Get-Date -UFormat "%H") + "-" + $(Get-Date -UFormat "%M")

set-variable logOutput -option Constant -value "PS360Logs_$dtStamp.txt"

set-variable logToCheck -option Constant -value "\c$\AMC_Install_Logs\PS360\PS360_v31_Install.log"
#set-variable logToCheck -option Constant -value "\c$\AMC_Install_Logs\PS360\PS360_Install.log"

set-variable logSuccessText -option Constant -value "==== INSTALL PASSED CHECKS ==== "

<#------------------------------------------------------------------------------
                                FUNCTIONS
------------------------------------------------------------------------------#>
function Write-Color([String[]]$Text, [ConsoleColor[]]$Color = "White", [int]$StartTab = 0, [int] $LinesBefore = 0,[int] $LinesAfter = 0) {
    $DefaultColor = $Color[0]
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host "`t" -NoNewLine } }  # Add TABS before text
    if ($Color.Count -ge $Text.Count) {
        for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine } 
    } else {
        for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
        for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
    }
    Write-Host
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host "`n" } }  # Add empty line after
} # copied from http://stackoverflow.com/questions/2688547/muliple-foreground-colors-in-powershell-in-one-command
    
<#------------------------------------------------------------------------------
                                    MAIN
------------------------------------------------------------------------------#>

## Format arguments from none, list or text file 
IF (!$args){
    $compNames = $env:computername # No arguments passed, get the local computer name
} ELSE {
    $passFile = Test-Path $args  # Was a text file passed?

    IF ($passFile -eq $True) {
        $compNames = get-content $args #load text file to array
    } ELSE {
        $compNames = $args # add individul computer names to array
    }
}


FOREACH ($compName in $compNames) {
    IF(Test-Connection -count 1 -quiet $compName){ # Check if computer is online
        $pathToLog = "\\$compName$logToCheck"

        IF (Test-Path $pathToLog) {
            $lastLine = Get-Content -Path $pathToLog | Select-Object -last 1
            IF ([string]::IsNullOrEmpty($lastLine)) {$lastLine = "++++ Log File is present but empty ++++"} # If log file is empty fill variable with something other than null
            # ONLY Write in green if INSTALL PASSED CHECKS
            IF ($lastLine.EndsWith("$logSuccessText")){
                write-host "$compName    $lastLine" -foregroundcolor "Green" 
            } ELSE {
                #Write-Color "$compName    ", "$lastLine" -Color Green,Gray
                Write-Host "$compName    $lastLine" -foregroundcolor "Yellow"
            }
            
             
        } ELSE {
             write-host "$compName    **** Log File Not Found ****" -foregroundcolor "Gray"
        }
        # Colors found at https://technet.microsoft.com/en-us/library/ff406264.aspx
    } ELSE {
        write-host "$compName    **** Could not connect  ****" -foregroundcolor "Red"
    }

}