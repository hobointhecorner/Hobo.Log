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
