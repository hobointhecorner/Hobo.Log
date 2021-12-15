function Import-LogFile
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Format
    )

    process
    {
        if (Test-Path $Path)
        {
            switch ($Format)
            {
                'txt' { Get-Content $Path }
                'csv' { Import-Csv -Path $Path }
                'json' { Get-Content -Path $Path | ConvertFrom-Json }
                'clixml' { Import-Clixml -Path $Path }
            }
        }
    }
}

function Export-LogFile
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        $Content,
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Format
    )

    process
    {
        switch ($Format)
        {
            'txt' { Add-Content -Path $Path -Value $Content }
            'csv' { $Content | Export-Csv -Path $Path -Force -Confirm:$false }
            'json' { $Content | ConvertTo-Json | Set-Content -Path $Path -Force -Confirm:$false }
            'clixml' { $Content | Export-Clixml -Path $Path -Force -Confirm:$false }
        }
    }
}

function Get-LogFileMessage
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        $InputObject
    )

    process
    {
        if ($InputObject)
        {
            switch ($InputObject.GetType().FullName.ToLower())
            {
                'system.string' { return $InputObject }
                'system.object[]'
                {
                    return ($InputObject | ConvertTo-Json -Compress) -replace ',', ', '
                }
                'system.collections.hashtable'
                {
                    $messageKey = $InputObject.Keys | Where-Object { $_ -ieq 'message' }
                    if ($messageKey -and $InputObject.ContainsKey($messageKey))
                    {
                        return $InputObject[$messageKey]
                    }
                    else
                    {
                        return ($InputObject | ConvertTo-Json -Compress) -replace ":", ': ' -replace ',', ', '
                    }
                }
                default
                {
                    $objectProps = $InputObject |
                                    Get-Member |
                                        Where-Object { $_.MemberType -ieq 'property' } |
                                        Select-Object -ExpandProperty Name

                    if ('message' -iin $objectProps)
                    {
                        return $InputObject.Message
                    }
                    else
                    {
                        return ([string]$InputObject)
                    }
                }
            }
        }
    }
}

function Limit-LogFile
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        $Directory,
        [parameter(Mandatory = $true)]
        $Name,
        [parameter(Mandatory = $true)]
        $Format,

        [int]$MaxLengthBytes,
        [timespan]$MaxTime,

        [switch]$RollOver,
        [ValidateNotNullOrEmpty()]
        [int]$MaxLogs
    )

    begin
    {
        $logExpired = $false
        $filePath = Join-Path $Directory "$Name.$Format"
    }

    process
    {
        if (Test-Path $filePath)
        {
            $logInfo = Get-Item $filePath
            if ($MaxLengthBytes)
            {
                if ($logInfo.Length -ge $MaxLengthBytes)
                {
                    $logExpired = $true
                }
            }

            if ($MaxTime)
            {
                $timeSinceCreation = New-TimeSpan $logInfo.CreationTime (Get-Date)
                if ($timeSinceCreation -ge $MaxTime)
                {
                    $logExpired = $true
                }
            }

            if ($logExpired)
            {
                if ($RollOver)
                {
                    # Rename current log
                    $rolloverName = "$Name-$(Get-Date -Format yyyyMMdd_HHmmss).$Format"
                    Rename-Item -LiteralPath $filePath -NewName $rolloverName

                    # Verify max number of logs not reached
                    $logFiles = Get-ChildItem $Directory | Where-Object { $_.Name -match "$Name-\d{8}_\d{6}.$Format" }
                    $logCount = $logFiles | Measure-Object | Select-Object -ExpandProperty Count

                    if ($logCount -gt $MaxLogs)
                    {
                        # Delete oldest log(s)
                        $deleteCount = $logCount - $MaxLogs
                        $logFiles |
                            Sort-Object CreationTime  |
                            Select-Object -First $deleteCount |
                            ForEach-Object { Remove-Item $_.FullName -Force -Confirm:$false }
                    }
                }
                else
                {
                    # Remove current log
                    Remove-Item $filePath -Force -Confirm:$false
                }
            }
        }
    }
}

<#

.SYNOPSIS
Export object(s) to a file-based log.

.DESCRIPTION
This script is a tool to facilitate easy file-based logging to various formats, with controls to allow for multiple kinds of log management and automatic rollover.

.PARAMETER InputObject
The object to be added to the log

.PARAMETER Name
The filename of the log.  Defaults to "log"

.PARAMETER Directory
Path to the directory the log will be stored in.  Defaults to the directory the script is run from.

.PARAMETER Format
Defines the format of the log.  Can be txt, csv, json, or xml.

.PARAMETER MaxLengthBytes
Maximum log size before the log is overwritten or rolled over.  Accepts kb/mb/gb notation.  Defaults to 25mb.

.PARAMETER MaxTime
Maximum amount of time that a log is allowed to be written to before overwritten or rolled over.

.PARAMETER Rollover
Tells the script to append a date code once the defined threshold from MaxLengthBytes, MaxLogEntries, or MaxTime is reached. It will then begin a new log file.

.PARAMETER MaxLogs
Maximum number of rolled over logs to keep at any time

.PARAMETER PassThru
Writes object to console output as well as logging to file.

#>

function Write-LogFile
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        $InputObject,

        [parameter(Mandatory = $true)]
        [string]$Directory,
        [parameter(Mandatory = $true)]
        [string]$Name,
        [ValidateSet('txt', 'csv', 'json', 'clixml')]
        [string]$Format = 'txt',

        [int]$MaxLengthBytes = 5mb,
        [timespan]$MaxTime = ([timespan]::MaxValue),

        [switch]$RollOver,
        [ValidateNotNullOrEmpty()]
        [int]$MaxLogs = 100,

        [switch]$PassThru
    )

    begin
    {
        $filePath = Join-Path $Directory "$Name.$Format"

        Limit-LogFile -Directory $Directory -Name $Name -Format $Format `
            -MaxLengthBytes $MaxLengthBytes -MaxTime $MaxTime `
            -Rollover:$Rollover -MaxLogs $MaxLogs

        if (!(Test-Path $Directory))
        {
            New-Item $Directory -ItemType Directory -Force | Out-Null
        }
    }

    process
    {
        if ($Format -eq 'txt')
        {
            $newContent = Get-LogFileMessage $InputObject
        }
        elseif ($Format -in 'csv', 'json', 'clixml')
        {
            $content = Import-LogFile -Path $filePath -Format $Format

            $newContent = @()
            $content | ForEach-Object { $newContent += $_ }
            $newContent += $InputObject
        }

        Export-LogFile -Content $newContent -Path $filePath -Format $Format
    }

    end
    {
        if ($PassThru)
        {
            return $InputObject
        }
    }
}
