<#
.SYNOPSIS
	Installation OneDrive Machine-Wide-Install
	
	FileName:    OneDrive-Machine-Wide-installer.ps1
    Author:      Mark Messink
    Contact:     
    Created:     2021-09-20
    Updated:     2023-02-02

    Version history:
    1.0.0 - (2021-09-20) Initial Script
	1.0.1 - (21-12-2022) Script verniewd
	1.1.0 - 

.DESCRIPTION
	Download en installeer OneDrive Machine Wide

.PARAMETER
	<beschrijf de parameters die eventueel aan het script gekoppeld moeten worden>

.INPUTS


.OUTPUTS
	logfiles:
	PSlog_<naam>	Log gegenereerd door een powershell script
	INlog_<naam>	Log gegenereerd door Intune (Win32)
	AIlog_<naam>	Log gegenereerd door de installer van een applicatie bij de installatie van een applicatie
	ADlog_<naam>	Log gegenereerd door de installer van een applicatie bij de de-installatie van een applicatie
	Een datum en tijd wordt automatisch toegevoegd

.EXAMPLE
	./scriptnaam.ps1

.LINK Information
	https://docs.microsoft.com/en-us/onedrive/per-machine-installation
	https://support.microsoft.com/en-us/office/onedrive-release-notes-845dcf18-f921-435e-bf28-4e24b95e5fc0

.LINK Downloads
	https://go.microsoft.com/fwlink/?linkid=860984 #Rolling out - Production ring
	https://go.microsoft.com/fwlink/?linkid=860988 #Rolling out - Deferred ring
	https://go.microsoft.com/fwlink/?linkid=844652 #Last release Build - Production ring
	https://go.microsoft.com/fwlink/?linkid=860987 #Last release Build - Deferred ring

.NOTES
	WindowsBuild:
	Het script wordt uitgevoerd tussen de builds LowestWindowsBuild en HighestWindowsBuild
	LowestWindowsBuild = 0 en HighestWindowsBuild 50000 zijn alle Windows 10/11 versies
	LowestWindowsBuild = 19000 en HighestWindowsBuild 19999 zijn alle Windows 10 versies
	LowestWindowsBuild = 22000 en HighestWindowsBuild 22999 zijn alle Windows 11 versies
	Zie: https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information

#>

#################### Variabelen #####################################
$logpath = "C:\IntuneLogs"
$NameLogfile = "PSlog_OneDrive-Machine-Wide-installer.txt"
$LowestWindowsBuild = 0
$HighestWindowsBuild = 50000



#################### Einde Variabelen ###############################


#################### Start base script ##############################
### Niet aanpassen!!!

# Prevent terminating script on error.
$ErrorActionPreference = 'Continue'

# Create logpath (if not exist)
If(!(test-path $logpath))
{
      New-Item -ItemType Directory -Force -Path $logpath
}

# Add date + time to Logfile
$TimeStamp = "{0:yyyyMMdd-HHmm}" -f (get-date)
$logFile = "$logpath\" + "$TimeStamp" + "_" + "$NameLogfile"

# Start Transcript logging
Start-Transcript $logFile -Append -Force

# Start script timer
$scripttimer = [system.diagnostics.stopwatch]::StartNew()

# Controle Windows Build
$WindowsBuild = [System.Environment]::OSVersion.Version.Build
Write-Output "------------------------------------"
Write-Output "Windows Build: $WindowsBuild"
Write-Output "------------------------------------"
If ($WindowsBuild -ge $LowestWindowsBuild -And $WindowsBuild -le $HighestWindowsBuild)
{
#################### Start base script ################################

#################### Start uitvoeren script code ####################
Write-Output "-------------------------------------------------------------------------------------"
Write-Output "### Start uitvoeren script code ###"
Write-Output "-------------------------------------------------------------------------------------"

	$ExeFile = (Join-Path -Path ${env:ProgramFiles} -ChildPath "Microsoft OneDrive\OneDrive.exe")
	$ExeFile
	
	if (-not(Test-Path -Path "$ExeFile" -PathType Leaf)) {
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Download OneDrive from Microsoft"
		$downloadLocation = "https://go.microsoft.com/fwlink/?linkid=860984"
		$downloadDestination = "$($env:TEMP)\OneDriveSetup.exe"
		$webClient = New-Object System.Net.WebClient
		$webClient.DownloadFile($downloadLocation, $downloadDestination)
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Version OneDrive Download"
		(Get-Item $downloadDestination).VersionInfo | FL Productname, FileName, Productversion
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Install OneDrive Machine-Wide"
		$installProcess = Start-Process $downloadDestination -ArgumentList "/allusers" -NoNewWindow -PassThru
		$installProcess.WaitForExit()
		} else {
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Per machine OneDrive already exists. Installation skipped"
	}
		
	if (Test-Path -Path "$ExeFile" -PathType Leaf) {
	Write-Output "-------------------------------------------------------------------"
	Write-Output "OneDrive version information:"
	(Get-Item $ExeFile).VersionInfo | FL Productname, FileName, Productversion
	Write-Output "-------------------------------------------------------------------"
	} else {
		Write-Output "-------------------------------------------------------------------"
		Write-Output "File not found. Per machine installation failed"
		Write-Output "-------------------------------------------------------------------"
	}

Write-Output "-------------------------------------------------------------------------------------"
Write-Output "### Einde uitvoeren script code ###"
Write-Output "-------------------------------------------------------------------------------------"
#################### Einde uitvoeren script code ####################

#################### End base script #######################

# Controle Windows Build
}Else {
Write-Output "-------------------------------------------------------------------------------------"
Write-Output "### Windows Build versie voldoet niet, de script code is niet uitgevoerd. ###"
Write-Output "-------------------------------------------------------------------------------------"
}

#Stop and display script timer
$scripttimer.Stop()
Write-Output "------------------------------------"
Write-Output "Script elapsed time in seconds:"
$scripttimer.elapsed.totalseconds
Write-Output "------------------------------------"

#Stop Logging
Stop-Transcript
#################### End base script ################################

#################### Einde Script ###################################
