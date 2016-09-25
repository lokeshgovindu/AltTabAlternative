/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
(-----------------------------------------------------------------------------)
| About Dialog                         / A Script file for AutoHotkey 1.1.23+ |
|                                     ----------------------------------------|
|                                                                             |
o-----------------------------------------------------------------------------o
*/

; This is for my testing
;~ #Include VersionInfo.ahk
;~ If (true) {
	;~ ProductPage 	        := "http://alttabalternative.sourceforge.net/"
	;~ AuthorName 		        := "Lokesh Govindu"
	;~ AuthorPage 		        := "http://lokeshgovindu.blogspot.in/"
	;~ AutoHotkeyPage          := "https://autohotkey.com/"
;~ AboutDialogHtml =
;~ (
;~ <html>
;~ <body>
;~ <b style='mso-bidi-font-weight:normal'><span
;~ style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;
;~ mso-fareast-font-family:"Times New Roman";color:red'>This program is a free
;~ software.</span></b><span style='font-family:"Calibri",sans-serif;mso-fareast-font-family:
;~ "Times New Roman"'><br>
;~ <span class=SpellE><span style='color:#002060'>AltTabAlternative</span></span><span
;~ style='color:#002060'> is a small application created in <a
;~ href="https://autohotkey.com/"><span class=SpellE><span style='color:#002060'>AutoHotkey</span></span></a>,
;~ is an alternative for windows native task switcher (<span class=SpellE>Alt+Tab</span>
;~ / <span class=SpellE>Alt+Shift+Tab</span>).</span><br>
;~ <br>
;~ </span><span class=SpellE><b style='mso-bidi-font-weight:normal'><span
;~ style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;
;~ mso-fareast-font-family:"Times New Roman";color:#002060'>%ATAPRODUCTNAME%</span></b></span><b
;~ style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt;mso-bidi-font-size:
;~ 12.0pt;font-family:"Calibri",sans-serif;mso-fareast-font-family:"Times New Roman";
;~ color:#002060'><br>
;~ <span class=SpellE>FullVersion %ATAPRODUCTFULLVERSION%</span><br>
;~ %ATACOPYRIGHT%<o:p></o:p></span></b>
;~ <hr>
;~ <b style='mso-bidi-font-weight:normal'><span
;~ style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;
;~ mso-fareast-font-family:"Times New Roman";color:#C00000'>Thanks to God & everyone :-)</span></b>
;~ </body>
;~ </html>
;~ )
	
	;~ AboutDialog()
	;~ Return
	
	;~ Esc::
		;~ ExitApp
;~ }

AboutDialog()
{
	Global
	Gui, AboutDialog: New, , About %ATAPRODUCTNAME%
	Gui, Margin, 10, 10
	Gui, Font, s11
	Gui, Add, Link, hWndhAppSysLink vProgNameSysLink, <a href="%ProductPage%">%ATAPRODUCTNAME%</a> Version %ProductVersion%
	Gui, Add, Link, y+1 hWndhAuthorSysLink vAuthorSysLink, <a href="%AuthorPage%">%AuthorName%</a> (C) %ProductYear%
	Gui, Add, Text, y+9, About && Credits
	Gui, add, ActiveX, y+1 vHF w447 multi r9 +Border, HTMLFile
	HF.write(AboutDialogHtml)
	Gui, Font
	Gui, Add, Button, w75 gBtnOk vBtnOk +Default +Center, OK
	Gui, Show, AutoSize Center
	Return
	
	
AboutDialogGuiEscape:	
AboutDialogGuiClose:
BtnOk:
    Gui, AboutDialog:Hide

AboutDialogGuiSize:
	WinGetPos, X, Y, Width, Height, A
	MoveControlToHorizontalCenter("ProgNameSysLink", Width)
	MoveControlToHorizontalCenter("AuthorSysLink", Width)
	MoveControlToHorizontalCenter("BtnOk", Width)
	GuiControl, Focus, BtnOk
Return

; End of the GUI section

}

MoveControlToHorizontalCenter(CtrlvName, Width)
{
	GuiControlGet, CtrlPos, Pos, %CtrlvName%
	XPos := (Width - CtrlPosW) / 2
	GuiControl, Move, %CtrlvName%, x%XPos%
}
