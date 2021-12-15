# Hobo.Log.File
Write to a file-based log

### Write-LogFile
```
NAME
    Write-LogFile

SYNOPSIS
    Export object(s) to a file-based log.


SYNTAX
    Write-LogFile [-InputObject] <Object> [-Directory] <String> [-Name] <String> [[-Format] <String>] [[-MaxLengthBytes] <Int32>] [[-MaxTime] <TimeSpan>] [-RollOver] [[-MaxLogs] <Int32>] [-PassThru] [<CommonParameters>]


DESCRIPTION
    This script is a tool to facilitate easy file-based logging to various formats, with controls to allow for multiple kinds of log management and automatic rollover.


PARAMETERS
    -InputObject <Object>
        The object to be added to the log

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Directory <String>
        Path to the directory the log will be stored in.  Defaults to the directory the script is run from.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Name <String>
        The filename of the log.  Defaults to "log"

        Required?                    true
        Position?                    3
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Format <String>
        Defines the format of the log.  Can be txt, csv, json, or xml.

        Required?                    false
        Position?                    4
        Default value                txt
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -MaxLengthBytes <Int32>
        Maximum log size before the log is overwritten or rolled over.  Accepts kb/mb/gb notation.  Defaults to 25mb.

        Required?                    false
        Position?                    5
        Default value                5242880
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -MaxTime <TimeSpan>
        Maximum amount of time that a log is allowed to be written to before overwritten or rolled over.

        Required?                    false
        Position?                    6
        Default value                ([timespan]::MaxValue)
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -RollOver [<SwitchParameter>]
        Tells the script to append a date code once the defined threshold from MaxLengthBytes, MaxLogEntries, or MaxTime is reached. It will then begin a new log file.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -MaxLogs <Int32>
        Maximum number of rolled over logs to keep at any time

        Required?                    false
        Position?                    7
        Default value                100
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Writes object to console output as well as logging to file.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).
```
