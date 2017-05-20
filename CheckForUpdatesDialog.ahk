/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
o-----------------------------------------------------------------------------o
*/

#Include %A_ScriptDir%\CommonUtils.ahk

; This is for my testing
;~ ProgramName                 := "AltTabAlternative"
;~ If (true) {
    ;~ ShowNoUpdatesMsgBox     := true
	;~ ProductPage 	        := "https://alttabalternative.sourceforge.io/"
	;~ ATALatestVersionFile	:= "E:\Installers\AltTabAlternative\version.txt"
	;~ ProductVersion			:= "16.3.0.1"
	;~ ProductVersion			:= "17.0.0.1"
	;~ latestVersion			:= "17.0.0.1"
    ;~ ProductLatestURL        := "https://sourceforge.net/projects/alttabalternative/files/latest/download"
    ;~ ProductLatestURL        := "https://sourceforge.net/projects/sevenzip/files/latest/download"
	;~ PrintKV("ATALatestVersionFile", ATALatestVersionFile)
    ;~ ShowCheckForUpdatesDialog(ProductVersion, ATALatestVersionFile, ShowNoUpdatesMsgBox)
    ;~ Return
	
    ;~ Esc::
        ;~ ExitApp
;~ }


ShowCheckForUpdatesDialog(ProductVersion, ATALatestVersionFile, ShowNoUpdatesMsgBox)
{
	Global
    FileRead, temp, %ATALatestVersionFile%
    Loop, parse, temp, `n, `r
    {
        if (A_index = 1) {
            latestVersion := A_LoopField
        } else if (A_Index = 2) {
            ATAInstallerName := A_LoopField
        } else {
            latestVersionChanges .= A_LoopField "`n"
        }
    }
	
    ;~ PrintKV("ProductVersion", ProductVersion)
    ;~ PrintKV(" latestVersion", latestVersion)
    PrintKV("ATAInstallerName", ATAInstallerName)
    
    if (!IsLatestRelease(ProductVersion, latestVersion)) {
        if (ShowNoUpdatesMsgBox) {
            MsgBox, 64, %ProgramName%, You are using the latest version of %ProgramName%`nVersion: %ProductVersion%
        }
        Return
    }
    
	latestVersionChanges := Trim(latestVersionChanges, " `t`n")
	Gui, UpdatesDialog: New, +hwndhUpdatesDialog, %ProgramName% Update Available
    Gui, Margin, 5, 5
	
	Gui, Font, s11, Lucida Console
	VersionLabelOffsetX := 240
	VersionNumberOffsetX := VersionLabelOffsetX + 150
	Gui, Add, Text, xm+%VersionLabelOffsetX%, `  Your Version :
	Gui, Add, Text, xm+%VersionNumberOffsetX% yp cGreen, %ProductVersion%
	Gui, Add, Text, xm+%VersionLabelOffsetX% yp+17, Latest Version :
	Gui, Add, Text, xm+%VersionNumberOffsetX% yp cBlue, %latestVersion%
	
	Gui, Font, s11 cBlue, Lucida Console
	Gui, Add, Text, xm y+12 vUDChangesText cRed, Changes:
	Gui, Add, Edit, xm w750 +ReadOnly, %latestVersionChanges%
	Gui, Font

	Gui, Add, Button, xm  w100 vUDOkBtn gUDOkBtnHandler hwndhUDOkBtn +Default, &Close
	Gui, Add, Button, x+3 w100 vUDBrowseBtn gUDBrowseHandler hwndhUDBrowseBtn, &Browse
	Gui, Add, Button, x+3 w100 vUDDownloadBtn gUDDownloadHandler hwndhUDDownloadBtn, &Download
	
    Gui, Show, AutoSize Center
    Return

; -----------------------------------------------------------------------------
; ToolTip cannot be displayed if the static text control doesn't have a gHandler.
; So, adding DoNothing event handler for static text controls to display tooltip
; information.
; -----------------------------------------------------------------------------
DoNothingHandler:
Return

; -----------------------------------------------------------------------------
; UpdatesDialog GuiSize
; -----------------------------------------------------------------------------
UpdatesDialogGuiSize:
    PrintSub("UpdatesDialogGuiSize")
    PrintKV2("A_GuiWidth", A_GuiWidth, "A_GuiHeight", A_GuiHeight)
    WinGetPos, X, Y, Width, Height, A
    MoveControlsToHorizontalCenter("UDOkBtn|UDBrowseBtn|UDDownloadBtn", A_GuiWidth)
    ;~ AutoXYWH("w", "StorageEdit")
    ;~ GuiControl, Move, GeneralGroupBox, w531
    ControlFocus, , ahk_id %hUDOkBtn%
Return

UDBrowseHandler:
	Run, %ProductPage%
Return


; -----------------------------------------------------------------------------
; Ok Btn Handler
; -----------------------------------------------------------------------------
UpdatesDialogGuiEscape:
UpdatesDialogGuiClose:
UDOkBtnHandler:
    PrintSub("UDOkBtnHandler")
    Gui, UpdatesDialog:Destroy
Return


; -----------------------------------------------------------------------------
; Download latest AltTabAlternative
; -----------------------------------------------------------------------------
UDDownloadHandler:
    Gui, +OwnDialogs
    FileSelectFile, ATAInstallerPath, S, %A_ScriptDir%\%ATAInstallerName%, All Files (*.*)
    if (ATAInstallerPath != "") {
        MouseGetPos, xpos, ypos
        Tooltip, Downloading`, please wait..., xpos, ypos, 1
        hCurs := DllCall("LoadCursor", "UInt", NULL, "Int", 32514, "UInt") ;IDC_WAIT
        DllCall("SetCursor", "UInt", hCurs)
        URLDownloadToFile, %ProductLatestURL%, %ATAInstallerPath%
        DllCall("DestroyCursor","Uint",hCurs)
        Tooltip
    }
Return

}


; -----------------------------------------------------------------------------
; Check for updates
; ProgramVersion : Current version of the running application
; CurrentVersion : Latest version available on net
; Returns:
;    True - if ProgramVersion > CurrentVersion
;   False - otherwise
; -----------------------------------------------------------------------------
IsLatestRelease(programVersion, currentVersion) {
	StringSplit, programVersionArray, programVersion, `.
	StringSplit, currentVersionArray, currentVersion, `.

	Loop % currentVersionArray0 - programVersionArray0
    {
		var := programVersionArray0 + A_index, programVersionArray%var% := 0
    }

	Loop % currentVersionArray0
    {
		if (programVersionArray%A_index% <= currentVersionArray%A_index%) {
			return false
        }
		else if (programVersionArray%A_index% > currentVersionArray%A_index%) {
            ; in case currentVersion supplied is of old file
			return true
        }
    }
	return true
}
