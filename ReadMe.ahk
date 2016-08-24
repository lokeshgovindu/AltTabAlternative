/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
(-----------------------------------------------------------------------------)
| ReadMe                               / A Script file for AutoHotkey 1.1.23+ |
|                                     ----------------------------------------|
|                                                                             |
o-----------------------------------------------------------------------------o
*/

ShowReadMe()
{
	Global
    ReadMeWindowMinWidth  := 800
    ReadMeWindowMinHeight := 600
    ReadMeWindowWidth     := 1024
    ReadMeWindowHeight    := 768
    ReadMeFilePath        := A_ScriptDir . "\" . ReadMeFileName

	FileRead, FileContents, %ReadMeFilePath%
    if (ErrorLevel) {
        MsgBox, , Error, File not found: %ReadMeFilePath%
        Return
    }

    Gui, ReadMe: New, +Resize +hwndhReadMeWindow MinSize%ReadMeWindowMinWidth%x%ReadMeWindowMinHeight%, %ReadMeFilePath%
    Gui, ReadMe: Font, s11, Lucida Console
    Gui, ReadMe: Default
    Gui, ReadMe: Margin, 0, 0
    Gui, ReadMe: Add, Edit, w%ReadMeWindowWidth% h%ReadMeWindowHeight% -Wrap Multi HScroll VScroll vReadMeEditVar hwndhReadMeEdit +ReadOnly, %FileContents%

    Gui, ReadMe: Show, AutoSize Center
	ControlSend, , ^{Home}, ahk_id %hReadMeWindow%
	Return

	ReadMeGuiEscape:
	ReadMeGuiClose:
		Gui, ReadMe: Destroy

	ReadMeGuiSize:
		If (A_EventInfo = 1) ; The window has been minimized.
			Return
		AutoXYWH("wh", "ReadMeEditVar")
	Return
} ; ShowReadMe ends here!
