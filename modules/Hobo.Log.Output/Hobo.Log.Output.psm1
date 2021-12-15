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
