# Hobo.Log.Event

Write to Windows Event Viewer logs

### Write-LogEvent
```
NAME
    Write-LogEvent

SYNOPSIS
    Write messages to the Windows Event Log.


SYNTAX
    Write-LogEvent [-Message] <String> [-LogSource] <String> [[-LogName] <String>] [[-LogType] <String>] [[-EventId] <String>] [-PassThru] [<CommonParameters>]


DESCRIPTION
    This is a Powershell cmdlet to write messages to the Windows Event Log. It will automatically attempt to create the defined event log and source if they do not already exist.


PARAMETERS
    -Message <String>
        The message to be written to the log

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogSource <String>
        The name of the log source to be written from.  This will create the source in the event viewer if the user has administrative privileges.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogName <String>
        The name of the event log to be written to.  Defaults to the Application log.

        Required?                    false
        Position?                    3
        Default value                Application
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogType <String>
        The event type of the log entry being written.  This can be Information, Warning, or Error.  Defaults to Information.

        Required?                    false
        Position?                    4
        Default value                INFO
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -EventId <String>
        The ID number of the event being written.  Defaults to 0.

        Required?                    false
        Position?                    5
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Writes object to console output as well

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

### New-LogEventSource
```
NAME
    New-LogEventSource

SYNOPSIS
    Create a new log source in the Windows Event Log.


SYNTAX
    New-LogEventSource [-LogName] <String> [-LogSource] <String> [-Force] [<CommonParameters>]


DESCRIPTION
    This is a Powershell cmdlet to create a new log source in the Windows Event Log.  This command requires the user have administrative privileges.


PARAMETERS
    -LogName <String>
        The name of the log to create the source in.  Will create a new log with the defined name if one does not already exist.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -LogSource <String>
        The name of the log source to create.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        This will remove the log source if it already exists before creating it.  This does NOT bypass administrative privilege checks.

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
