# Hobo.Log.Output

Write to the console

## Write-LogOutput
```
NAME
    Write-LogOutput

SYNOPSIS
    Write well-formatted output to the console


SYNTAX
    Write-LogOutput [<CommonParameters>]

    Write-LogOutput -Message <String> [-LogType <String>] [-AdditionalFields <Hashtable>] [-Raw] [<CommonParameters>]

    Write-LogOutput -InputObject <LogOutput[]> [-LogType <String>] [-AdditionalFields <Hashtable>] [-Raw] [<CommonParameters>]


DESCRIPTION
    This cmdlet allows a user to write a well-formatted output object to the console using their preferred output pipeline


PARAMETERS
    -Message <String>
        The string message to log to the console

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -InputObject <LogOutput[]>
        A LogOutput object to be written to the console

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false

    -LogType <String>
        The type of message being written (INFO, WARN, ERROR)

        Required?                    false
        Position?                    named
        Default value                INFO
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -AdditionalFields <Hashtable>
        Any fields + values to be added to the output object

        Required?                    false
        Position?                    named
        Default value                @{}
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Raw [<SwitchParameter>]
        Output as a raw string instead of a LogOutput object

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
