class LogOutput
{
    [string]$Message
    [string]$Type
    [datetime]$DateTime

    LogOutput([string]$Message, [string]$Type)
    {
        $this.Message = $Message
        $this.Type = $Type
        $this.DateTime = Get-Date
    }

    LogOutput([string]$Message, [string]$Type, [datetime]$DateTime)
    {
        $this.Message = $Message
        $this.Type = $Type
        $this.DateTime = $DateTime
    }

    [string] GetDateString()
    {
        return (Get-Date $this.DateTime -Format 'yyyy-MM-dd HH:mm:ss')
    }

    [string] ToRaw()
    {
        return "$($this.GetDateString())  |  $($this.Type)  |  $($this.Message)"
    }
}


<#

.SYNOPSIS
Write well-formatted output to the console

.DESCRIPTION
This cmdlet allows a user to write a well-formatted output object to the console using their preferred output pipeline

.PARAMETER Message
The string message to log to the console

.PARAMETER InputObject
A LogOutput object to be written to the console

.PARAMETER LogType
The type of message being written (INFO, WARN, ERROR)

.PARAMETER AdditionalFields
Any fields + values to be added to the output object

.PARAMETER Raw
Output as a raw string instead of a LogOutput object

#>
function Write-LogOutput
{
    [cmdletbinding(DefaultParameterSetName = 'InputObject')]
    param(
        [parameter(Mandatory, ParameterSetName='message')]
        [string]$Message,

        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'inputObject')]
        [LogOutput[]]$InputObject,

        [parameter(ParameterSetName = 'message')]
        [parameter(ParameterSetName = 'inputObject')]
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$LogType = 'INFO',

        [parameter(ParameterSetName = 'message')]
        [parameter(ParameterSetName = 'inputObject')]
        [hashtable]$AdditionalFields = @{},

        [parameter(ParameterSetName = 'message')]
        [parameter(ParameterSetName = 'inputObject')]
        [switch]$Raw
    )

    begin
    {
        if ($Message)
        {
            $InputObject = @()
            $InputObject += [LogOutput]::New($Message, $LogType)
        }
    }

    process
    {
        foreach ($object in $InputObject)
        {
            if ($Raw)
            {
                $outputObject = $object.ToRaw()
            }
            else
            {
                $AdditionalFields.Keys | ForEach-Object {
                    Add-Member -InputObject $object -MemberType NoteProperty -Name $_ -Value $AdditionalFields[$_]
                }

                $outputObject = $object
            }

            Write-Output $outputObject
        }
    }
}
