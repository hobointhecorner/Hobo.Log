# Hobo.Log

A collection of logging tools for powershell

**[Hobo.Log.Event](modules/Hobo.Log.Event/README.md)**: Write to the Windows Event Log

**[Hobo.Log.File](modules/Hobo.Log.File/README.md)**: Write to a file-based log

**[Hobo.Log.Output](modules/Hobo.Log.Output/README.md)**: Write output to the console with standardized formatting

## Write-LogTee
```
NAME
    Write-LogTee

SYNOPSIS
    This is a Powershell cmdlet to write output to the console, a log file, or the Windows Event Log with one command.


SYNTAX
    Write-LogTee [-Message] <String> [[-LogType] <String>] [[-LogOutputPref] <Hashtable>] [[-LogOutputPipeline] <String>] [-LogOutputRaw] [-LogFile] [[-LogFilePref] <Hashtable>] [-LogFileRaw] [-LogEvent] [[-LogEventPref] <Hashtable>] [<CommonParameters>]


DESCRIPTION
    This cmdlet allows a user to write output to the console using their preferred output pipeline, as well as write the output to a file log and the Windows Event Log at the same time with one command.


PARAMETERS
    -Message <String>
        The message to be logged

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogType <String>
        The event type of the log entry being written.  (INFO, WARN, ERROR)

        Required?                    false
        Position?                    2
        Default value                INFO
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogOutputPref <Hashtable>

        Required?                    false
        Position?                    3
        Default value                @{}
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogOutputPipeline <String>
        Choose to write to alternative pipelines (OUTPUT, INFO)

        Required?                    false
        Position?                    4
        Default value                OUTPUT
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogOutputRaw [<SwitchParameter>]
        Writes a string to console output instead of a LogOutput object

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogFile [<SwitchParameter>]
        Enables writing to the file log.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogFilePref <Hashtable>
        A hashtable of parameters to be sent to the Write-LogFile command.

        Required?                    false
        Position?                    5
        Default value                @{}
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogFileRaw [<SwitchParameter>]
        Writes a string to file output instead of a LogOutput object

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogEvent [<SwitchParameter>]
        Enables writing to the Windows Event Log.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogEventPref <Hashtable>
        A hashtable of parameters to be sent to the Write-LogEvent command.

        Required?                    false
        Position?                    6
        Default value                @{}
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).
```
