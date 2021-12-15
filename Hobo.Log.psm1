function Merge-LogPref
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [hashtable]$Pref,

        [hashtable]$NewPref = @{}
    )

    process
    {
        if ($NewPref.Keys)
        {
            foreach ($key in $NewPref.Keys)
            {
                if ($Pref.ContainsKey($key))
                {
                    $Pref[$key] = $NewPref[$key]
                }
                else
                {
                    $Pref.Add($key, $NewPref[$key])
                }
            }
        }
    }

    end
    {
        return $Pref
    }
}

<#

.SYNOPSIS
This is a Powershell cmdlet to write output to the console, a log file, or the Windows Event Log with one command.

.DESCRIPTION
This cmdlet allows a user to write output to the console using their preferred output pipeline, as well as write the output to a file log and the Windows Event Log at the same time with one command.

.PARAMETER Message
The message to be logged

.PARAMETER LogType
The event type of the log entry being written.  (INFO, WARN, ERROR)

.PARAMETER LogOutputPipeline
Choose to write to alternative pipelines (OUTPUT, INFO)

.PARAMETER LogOutputRaw
Writes a string to console output instead of a LogOutput object

.PARAMETER LogFile
Enables writing to the file log.

.PARAMETER LogFilePref
A hashtable of parameters to be sent to the Write-LogFile command.

.PARAMETER LogFileRaw
Writes a string to file output instead of a LogOutput object

.PARAMETER LogEvent
Enables writing to the Windows Event Log.

.PARAMETER LogEventPref
A hashtable of parameters to be sent to the Write-LogEvent command.

#>

function Write-LogTee
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$LogType = 'INFO',
        [hashtable]$LogOutputPref = @{},
        [ValidateSet('OUTPUT', 'INFO')]
        [string]$LogOutputPipeline = 'OUTPUT',
        [switch]$LogOutputRaw,

        [switch]$LogFile,
        [hashtable]$LogFilePref = @{},
        [switch]$LogFileRaw,

        [switch]$LogEvent,
        [hashtable]$LogEventPref = @{}
    )

    begin
    {
        if ($LogOutputPipeline -ieq 'info')
        {
            $LogOutputRaw = $true
        }

        $LogOutputPref = Merge-LogPref -NewPref $LogOutputPrefs -Pref @{
            LogType = $LogType
        }

        $LogEventPref = Merge-LogPref -NewPref $LogEventPref -Pref @{
            LogType = $LogType
        }
    }

    process
    {
        $outputObject = Write-LogOutput @LogOutputPref -Message $Message

        if ($LogFile)
        {
            if ($LogFileRaw)
            {
                Write-LogFile @LogFilePref -InputObject $outputObject.ToRaw()
            }
            else
            {
                Write-LogFile @LogFilePref -InputObject $outputObject
            }
        }

        if ($LogEvent)
        {
            Write-LogEvent @LogEventPref -Message $outputObject.ToRaw()
        }

        if ($LogOutputRaw)
        {
            $outputObject = $outputObject.ToRaw()
        }

        switch ($LogOutputPipeline)
        {
            'OUTPUT' { Write-Output $outputObject }
            'INFO' { Write-Information $outputObject }
        }
    }
}
