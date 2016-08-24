/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
(-----------------------------------------------------------------------------)
| Release Notes                        / A Script file for AutoHotkey 1.1.23+ |
|                                     ----------------------------------------|
|                                                                             |
o-----------------------------------------------------------------------------o
*/

ShowReleaseNotes()
{
	Global
	; -----------------------------------------------------------------------------
	; Display Release Notes dialog
	; -----------------------------------------------------------------------------
	RNWindowMinWidth  := 800
	RNWindowMinHeight := 600
	RNWindowWidth     := 1024
	RNWindowHeight    := 768
	RNFilePath        := A_ScriptDir . "\" . ReleaseNotesFileName

	FileRead, FileContents, %RNFilePath%
	if (ErrorLevel) {
		MsgBox, , Error, File not found: %RNFilePath%
		Return
	}

	Gui, RN: New, +Resize +hwndhRNWindow MinSize%RNWindowMinWidth%x%RNWindowMinHeight%, %RNFilePath%
	Gui, RN: Font, s11, Lucida Console
	Gui, RN: Default
	Gui, RN: Margin, 0, 0
	Gui, RN: Add, Edit, w%RNWindowWidth% h%RNWindowHeight% -Wrap Multi HScroll VScroll vRNEditVar hwndhRNEdit +ReadOnly, %FileContents%

	Gui, RN: Show, AutoSize Center
	ControlSend, , ^{Home}, ahk_id %hRNWindow%
	Return

	RNGuiEscape:
	RNGuiClose:
		Gui, RN: Destroy

	RNGuiSize:
		If (A_EventInfo = 1) ; The window has been minimized.
			Return
		AutoXYWH("wh", "RNEditVar")
	Return
} ; ShowReleaseNotes ends here!
