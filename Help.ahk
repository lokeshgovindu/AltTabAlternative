/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
(-----------------------------------------------------------------------------)
| Help                                 / A Script file for AutoHotkey 1.1.23+ |
|                                     ----------------------------------------|
|                                                                             |
o-----------------------------------------------------------------------------o
*/

; This is for my testing
;~ if (true) {
	;~ HelpFileName := "Help.mht"
	;~ HelpFilePath := A_ScriptDir . "\" . HelpFileName
	;~ #Include %A_ScriptDir%\CommonUtils.ahk

	;~ ShowHelp()
	;~ Return

	;~ Esc::
		;~ ExitApp
;~ }

ShowHelp()
{
	Global
    HelpWindowMinWidth  := 800
    HelpWindowMinHeight := 600
    HelpWindowWidth     := 1024
    HelpWindowHeight    := 768
    HelpFilePath        := A_ScriptDir . "\" . HelpFileName

	FileRead, FileContents, %HelpFilePath%
    if (ErrorLevel) {
        MsgBox, , Error, File not found: %HelpFilePath%
        Return
    }

    Gui, Help: New, +Resize +hwndhHelpWindow MinSize%HelpWindowMinWidth%x%HelpWindowMinHeight%, %HelpFilePath%
    Gui, Help: Font, s11, Lucida Console
    Gui, Help: Default
    Gui, Help: Margin, 0, 0
	Gui, Help: Add, ActiveX, w%HelpWindowWidth% h%HelpWindowHeight% vShellExpolorer Multi +Border, Shell.Explorer
	ShellExpolorer.Navigate(HelpFilePath)
	ShellExpolorer.silent := true

    Gui, Help: Show, AutoSize Center
	ControlSend, , ^{Home}, ahk_id %hHelpWindow%
	Return

	HelpGuiEscape:
	HelpGuiClose:
		Gui, Help: Destroy
	Return

	HelpGuiSize:
		If (A_EventInfo = 1) ; The window has been minimized.
			Return
		AutoXYWH("wh", "ShellExpolorer")
	Return
} ; ShowHelp ends here!
