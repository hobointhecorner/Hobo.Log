function Merge-LogPref
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [hashtable]$NewPref,

        [parameter(Mandatory)]
        [hashtable]$Pref
    )

    process
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

    end
    {
        return $Pref
    }
}

function Write-LogTee
{
    [cmdletbinding()]
    param(
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
