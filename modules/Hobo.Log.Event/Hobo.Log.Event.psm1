$isEnabled = $true
$disabledLogSources = @()

if ($IsLinux)
{
    Write-Warning "Disabling event logging: platform is Non-Windows"
    $isEnabled = $false
}

function Test-LogEventPrivileges
{
    [cmdletbinding()]
    param()

    process
    {
        return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }
}

function Test-LogEventSource
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$LogSource
    )

    process
    {
        return ([System.Diagnostics.EventLog]::SourceExists($LogSource))
    }
}

function Test-LogEventSourceEnabled
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$LogSource
    )

    process
    {
        $LogSource -inotin $disabledLogSources
    }
}

<#

.SYNOPSIS
Create a new log source in the Windows Event Log.

.DESCRIPTION
This is a Powershell cmdlet to create a new log source in the Windows Event Log.  This command requires the user have administrative privileges.

.PARAMETER LogName
The name of the log to create the source in.  Will create a new log with the defined name if one does not already exist.

.PARAMETER LogSource
The name of the log source to create.

.PARAMETER Force
This will remove the log source if it already exists before creating it.  This does NOT bypass administrative privilege checks.

#>
function New-LogEventSource
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$LogName,
        [parameter(Mandatory = $true)]
        [string]$LogSource,
        [switch]$Force
    )

    begin
    {
        if (!$isEnabled) { return }

        $removeSource = $false
        $createSource = $true
        $hasPrivileges = Test-LogEventPrivileges

        if (!$hasPrivileges)
        {
            Write-Warning "Disabling event logging for source $LogSource`: Admin privileges required to create log source"
            $hasPrivileges = $false
            $disabledLogSources += $LogSource
        }
    }

    process
    {
        if ($hasPrivileges)
        {
            if (Test-LogEventSource $LogSource)
            {
                if ($Force)
                {
                    $removeSource = $true
                }
                else
                {
                    $createSource = $false
                }
            }

            if ($removeSource)
            {
                Write-Verbose "Removing log source $LogSource"
                Remove-EventLog -Source $LogSource
            }

            if ($createSource)
            {
                Write-Verbose "Creating log source $LogSource in log $LogName"
                New-EventLog -LogName $LogName -Source $LogSource
            }
        }
    }
}


<#

.SYNOPSIS
Write messages to the Windows Event Log.

.DESCRIPTION
This is a Powershell cmdlet to write messages to the Windows Event Log. It will automatically attempt to create the defined event log and source if they do not already exist.

.PARAMETER Message
The message to be written to the log

.PARAMETER LogName
The name of the event log to be written to.  Defaults to the Application log.

.PARAMETER LogSource
The name of the log source to be written from.  This will create the source in the event viewer if the user has administrative privileges.

.PARAMETER LogType
The event type of the log entry being written.  (INFO, WARN, ERROR)

.PARAMETER EventId
The ID number of the event being written.  Defaults to 0.

.PARAMETER Force
Bypasses administrative privilege and log source existence checks and attempts to write to the defined event log and source.

.PARAMETER PassThru
Writes object to console output as well

#>
function Write-LogEvent
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$Message,

        [parameter(Mandatory = $true)]
        [string]$LogSource,

        [string]$LogName = 'Application',
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$LogType = 'INFO',
        [string]$EventId = 0,

        [switch]$PassThru
    )

    begin
    {
        if (!$isEnabled -or !(Test-LogSourceEnabled $LogSource)) { return }

        if (!(Test-LogEventSource $LogSource))
        {
            New-LogEventSource -LogName $LogName -LogSource $LogSource
        }

        switch ($LogType)
        {
            'WARN' { $logEntryType = [System.Diagnostics.EventLogEntryType]::Warning }
            'ERROR' { $logEntryType = [System.Diagnostics.EventLogEntryType]::Error }
            default { $logEntryType = [System.Diagnostics.EventLogEntryType]::Information }
        }
    }

    process
    {
        if (Test-LogEventSource $LogSource)
        {
            Write-EventLog -LogName $LogName -Source $LogSource `
                -EntryType $logEntryType -EventId $EventId `
                -Message $Message
        }
    }

    end
    {
        return $InputObject
    }
}
