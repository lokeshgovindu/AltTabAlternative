/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
| Inspired from https://github.com/ralesi/alttab.ahk                          |
(-----------------------------------------------------------------------------)
| Alt+Tab Alternative                  / A Script file for AutoHotkey 1.1.23+ |
|                                     ----------------------------------------|
|                                                                             |
o-----------------------------------------------------------------------------o
*/

#SingleInstance Force
#InstallKeybdHook

#Include %A_ScriptDir%\VersionInfo.ahk
#Include %A_ScriptDir%\ATATooltips.ahk

SetWorkingDir, %A_ScriptDir%

; -----------------------------------------------------------------------------
; 
; -----------------------------------------------------------------------------
; Windows Messages

WM_KEYDOWN := 0x100
WM_KEYUP   := 0x101
WM_NOTIFY  := 0x004E

; -----------------------------------------------------------------------------
; Product Information 
; -----------------------------------------------------------------------------

ProductPage 	        := "https://alttabalternative.sourceforge.io/"
AuthorName 		        := "Lokesh Govindu"
AuthorPage 		        := "http://lokeshgovindu.blogspot.in/"
AuthorEMail             := "lokeshgovindu@gmail.com"
ProductLatestURL        := "https://sourceforge.net/projects/alttabalternative/files/latest/download"
UpdateFileURL           := "https://sourceforge.net/projects/alttabalternative/files/version.txt/download"
AboutDialogHtml =
(
<html>
<body>
<b style='mso-bidi-font-weight:normal'><span
style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;
mso-fareast-font-family:"Times New Roman";color:red'>This program is a free
software.</span></b><span style='font-family:"Calibri",sans-serif;mso-fareast-font-family:
"Times New Roman"'><br>
<span class=SpellE><span style='color:#002060'>AltTabAlternative</span></span><span
style='color:#002060'> is a small application created in <a
href="https://autohotkey.com/"><span class=SpellE><span style='color:#002060'>AutoHotkey</span></span></a>,
is an alternative for windows native task switcher (<span class=SpellE>Alt+Tab</span>
/ <span class=SpellE>Alt+Shift+Tab</span>).
It also supports Alt+Backtick / Alt+Shift+Backtick to switch between the windows of the same application.</span>
<br>
<br>
</span>
<span class=SpellE><b style='mso-bidi-font-weight:normal'><span
style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;
mso-fareast-font-family:"Times New Roman";color:#002060'>%ATAPRODUCTNAME%</span></b></span><b
style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt;mso-bidi-font-size:
12.0pt;font-family:"Calibri",sans-serif;mso-fareast-font-family:"Times New Roman";
color:#002060'><br>
<span class=SpellE>FullVersion %ATAPRODUCTFULLVERSION%</span><br>
%ATACOPYRIGHT%<o:p></o:p><br><a href="mailto:%AuthorEMail%?Subject=AltTabAlternative">
%AuthorEMail%</a></span></b>
<hr>
<b style='mso-bidi-font-weight:normal'>
<span style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;
mso-fareast-font-family:"Times New Roman";color:#C00000'>First thanks to God :-)</span></b>
<br><br>
<style>
table {border-spacing: 8px 2px;}
</style>
<table style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;color:#98B87E' cellspacing="0" cellpadding="0">
<tr style='color:#774620'><td align="right"><b><a href="https://github.com/ralesi">Rich Alesi</a>, <a href="https://github.com/studgeek">David Rees</a></b></td><td>: AltTab initial version</td><tr>
<tr style='color:#3D113B'><td align="right"><b><a href="https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=58">jballi</a></b></td><td>: For AddTooltip, Font Library v0.5</td><tr>
<tr style='color:#778E64'><td align="right"><b>kdoske</b></td><td>: For CSV Library</td><tr>
<tr style='color:#53A390'><td align="right"><b><a href="http://www.elegantthemes.com/">elegantthemes</a></b></td><td>: Icon design</td><tr>
<tr style='color:#4C4AA8'><td align="right"><b><a href="https://in.linkedin.com/in/madhu-sameena-05084b38">Madhu Sameena</a></b></td><td>: Suggestions & testing</td><tr>
<tr style='color:#7D3858'><td align="right"><b><a href="https://in.linkedin.com/in/satish-samayam-077a4a2b">Satish Samayam</a></b></td><td>: Suggestions & testing</td><tr>
</table>
<br>
<span style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Calibri",sans-serif;;color:#049308'><b>And Everyone !!!</b></span>
</body>
</html>
)

SettingsDirPath         := A_AppData . "\" . ProductName
SettingsINIFileName     := "AltTabAlternativeSettings.ini"
SettingsINIFilePath     := SettingsDirPath . "\" . SettingsINIFileName
CheckForUpdatesFileName := "CheckForUpdates.txt"
CheckForUpdatesFilePath := SettingsDirPath . "\" . CheckForUpdatesFileName
HiddenWindowsFileName   := "HiddenWindows.txt"
HiddenWindowsFilePath   := SettingsDirPath . "\" . "HiddenWindows.txt"
HiddenWindowsFile_ID    := "ATAHW"
HiddenWindowsFile_Cols  := 5

TrayIcon                := "AltTabAlternative.ico"
ApplicationName         := ProductName
ProgramName             := ApplicationName
ReadMeFileName          := "ReadMe.txt"
HelpFileName            := "Help.mht"
ReleaseNotesFileName    := "ReleaseNotes.txt"


; -----------------------------------------------------------------------------
; ::Global Variables and their help
;
; ********* HiddenWindowList *********
; Do NOT worry about the deletion of windows from the HiddenWindowList,
;   GetWindowsCount function will take care of it. Window info will be deleted
;   if any hidden window doesn't exist.
;
;
; ********* Settings variables *********
; All Settings are defined/read/write in SettingsDialog.ahk file
;
;
; ********* HotkeysDisabled *********
; This variable is used to disable/enable AltTabAlternative application.
;
;
; ********* ATACSHotkeysDisabled *********
; ATA ContextSensitive hotkeys are ON when the ATA window is visible.
; Use these keys to hide/unhide, display hidden windows in listview.
;
;
; ********* IsAltBacktick *********
; Alt+Backtick is used to display the processes of same type.
; IsAltBacktick is true when Alt+Backtick is pressed.
;
;
; ********* ATACS *********
; AltTabAlternative ContextSensitive Keys
;
;
; ********* variable *********
;
;
; -----------------------------------------------------------------------------

; Current search string
Global CurSearchString              := ""

; New search string
Global NewSearchString              := ""
Global DisplayListShown             := 0
Global CtrlBtnDown                  := false
Global NumberBtnDown                := false
Global NumberBtnValue               := -1
Global Window_Found_Count           := 0
Global SelectedRowNumber            := 1
Global SelectedWinNumber            := 0
Global SelectedProcName             := ""
Global LVE_VkCodePrev                =
Global HotkeysDisabled              := false
Global AltTabHotkeysDisabled        := false
Global AltBacktickHotkeysDisabled   := false
Global ATACSHotkeysDisabled         := false
Global ActivateWindow               := false
Global HiddenWindowList             := {}
Global ShowHiddenWindows            := false
Global IsAltBacktick                := false
Global BacktickFilterWindows        := true
Global BacktickProcName             := ""
Global ProcessDictList              := ""
Global ProcessDictListIndex         := -1

Global SBPartsCount                 := 3
Global SBPartPIDPos                 := 3
Global SBPartActiveWindowPos        := 2
Global SBPartInfoPos                := 1

Global SBPartPIDWidth               := 108
Global SBPartActiveWindowWidth      := 60


; -----------------------------------------------------------------------------
; USER EDITABLE SETTINGS:
; -----------------------------------------------------------------------------
; Icons
UseLargeIcons       := 1     ; 0 = small icons, 1 = large icons in listview
ListviewResizeIcons := 0     ; Resize icons to fit listview area


; -----------------------------------------------------------------------------
; Read settings here and ::Global Variables
; -----------------------------------------------------------------------------
IniFileData("Read")
PrintSettings()

;~ Global SimilarProcessGroupsStr := "notepad++.exe/notepad.exe|chrome.exe/iexplore.exe|explorer.exe/xplorer2_lite.exe/xplorer2.exe/xplorer2_64.exe"
;~ Global ProcessDictList := GetProcessDictList(SimilarProcessGroupsStr)
;~ Global ProcessDictListIndex := -1

;~ PrintProcessDictList("ProcessDictList", ProcessDictList)


; Position
GuiX = Center
GuiY = Center


; -----------------------------------------------------------------------------
; USER OVERRIDABLE SETTINGS:
; -----------------------------------------------------------------------------

; Convert colours to correct format for listview color functions:
; I have disabled the selection of item with the below colors in ListView.
Listview_Colour_Selected_Text       := RGBtoBGR("0xFFFFFF")
Listview_Colour_Selected_Back       := RGBtoBGR("0x0080FF")

; ListView Column Widths
Col_1 = Auto    ; Icon Column
Col_2 = 0       ; Row Number
; col 3 is autosized based on other column sizes
Col_4 = Auto    ; Process Name
Col_4_Width_Min := 143
Col_4_Width_Max := 200

ColumnTitleList = #| |Window Title|Process Name
StringSplit, ColumnTitle, ColumnTitleList,| ; Create list of listview header titles

; -----------------------------------------------------------------------------
; 
; -----------------------------------------------------------------------------
If A_PtrSize = 8
    GetClassLong_API := "GetClassLongPtr"
else
    GetClassLong_API := "GetClassLong"

WS_EX_APPWINDOW = 0x40000   ; Provides a taskbar button
WS_EX_TOOLWINDOW = 0x80     ; Removes the window from the alt-tab list
GW_OWNER = 4

SysGet, ScrollbarVerticalThickness, 2 ; 2 is SM_CXVSCROLL, Width of a vertical scroll bar
If A_OSVersion = WIN_2000
    lv_h_win_2000_adj = 2 ; adjust height of main listview by +2 pixels to avoid scrollbar in windows 2000
Else
    lv_h_win_2000_adj = 0

UseLargeIconsCurrent = %UseLargeIcons% ; for remembering original user setting but changing on the fly

; -----------------------------------------------------------------------------
; System Tray Menu
; -----------------------------------------------------------------------------

MouseGetPos, xpos, ypos
;~ PrintKV2("xpos", xpos, "ypos", ypos)
Tooltip, Installing %ATAPRODUCTNAME% ......`, please wait, xpos, ypos, 1
Sleep, 100
ToolTip

; Initiate Hotkeys
Gosub, InitiateHotkeys

; Read the hidden windows if there are any
Gosub, HiddenWindowsFileOpen

; Menu Stuff

Menu, Tray, NoStandard  ; Clear previous entries
Menu TRAY, Icon
IfExist %TrayIcon%
    Menu TRAY, Icon, %TrayIcon%
Menu, Tray, Add, About %ATAPRODUCTNAME%, AboutHandler
Menu, Tray, Add  ; Separator
Menu, Tray, Add, ReadMe, ReadMeHandler
Menu, Tray, Add, Help, HelpHandler
Menu, Tray, Add, Release Notes, ReleaseNotesHandler
Menu, Tray, Add  ; Separator
Menu, Tray, Add, Settings, SettingsHandler
Menu, Tray, Add, Disable %ProgramName%, DisableHandler
Menu, Tray, Add, Check for updates, CheckForUpdatesHandler
Menu, Tray, Add, Run At Startup, RunAtStartupHandler
Menu, Tray, Add  ; Separator
Menu, Tray, Add, Exit, ExitHandler
Menu, Tray, Tip, %ATAPRODUCTNAME%
Menu, Tray, Default, About %ATAPRODUCTNAME%


; -----------------------------------------------------------------------------
; Create HiddenWindowsFilePath file if not exists
; -----------------------------------------------------------------------------
IfNotExist, %HiddenWindowsFilePath%
{
    CSV_Create(HiddenWindowsFilePath, HiddenWindowsFile_Cols, HiddenWindowsFile_ID)
    CSV_Save(HiddenWindowsFilePath, HiddenWindowsFile_ID)
}


; -----------------------------------------------------------------------------
; Check if the application is marked "Run At Startup"
; Always Run At Startup when the application starts.
; -----------------------------------------------------------------------------
IfExist, %A_Startup%/%ProgramName%.lnk
{
	FileDelete, %A_Startup%/%ProgramName%.lnk
	;~ FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/%ProgramName%.lnk
	;~ Menu, Tray, Check, Run At Startup
}

FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/%ProgramName%.lnk
Menu, Tray, Check, Run At Startup

; -----------------------------------------------------------------------------
; Run CheckForUpdates
; -----------------------------------------------------------------------------
RunCheckForUpdates()


; -----------------------------------------------------------------------------
; Create AltTabAlternative Window ContextMenu here
; -----------------------------------------------------------------------------
Menu, ATAContextMenu, Add, &About %ATAPRODUCTNAME%`tShift+F1, AboutHandler
Menu, ATAContextMenu, Add  ; Separator
Menu, ATAContextMenu, Add, &ReadMe, ReadMeHandler
Menu, ATAContextMenu, Add, &Help`tF1, HelpHandler
Menu, ATAContextMenu, Add, &Release Notes, ReleaseNotesHandler
Menu, ATAContextMenu, Add  ; Separator
Menu, ATAContextMenu, Add, &Settings`tF2, SettingsHandler
Menu, ATAContextMenu, Add  ; Separator
Menu, ATAContextMenu, Add, E&xit, ExitHandler


; -----------------------------------------------------------------------------
; Create AltTabAlternative ListView ContextMenu here
; -----------------------------------------------------------------------------
Menu, ListViewContextMenu, Add, &Close Window`tDel, CloseWindowHandler
Menu, ListViewContextMenu, Add, &Kill Process`tShift+Del, KillProcessHandler
Menu, ListViewContextMenu, Add  ; Separator
Menu, ListViewContextMenu, Add, &Close All Windows`tNumpadDiv (/), CloseAllWindowsHandler
Menu, ListViewContextMenu, Add, &Kill All Processes`tShift+NumpadDiv (/), KillAllProcessesHandler
Menu, ListViewContextMenu, Add  ; Separator
Menu, ListViewContextMenu, Add, &About %ATAPRODUCTNAME%`tShift+F1, AboutHandler
Menu, ListViewContextMenu, Add, &ReadMe, ReadMeHandler
Menu, ListViewContextMenu, Add, &Help`tF1, HelpHandler
Menu, ListViewContextMenu, Add, &Release Notes, ReleaseNotesHandler
Menu, ListViewContextMenu, Add, &Settings`tF2, SettingsHandler
Menu, ListViewContextMenu, Add  ; Separator
Menu, ListViewContextMenu, Add, E&xit, ExitHandler

Return

/*
 * ----------------------------------------------------------------------------
 * Just to know returning script at here !!!
 * ----------------------------------------------------------------------------
 *
 *                    _..-'(                       )`-.._
 *                  ./'. '||\\.       (\_/)       .//||` .`\.
 *               ./'.|'.'||||\\|..    )O O(    ..|//||||`.`|.`\.
 *            ./'..|'.|| |||||\`````` '`"'` ''''''/||||| ||.`|..`\.
 *          ./'.||'.|||| ||||||||||||.     .|||||||||||| |||||.`||.`\.
 *         /'|||'.|||||| ||||||||||||{     }|||||||||||| ||||||.`|||`\
 *        '.|||'.||||||| ||||||||||||{     }|||||||||||| |||||||.`|||.`
 *       '.||| ||||||||| |/'   ``\||``     ''||/''   `\| ||||||||| |||.`
 *       |/' \./'     `\./         \!|\   /|!/         \./'     `\./ `\|
 *       V    V         V          }' `\ /' `{          V         V    V
 *       `    `         `               V               '         '    '
 *
 *                                                                             ,aa,       ,aa
 *                                                                            d"  "b    ,d",`b
 *                                                                          ,dP a  "b,ad8' 8 8
 *                                                                          d8' 8  ,88888a 8 8
 *                                                                         d8baa8ba888888888a8
 *                                                                      ,ad888888888YYYY888YYY,
 *                                                                   ,a888888888888"   "8P"  "b
 *                                                               ,aad8888tt,8888888b (0 `8, 0 8
 *                           ____________________________,,aadd888ttt8888ttt"8"I  "Yb,   `Ya  8
 *                     ,aad8888b888888aab8888888888b,     ,aatPt888ttt8888tt 8,`b,   "Ya,. `"aP
 *                 ,ad88tttt8888888888888888888888888ttttt888ttd88888ttt8888tt,t "ba,.  `"`d888
 *              ,d888tttttttttttttt888888888888888888888888ttt8888888888ttt888ttt,   "a,   `88'
 *             a888tttttttttttttttttttttttttt8888888888888ttttt88888ttt888888888tt,    `""8"'
 *            d8P"' ,tttttttttttttttttttttttttttttttttt88tttttt888tttttttt8a"8888ttt,   ,8'
 *           d8tb  " ,tt"  ""tttttttttttttttttttttttttttttttttt88ttttttttttt, Y888tt"  ,8'
 *           88tt)              "t" ttttt" """  """    "" tttttYttttttttttttt, " 8ttb,a8'
 *           88tt                    `"b'                  ""t'ttttttttttt"t"t   t taP"
 *           8tP                       `b                       ,tttttt' " " "tt, ,8"
 *          (8tb  b,                    `b,                 a,  tttttt'        ""dP'
 *          I88tb `8,                    `b                d'   tttttt        ,aP"
 *          8888tb `8,                   ,P               d'    "tt "t'    ,a8P"
 *         I888ttt, "b                  ,8'              ,8       "tt"  ,d"d"'
 *        ,888tttt'  8b               ,dP""""""""""""""""Y8        tt ,d",d'
 *      ,d888ttttP  d"8b            ,dP'                  "b,      "ttP' d'
 *    ,d888ttttPY ,d' dPb,        ,dP'                      "b,     t8'  8
 *   d888tttt8" ,d" ,d"  8      ,d"'                         `b     "P   8
 *  d888tt88888d" ,d"  ,d"    ,d"                             8      I   8
 * d888888888P' ,d"  ,d"    ,d"                               8      I   8
 * 88888888P' ,d"   (P'    d"                                 8      8   8
 * "8P"'"8   ,8'    Ib    d"                                  Y      8   8
 *       8   d"     `8    8                                   `b     8   Y
 *       8   8       8,   8,                                   8     Y   `b
 *       8   Y,      `b   `b                                   Y     `b   `b
 *       Y,   "ba,    `b   `b,                                 `b     8,   `"ba,
 *        "b,   "8     `b    `""b                               `b     `Yaa,adP'
 *          """""'      `baaaaaaP                                `YaaaadP"'
 * 
 * ----------------------------------------------------------------------------
 */

; -----------------------------------------------------------------------------
; Display GuiContextMenu
; -----------------------------------------------------------------------------
GuiContextMenu:
    PrintSub("GuiContextMenu")
    ;~ PrintKV("A_Gui", A_Gui)
    ;~ PrintKV("A_GuiControl", A_GuiControl)
    ;~ PrintKV("A_EventInfo", A_EventInfo)
    ;~ PrintKV("A_GuiEvent", A_GuiEvent)
    if (A_GuiControl = "ListView1") {
        Menu, ListViewContextMenu, Show, %A_GuiX%, %A_GuiY%
    }
    else {
        Menu, ATAContextMenu, Show, %A_GuiX%, %A_GuiY%
    }
Return


; -----------------------------------------------------------------------------
; Display ListViewContextMenu
; -----------------------------------------------------------------------------
ListViewContextMenu:
    PrintSub("ListViewContextMenu")
    GetSelectedRowInfo()
    PrintKV("[ListViewContextMenu] SelectedRowNumber", SelectedRowNumber)
    GuiID := WinExist()

    VarSetCapacity(rect, 16, 0)
    SelectedRowNumberNew := SelectedRowNumber - 1
    PrintKV("SelectedRowNumberNew", SelectedRowNumberNew)
    xmin := ymin := 10000
    xmax := ymax := -1000
    
    Loop, % LV_GetCount("Col")
    {
        NumPut(0, rect, 0)            ; LVIR_LABEL : 2, get label info constant
        NumPut(A_Index, rect, 4)      ; 1-based subitem index (i think it is column)
        SelectedRowNumberNew := SelectedRowNumber - 1
        SendMessage, 0x1000+56, %SelectedRowNumberNew%, &rect, SysListView321, ahk_id %GuiID% ; LVM_GETSUBITEMRECT - 56, LVIR_BOUNDS - 0
        x1 := NumGet(&rect, 0, "UInt"), y1 := NumGet(&rect,  4, "UInt")
        x2 := NumGet(&rect, 8, "UInt"), y2 := NumGet(&rect, 12, "UInt")
        ;~ PrintKV4("x1", x1, "y1", y1, "x2", x2, "y2", y2)
        xmin := (xmin > x1 ? x1 : xmin)
        ymin := (ymin > y1 ? y1 : ymin)
        xmax := (xmax < x2 ? x2 : xmax)
        ymax := (ymax < y2 ? y2 : ymax)        
    }
    Print4(xmin, ymin, xmax, ymax)
    xmid := xmin + (xmax - xmin + 1) / 2
    ymid := ymax + 21 + 2
    Print2(xmid, ymid)
    
    ;~ Menu, ListViewContextMenu, Show, %A_GuiX%, %A_GuiY%
    Menu, ListViewContextMenu, Show, %xmid%, %ymid%
Return


; -----------------------------------------------------------------------------
; CloseWindow Handler
; -----------------------------------------------------------------------------
CloseWindowHandler:
    PrintSub("CloseWindowHandler")
    GetSelectedRowInfo()
    windowID := Window%SelectedRowNumber%
    TerminateWindow(windowID)
Return


; -----------------------------------------------------------------------------
; KillProcess Handler: Kill process forcefully.
; -----------------------------------------------------------------------------
KillProcessHandler:
    PrintSub("KillProcessHandler")
    GetSelectedRowInfo()
    procID := PID%SelectedRowNumber%
    KillProcessForcefully(procID)
Return


; -----------------------------------------------------------------------------
; CloseAllWindows Handler
; -----------------------------------------------------------------------------
CloseAllWindowsHandler:
    PrintSub("CloseAllWindowsHandler")
    Gosub, DisableIncrementalSearch

    ; Prompts for confirmation before terminating
    if (PromptTerminateAll) {
        Gui, +OwnDialogs    ; To display a modal dialog
        ;   0x4 : Yes/No
        ;  0x20 : Icon Question
        ; 0x100 : Makes the 2nd button the default
        MsgBox, 292, AltTabAlternative: Close All Windows, Are you sure you want to close all windows?
        IfMsgBox, No
        {
            Gosub, EnableIncrementalSearch
            return
        }                
    }

    Loop, %Window_Found_Count%
    {
        windowID := Window%A_Index%
        index := Window_Found_Count - A_Index + 1
        PrintKV3("[CloseAllWindowsHandler] index", index, "PID", PID%index%, "windowTitle", WindowTitle%index%)
        TerminateWindow(windowID)
        LV_Delete(index)
    }
    
    ; Set Window_Found_Count to 0, then only ListView gets updated with new windows
    Window_Found_Count := 0
    Gosub, EnableIncrementalSearch
Return


; -----------------------------------------------------------------------------
; KillAllProcesses Handler: Kill all process forcefully.
; -----------------------------------------------------------------------------
KillAllProcessesHandler:
    PrintSub("KillAllProcessesHandler")
    Gosub, DisableIncrementalSearch

    ; Prompts for confirmation before terminating
    if (PromptTerminateAll) {
        Gui, +OwnDialogs    ; To display a modal dialog
        ;   0x4 : Yes/No
        ;  0x20 : Icon Question
        ; 0x100 : Makes the 2nd button the default
        MsgBox, 292, AltTabAlternative: Kill All Processes, Are you sure you want to kill all processes?
        IfMsgBox, No
        {
            Gosub, EnableIncrementalSearch
            return
        }                
    }

    Loop, %Window_Found_Count%
    {
        windowID := Window%A_Index%
        index := Window_Found_Count - A_Index + 1
        PrintKV3("[KillAllProcessesHandler] index", index, "PID", PID%index%, "windowTitle", WindowTitle%index%)

        KillProcessForcefully(PID%index%)
        LV_Delete(index)
    }
    
    ; Set Window_Found_Count to 0, then only ListView gets updated with new windows
    Window_Found_Count := 0
    Gosub, EnableIncrementalSearch
Return


; -----------------------------------------------------------------------------
; ExitApp
; -----------------------------------------------------------------------------
ExitHandler:
    MsgBox, 292, %ProductName%, Are you sure you want to exit?
    IfMsgBox, No
    {
        return
    }
    ExitApp


; -----------------------------------------------------------------------------
; RunAtStartup Handler
; -----------------------------------------------------------------------------
RunAtStartupHandler:
	Menu, Tray, Togglecheck, Run At Startup
	IfExist, %A_Startup%/%ProgramName%.lnk
		FileDelete, %A_Startup%/%ProgramName%.lnk
	else
        FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/%ProgramName%.lnk
Return


; -----------------------------------------------------------------------------
; CheckForUpdates Handler
; -----------------------------------------------------------------------------
CheckForUpdatesHandler:
    CheckForUpdatesFunction(true)
Return


; -----------------------------------------------------------------------------
; Disable AltTabAlternative Handler
; -----------------------------------------------------------------------------
DisableHandler:
    PrintKV("HotkeysDisabled", HotkeysDisabled)
    if (HotkeysDisabled) {
        ToggleHotkeys("On")
    } else {
        ToggleHotkeys("Off")
    }
    Menu, Tray, Togglecheck, Disable %ProgramName%
Return


; -----------------------------------------------------------------------------
; Display About Dialog Box
; -----------------------------------------------------------------------------
AboutHandler:
    Gosub, AltTabAlternativeDestroy
    AboutDialog()
Return


; -----------------------------------------------------------------------------
; Display Settings Dialog
; -----------------------------------------------------------------------------
SettingsHotkeyHandler:
    Gosub, AltTabAlternativeDestroy
    ShowSettingsDialog()
Return

SettingsHandler:
    Gosub, AltTabAlternativeDestroy
    ShowSettingsDialog()
Return


; -----------------------------------------------------------------------------
; Display Release Notes dialog
; -----------------------------------------------------------------------------
ReleaseNotesHandler:
    Gosub, AltTabAlternativeDestroy
    ShowReleaseNotes()
Return


; -----------------------------------------------------------------------------
; Display help window
; -----------------------------------------------------------------------------
HelpHotkeyHandler:
    Gosub, AltTabAlternativeDestroy
    ShowHelp()
Return

HelpHandler:
    Gosub, AltTabAlternativeDestroy
    ShowHelp()
Return


; -----------------------------------------------------------------------------
; Display ReadMe window
; -----------------------------------------------------------------------------
ReadMeHandler:
    Gosub, AltTabAlternativeDestroy
    ShowReadMe()
Return


; -----------------------------------------------------------------------------
; Initiate hotkeys
; -----------------------------------------------------------------------------
InitiateHotkeys:
    PrintSub("InitiateHotkeys")
    AltHotKey                 = !
    ShiftHotKey               = +
    AltHotKey2                = Alt
    TabHotKey                 = Tab
    ShiftTabHotkey            = +Tab
    EscHotKey                 = Esc
    BacktickHotKey            = ``
    ShiftBacktickHotKey       = +``
    HelpHotKey                = F1
    SettingsHotKey            = F2
    HideWindowHotkey          = +NumpadSub
    UnHideWindowHotkey        = +NumpadAdd
    ToggleHiddenWindowsHotkey = +NumpadMult
    
    PrintKV("AltHotkey", AltHotkey)
    PrintKV("TabHotkey", TabHotkey)
    PrintKV("ShiftTabHotkey", ShiftTabHotkey)
    PrintKV("BacktickHotKey", BacktickHotKey)
    PrintKV("ShiftBacktickHotKey", ShiftBacktickHotKey)
    PrintKV("EscHotKey", EscHotKey)
    PrintKV("HelpHotKey", HelpHotKey)
    PrintKV("SettingsHotKey", SettingsHotKey)
    
    ; Turn on Alt+Tab & Alt+Shift+Tab hotkey here to be able to turn it off for
    ;   simple switching of apps in script
    ;~ Hotkey, %AltHotkey%%EscHotKey%, AltEsc, Off
    ;~ Hotkey, %AltHotkey%%TabHotkey%, AltTabAlternative, On
    ;~ Hotkey, %AltHotkey%%ShiftTabHotkey%, AltShiftTabAlternative, On
    ToggleHotkeys("On")
Return


; -----------------------------------------------------------------------------
; Toggle Hotkeys
; This function toggles the below hotkeys
;  * Alt+Tab / Alt+Shift+Tab
;  * Alt+Backtick / Alt+Shift+Backtick
; -----------------------------------------------------------------------------
ToggleHotkeys(state)    ; (state = "On" or "Off")
{
    Global
    PrintSub("ToggleHotkeys")
    PrintKV("ToggleHotkeys: state", state)
    if (state = "on") {
        Print("state = on")
        HotKeysDisabled := false
    } else if (state = "off") {
        Print("state = off")
        HotkeysDisabled := true
    } else {
        Print("Unknown state")
        return
    }

    ; Alt+Tab
    ;~ Hotkey, %AltHotkey%%TabHotkey%, AltTabAlternative, %state% UseErrorLevel
    ;~ Hotkey, %AltHotkey%%ShiftTabHotkey%, AltShiftTabAlternative, %state% UseErrorLevel
    ToggleAltTabHotkeys(state)
    
    ; Alt+Backtick
    ;~ Hotkey, %AltHotkey%%BacktickHotkey%, AltBacktickAlternative, %state% UseErrorLevel
    ;~ Hotkey, %AltHotkey%%ShiftBacktickHotkey%, AltShiftBacktickAlternative, %state% UseErrorLevel
    ToggleAltBacktickHotkeys(state)
}


; -----------------------------------------------------------------------------
; Toggle Alt+Tab Hotkeys
; Disable Alt+Tab hotkeys when Alt+Backtick is pressed.
; -----------------------------------------------------------------------------
ToggleAltTabHotkeys(state)    ; (state = "On" or "Off")
{
    Global
    PrintSub("ToggleAltTabHotkeys")
    PrintKV("ToggleAltTabHotkeys: state", state)
    if (state = "on") {
        ;~ Print("state = on")
        AltTabHotkeysDisabled := false
    } else if (state = "off") {
        ;~ Print("state = off")
        AltTabHotkeysDisabled := true
    } else {
        Print("Unknown state")
        return
    }

    ; Alt+Tab
    Hotkey, %AltHotkey%%TabHotkey%, AltTabAlternative, %state% UseErrorLevel
    Hotkey, %AltHotkey%%ShiftTabHotkey%, AltShiftTabAlternative, %state% UseErrorLevel
}


; -----------------------------------------------------------------------------
; Toggle Alt+Tab Hotkeys
; Disable Alt+Tab hotkeys when Alt+Backtick is pressed.
; -----------------------------------------------------------------------------
ToggleAltBacktickHotkeys(state)    ; (state = "On" or "Off")
{
    Global
    PrintSub("ToggleAltBacktickHotkeys")
    PrintKV("ToggleAltBacktickHotkeys: state", state)
    if (state = "on") {
        ;~ Print("state = on")
        AltBacktickHotkeysDisabled := false
    } else if (state = "off") {
        ;~ Print("state = off")
        AltBacktickHotkeysDisabled := true
    } else {
        Print("Unknown state")
        return
    }
    
    ; Alt+Backtick
    Hotkey, %AltHotkey%%BacktickHotkey%, AltBacktickAlternative, %state% UseErrorLevel
    Hotkey, %AltHotkey%%ShiftBacktickHotkey%, AltShiftBacktickAlternative, %state% UseErrorLevel
}


; -----------------------------------------------------------------------------
; Toggle Alt+Tab Hotkeys
; Redirect Alt+Tab hotkeys when Alt+Backtick is pressed.
; -----------------------------------------------------------------------------
ToggleAltTabRedirectedHotkeys(state)    ; (state = "On" or "Off")
{
    Global
    PrintSub("ToggleAltTabHotkeys")
    PrintKV("ToggleAltTabHotkeys: state", state)
    if (state = "on") {
        ;~ Print("state = on")
        AltTabHotkeysDisabled := false
    } else if (state = "off") {
        ;~ Print("state = off")
        AltTabHotkeysDisabled := true
    } else {
        Print("Unknown state")
        return
    }

    ; Alt+Tab
    Hotkey, %AltHotkey%%TabHotkey%, AltBacktickAlternative, %state% UseErrorLevel
    Hotkey, %AltHotkey%%ShiftTabHotkey%, AltShiftBacktickAlternative, %state% UseErrorLevel
}


; -----------------------------------------------------------------------------
; Toggle AltTabAlternative ContextSensitive Hotkeys
; Use these keys to hide/unhide, display hidden windows in listview.
; -----------------------------------------------------------------------------
ToggleATACSHotkeys(state)    ; (state = "On" or "Off")
{
    Global
    PrintSub("ToggleATACSHotkeys")
    PrintKV("ToggleATACSHotkeys: state", state)
    if (state = "on") {
        Print("state = on")
        ATACSHotKeysDisabled := false
    } else if (state = "off") {
        Print("state = off")
        ATACSHotKeysDisabled := true
    } else {
        Print("Unknown state")
        return
    }

    Hotkey, %AltHotkey%%HideWindowHotkey%, ATAHideWindow, %state% UseErrorLevel
    Hotkey, %AltHotkey%%UnHideWindowHotkey%, ATAUnHideWindow, %state% UseErrorLevel
    Hotkey, %AltHotkey%%ToggleHiddenWindowsHotkey%, ATAToggleHiddenWindows, %state% UseErrorLevel
}


ToggleAltEscHotkey(state)    ; (state = "On" or "Off")
{
    Global
    PrintKV("ToggleAltEscHotkey: state", state)
    if (state = "on") {
        Print("state = on")
    } else if (state = "off") {
        Print("state = off")
    } else {
        Print("Unknown state")
        return
    }   

    Hotkey, %AltHotkey%%EscHotkey%, AltEsc, %state% UseErrorLevel
}


; -----------------------------------------------------------------------------
; AltEsc handler
; -----------------------------------------------------------------------------
AltEsc:
    PrintSub("AltEsc")
    AltEscPressed = 1
    Gosub, AltTabAlternativeDestroy
Return


; -----------------------------------------------------------------------------
; AltTabAlternative Gosub
; This hotkey displays the actual window
; -----------------------------------------------------------------------------
AltTabAlternative:
    PrintSub("AltTabAlternative")
    AltTabCommonFunction(1)
Return
    

; -----------------------------------------------------------------------------
; AltShiftTabAlternative Gosub
; This hotkey displays the actual window
; -----------------------------------------------------------------------------
AltShiftTabAlternative:
    PrintSub("AltShiftTabAlternative")
    AltTabCommonFunction(-1)
Return


; -----------------------------------------------------------------------------
; AltBacktickAlternative Gosub
; This hotkey displays the actual window
; -----------------------------------------------------------------------------
AltBacktickAlternative:
    PrintSub("AltBacktickAlternative")
    AltBacktickCommonFunction(1)
Return
    

; -----------------------------------------------------------------------------
; AltShiftTabAlternative Gosub
; This hotkey displays the actual window
; -----------------------------------------------------------------------------
AltShiftBacktickAlternative:
    PrintSub("AltShiftBacktickAlternative")
    AltBacktickCommonFunction(-1)
Return


; -----------------------------------------------------------------------------
; This hotkey displays the actual window
; -----------------------------------------------------------------------------
AltTabCommonFunction(direction)
{
    Global DisplayListShown
    Global Window_Found_Count
    Global LVE_VkCodePrev
    Global SBPartPIDPos
    Global IsAltBacktick
    
    IsAltBacktick := false
    
    PrintSub("AltTabCommonFunction")
    PrintKV("direction", direction)
    PrintKV("DisplayListShown", DisplayListShown)
    
    if (DisplayListShown = 0) {
        Print("--- Test ---")
        Gosub, InitializeDefaults
        Gosub, CreateWindow
        Gosub, DisplayList
        Gosub, GuiResizeAndPosition
        Gosub, ShowWindow
        ;~ Gosub, HiddenWindowsFileOpen
        ToggleAltEscHotkey("On")
        ToggleATACSHotkeys("On")
        ToggleAltBacktickHotkeys("Off")
    }

    SB_SetText("")
    
    ; Check for Alt Up 
    SetTimer, CheckAltHotkeyUp, 40
    
    ; Reset LVE_VkCodePrev to empty
    ; When user switching between windows using Alt+Shift+Tab and press Del,
    ; then should not treat this as Shift+Del (forcefully terminate process)
    ; So, need to reset LVE_VkCodePrev to empty always while Alt+Shift+Tab
    LVE_VkCodePrev =
    
    SelectedRowNumber := LV_GetNext(0, "F")
    SelectedRowNumber += direction
    if (SelectedRowNumber > Window_Found_Count) {
        SelectedRowNumber = 1
    }
    if (SelectedRowNumber < 1) {
        SelectedRowNumber := Window_Found_Count
    }
    PrintKV("[AltTabCommonFunction] SelectedRowNumber", SelectedRowNumber)
    ;~ LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible
    ListViewSelectRow(SelectedRowNumber)

    ; Display the selected row number and its WindowID
    ;~ PrintSelectedRowInfo()

    Return
}


; -----------------------------------------------------------------------------
; This hotkey displays the actual window
; Disable the Alt+Tab hotkeys when the Alt+Tab key is pressed and enable them
;  when the Alt key is released.
; -----------------------------------------------------------------------------
AltBacktickCommonFunction(direction)
{
    Global DisplayListShown
    Global Window_Found_Count
    Global LVE_VkCodePrev
    Global SBPartPIDPos
    Global IsAltBacktick
    Global SelectedProcName

    IsAltBacktick := true

    PrintSub("AltBacktickCommonFunction")
    PrintKV("direction", direction)
    PrintKV("DisplayListShown", DisplayListShown)
    
    if (DisplayListShown = 0) {
        Print("--- Test ---")
        Gosub, InitializeDefaults
        Gosub, CreateWindow
        Gosub, DisplayList
        Gosub, GuiResizeAndPosition
        Gosub, ShowWindow
        ;~ Gosub, HiddenWindowsFileOpen
        ToggleAltEscHotkey("On")
        ToggleATACSHotkeys("On")
        
        ; Disable the Alt+Tab hotkeys
        ;~ ToggleAltTabHotkeys("Off")
        ToggleAltTabRedirectedHotkeys("On")
    }

    SB_SetText("")
    SB_SetText("Alt+Backtick, Selected ProcessName: " . SelectedProcName)
    
    ; Check for Alt Up 
    SetTimer, CheckAltHotkeyUp, 40
    
    ; Reset LVE_VkCodePrev to empty
    ; When user switching between windows using Alt+Shift+Tab and press Del,
    ; then should not treat this as Shift+Del (forcefully terminate process)
    ; So, need to reset LVE_VkCodePrev to empty always while Alt+Shift+Tab
    LVE_VkCodePrev =
    
    SelectedRowNumber := LV_GetNext(0, "F")
    ; SelectedRowNumber += direction
    if (direction > 0) {
        SelectedRowNumber := GetNextRowInfoOfSameProcess()
    }
    else {
        SelectedRowNumber := GetPrevRowInfoOfSameProcess()
    }
    
    if (SelectedRowNumber > Window_Found_Count) {
        SelectedRowNumber = 1
    }
    if (SelectedRowNumber < 1) {
        SelectedRowNumber := Window_Found_Count
    }
    PrintKV("[AltBacktickCommonFunction] SelectedRowNumber", SelectedRowNumber)
    ;~ LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible
    ListViewSelectRow(SelectedRowNumber)

    ; Display the selected row number and its WindowID
    ;~ PrintSelectedRowInfo()

    Return
}


DisplayLVColors:
    ; Assign Colors
    PrintSub("DisplayLVColors")
    GuiControl, -Redraw, ListView1
    PrintDictKV("HiddenWindowList", HiddenWindowList)
    Loop, % Window_Found_Count
    {
        WindowID := Window%A_Index%
        
        if (HiddenWindowList.HasKey(WindowID)) {
            PrintKV("[DisplayLVColors] Applying Colors to WindowID", WindowID)
            LV_ColorChange(index, ListViewHWFontColor, ListViewHWBackgroundColor)
        }
        ;~ else {
            ;~ PrintKV("[DisplayLVColors] WindowID is NOT a hidden window", WindowID)
        ;~ }
    }
    GuiControl, +Redraw, ListView1
    ;~ WinSet, Redraw,, ahk_id %ListView1Hwnd%
Return

; -----------------------------------------------------------------------------
; Check for Alt key release when the AltTab window is displayed
; -----------------------------------------------------------------------------
CheckAltHotkeyUp:
    ;~ PrintSub("CheckAltHotkeyUp")
    ;~ PrintKV("AltHotKey2", AltHotKey2)
    IsAltKeyReleased := GetKeyState(AltHotKey2, "P")
    ;~ PrintKV("IsAltKeyReleased", IsAltKeyReleased)
    If !(GetKeyState(AltHotKey2, "P") or GetKeyState(AltHotKey2)) ; Alt key released
    {
        PrintSub("CheckAltHotkeyUp: Alt key released")
        ActivateWindow := true
        Gosub, AltTabAlternativeDestroy
    }
Return


; -----------------------------------------------------------------------------
; Hide Window
; Description:
;   1. Hides the selected window and add its WindowID to HiddenWindowList dict
;   2. If ShowHiddenWindows is true then show that window with the hidden font
;      color and background color on hide window (OnKeyPress: Shift+NumpadSub)
; -----------------------------------------------------------------------------
ATAHideWindow:
    PrintLabel()
    GetSelectedRowInfo()
    windowID        := Window%SelectedRowNumber%        ; Store Window ID

    if (HiddenWindowList.HasKey(windowID)) {
        Print("[ATAHideWindow] ERROR: This is already hidden window.")
        SB_SetText("This is already hidden window.")
        Return
    }

    Gosub, DisableIncrementalSearch

    ownerID         := WindowParent%SelectedRowNumber%  ; Store Parent ahk_id's to a list to later see if window is owned
    windowTitle     := WindowTitle%SelectedRowNumber%   ; Store titles to a list
    hw_popup        := hw_popup%SelectedRowNumber%      ; Store the active popup window to a list (eg the find window in notepad)
    procName        := Exe_Name%SelectedRowNumber%      ; Store the process name
    procPath        := Exe_Path%SelectedRowNumber%      ; Store the process path
    procID          := PID%SelectedRowNumber%           ; Store the process id
    Dialog          := Dialog%SelectedRowNumber%        ; S if found a Dialog window, else 0

    Print("[ATAHideWindow] ---------------------------------------------")
    Print("[ATAHideWindow] SelectedRowNumber = " . SelectedRowNumber)
    Print("[ATAHideWindow]          WindowID = " . windowID)
    Print("[ATAHideWindow]           OwnerID = " . ownerID)
    Print("[ATAHideWindow]       WindowTitle = " . windowTitle)
    Print("[ATAHideWindow]          ProcName = " . procName)
    Print("[ATAHideWindow]            ProcID = " . procID)
    Print("[ATAHideWindow] ---------------------------------------------")
    
    WindowInfo := {}
    WindowInfo.WindowID := windowID
    WindowInfo.OwnerID  := ownerID
    WindowInfo.Title    := windowTitle
    WindowInfo.ProcName := procName
    WindowInfo.ProcID   := procID
    
    HideWindow(windowID)
    HiddenWindowList[windowID] := WindowInfo
    PrintWindowsInfoList("[ATAHideWindow] HiddenWindowList", HiddenWindowList)
    PrintWindowInfo(WindowInfo)
    
    SBUpdateInfo(Format("Hide Window, WindowID: {1:#x}, PID: {2}", windowID, procID))
    
    ; -----------------------------------------------------------------------------
    ; If ShowHiddenWindows is already true, then the window still visible in
    ;  the ListView and this window can not be marked as displayed with colors
    ;  in DisplayList subroutine. Handle it here.
    ; -----------------------------------------------------------------------------
    if (ShowHiddenWindows) {
        LV_ColorChange(SelectedRowNumber, ListViewHWFontColor, ListViewHWBackgroundColor)
    }
    
    Gosub, EnableIncrementalSearch
Return


; -----------------------------------------------------------------------------
; UnHide Window
; -----------------------------------------------------------------------------
ATAUnHideWindow:
    PrintLabel()
    GetSelectedRowInfo()
    windowID        := Window%SelectedRowNumber%
    PrintKV("[ATAUnHideWindow] windowID", windowID)
    if (!HiddenWindowList.HasKey(windowID)) {
        Print("[ATAUnHideWindow] ERROR: This is NOT a hidden window.")
        SB_SetText("This is NOT a hidden window.")
        Return
    }

    Gosub, DisableIncrementalSearch

    WindowInfo      := HiddenWindowList[windowID]
    ownerID         := WindowInfo.OwnerID
    windowTitle     := WindowInfo.Title
    procName        := WindowInfo.ProcName
    procID          := WindowInfo.ProcID

    Print("[ATAUnHideWindow] ---------------------------------------------")
    Print("[ATAUnHideWindow] SelectedRowNumber = " . SelectedRowNumber)
    Print("[ATAUnHideWindow]          WindowID = " . windowID)
    Print("[ATAUnHideWindow]           OwnerID = " . ownerID)
    Print("[ATAUnHideWindow]       WindowTitle = " . windowTitle)
    Print("[ATAUnHideWindow]          ProcName = " . procName)
    Print("[ATAUnHideWindow]            ProcID = " . procID)
    Print("[ATAUnHideWindow] ---------------------------------------------")
    
    ShowWindow(windowID)
    HiddenWindowList.Delete(windowID)
    PrintWindowsInfoList("[ATAUnHideWindow] HiddenWindowList", HiddenWindowList)
    
    SBUpdateInfo(Format("Un-hide Window, WindowID: {1:#x}, PID: {2}", windowID, procID))
    
    ; Reset the color of the unhidden window with the ListView font color
    ;   and background color
    LV_ColorChange(SelectedRowNumber)
    
    Gosub, EnableIncrementalSearch
    
    ; By showing the window, hidden window becomes active window
    ; So, activate AltTabAlternative
    WinActivate, ahk_id %MainWindowHwnd%
    LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible
Return


; -----------------------------------------------------------------------------
; Hide Window
; -----------------------------------------------------------------------------
ATAToggleHiddenWindows:
    PrintLabel()
    ShowHiddenWindows := not ShowHiddenWindows
    PrintKV("ShowHiddenWindows", ShowHiddenWindows)
    SBUpdateInfo("ShowHiddenWindows: " . (ShowHiddenWindows ? "ON" : "OFF"))
    if (ShowHiddenWindows) {
        ListViewFontColorBGR            := RGBtoBGR(ListViewFontColor)
        ListViewBackgroundColorBGR      := RGBtoBGR(ListViewBackgroundColor)
        ListViewHWFontColorBGR          := RGBtoBGR(ListViewHWFontColor)
        ListViewHWBackgroundColorBGR    := RGBtoBGR(ListViewHWBackgroundColor)
        LV_ColorInitiateStart()
    }
    else {
        LV_ColorInitiateStop()
    }
Return


; -----------------------------------------------------------------------------
; Initialize the settings to defaults
; -----------------------------------------------------------------------------
InitializeDefaults:
    PrintSub("InitializeDefaults")
    NewSearchString     := ""
    CurSearchString     := ""
    SelectedRowNumber   := 1
    DisplayListShown    := 0
    CtrlBtnDown         := false
    NumberBtnDown       := false
    NumberBtnValue      := -1
    ActivateWindow      := false
    AltEscPressed       := 0
    ShowHiddenWindows   := false
    BacktickProcName    := ""
    ProcessDictListIndex := -1

    ; -----------------------------------------------------------------------------
    ; Need to compute the WindowWidth & WindowHeightMax to display
    ; the AltTabAlternative window with changes without restarting
    ; the application.
    ; -----------------------------------------------------------------------------
    WindowWidth     := A_ScreenWidth * WindowWidthPercentage * 0.01
    WindowHeightMax := A_ScreenHeight * WindowHeightMaxPercentage * 0.01
    PrintKV("WindowWidth", WindowWidth)
    PrintKV("WindowHeightMax", WindowHeightMax)    
Return


; -----------------------------------------------------------------------------
; Create the actual window and the controls here
; -----------------------------------------------------------------------------
CreateWindow:
    PrintSub("CreateWindow")
    Gui, 1: +AlwaysOnTop +ToolWindow -Caption +HwndMainWindowHwnd +Border -SysMenu
    Gui, 1: Margin, 0, 0

    Gui, 1: Font, s%SearchStringFontSize% c%SearchStringFontColor% %SearchStringFontStyle%, %SearchStringFontName%
    Gui, 1: Add, Text, w%WindowWidth% vTextCtrlVar hwndhSearchStringText gMainDoNothingHandler Center, Search String: empty
    AddTooltip(hSearchStringText, "Filter windows while typing, delete last character using backspace")

    Gui, 1: Font, s%ListViewFontSize% c%ListViewFontColor% %ListViewFontStyle%, %ListViewFontName%
    Gui, 1: Add, ListView, w%WindowWidth% h200 AltSubmit +Redraw -Multi NoSort +LV0x2 Background%ListViewBackgroundColor% Count10 gListViewEvent vListView1 HwndListView1Hwnd, %ColumnTitleList%
    
    Print("ListView1Hwnd = [" . ListView1Hwnd . "]")
    
    Gui, 1: Font, s%FontSize% c%FontColorEdit% %FontStyle%, %FontType%
    Gui, 1: Font
    Gui, 1: Font, S11, Lucida Console
    ;~ Gui, 1: Font, S11, Consolas

    if (ShowStatusBar) {
        Gui, 1: Add, StatusBar, vMyStatusBar +HwndhMyStatusBar, 
    }
    else {
        Gui, 1: Add, StatusBar, vMyStatusBar +HwndhMyStatusBar Hidden, 
    }

    
    SBPartInfoWidth := WindowWidth - SBPartActiveWindowWidth - SBPartPIDWidth
    SB_SetParts(SBPartInfoWidth, SBPartActiveWindowWidth, SBPartPIDWidth)

    Gui, 1: +LastFound
    WinSet, Transparent, %WindowTransparency%
Return


; -----------------------------------------------------------------------------
; Show Window
; -----------------------------------------------------------------------------
ShowWindow:
    PrintSub("ShowWindow")
    Gui_vx := GuiCenterX()
    Gui, 1: Show, AutoSize x%Gui_vx% y%GuiY%, AltTabAlternative
    LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible
    DisplayListShown = 1
Return


; -----------------------------------------------------------------------------
; Display dim background
; -----------------------------------------------------------------------------
DisplayDimBackground:
    PrintSub("DisplayDimBackground")
    ; define background GUI to dim all active applications
    SysGet, Width, 78
    SysGet, Height, 79

    SysGet, X0, 76
    SysGet, Y0, 77

    ; Background GUI used to show foremost window
    Gui, 4: +LastFound -Caption +ToolWindow
    Gui, 4: Color, Black
    Gui, 4: Show, Hide
    WinSet, Transparent, 120
    Gui, 4: Show, x%X0% y%Y0% w%Width% h%Height%
    Gui4_ID := WinExist() ; for auto-sizing columns later
Return
    

; -----------------------------------------------------------------------------
; Get the windows and fill them in ListView an filter the windows based on the
; search string
; -----------------------------------------------------------------------------
DisplayList:
    PrintLabel()
    PrintKV("[DisplayList] SelectedRowNumber", SelectedRowNumber)
    LV_ColorChange() ; Clear all highlighting
    GuiControl, -Redraw, ListView1
    LV_Delete()
    windowList =
    Window_Found_Count := 0
    
    DetectHiddenWindows, Off ; makes DllCall("IsWindowVisible") unnecessary
    
    ImageListID1 := IL_Create(10, 5, UseLargeIconsCurrent) ; Create an ImageList so that the ListView can display some icons
    LV_SetImageList(ImageListID1, 1)    ; Attach the ImageLists to the ListView so that it can later display the icons
    
    WinGet, windowList, list, , , Program Manager   ; gather a list of running programs
    Loop, %windowList%
    {
        ;~ PrintKV("[DisplayList] A_Index", A_Index)
        ownerID := windowID := windowList%A_Index%

        Loop {
            ownerID := DecimalToHex(DllCall("GetWindow", "UInt", ownerID, "UInt", GW_OWNER))
        } Until !DecimalToHex(DllCall("GetWindow", "UInt", ownerID, "UInt", GW_OWNER))
        
        ownerID := ownerID ? ownerID : windowID
        
        If (DecimalToHex(DllCall("GetLastActivePopup", "UInt", ownerID)) = windowID)
        {
            WinGet, windowES, ExStyle, ahk_id %windowID%
            WinGet, ownerES, ExStyle, ahk_id %ownerID%

            isAltTabWindow := false
            if (ownerES && !((ownerES & WS_EX_TOOLWINDOW) && !(ownerES & WS_EX_APPWINDOW)) && !IsInvisibleWin10BackgroundAppWindow(ownerID)) {
                isAltTabWindow := true
                WinGetTitle, ownerTitle, ahk_id %ownerID%
                ;~ PrintKV("Title", OwnerTitle)
                title := OwnerTitle
            }
            else if (windowES && !((windowES & WS_EX_TOOLWINDOW) && !(windowES & WS_EX_APPWINDOW)) && !IsInvisibleWin10BackgroundAppWindow(windowID)) {
                isAltTabWindow := true
                WinGetTitle, windowTitle, ahk_id %windowID%
                if (windowTitle = "") {
                    WinGetTitle, windowTitle, ahk_id %ownerID%
                }
                title := WindowTitle
                ;~ PrintKV("Title", WindowTitle)
            }
            else if (windowES = 0x0 && ownerES = 0x0) {
                ; I have no idea why the windowES or ownerES are 0x0 when watching videos in fullscreen
                ; mode in Google Chrome / Internet Explorer and etc, but getting the title correctly.
                ;~ FileAppend, windowES = 0x0 && ownerES = 0x0`n, *
                isAltTabWindow := true
                WinGetTitle, windowTitle, ahk_id %windowID%
                if (windowTitle = "") {
                    WinGetTitle, windowTitle, ahk_id %ownerID%
                }
                title := WindowTitle
            }
            
            if (isAltTabWindow) {
                WinGet, procPath, ProcessPath, ahk_id %windowID%
                WinGet, procName, ProcessName, ahk_id %windowID%
                PrintKV2("[DisplayList] Window_Found_Count", Window_Found_Count, "procName", procName)

                ; If Alt+Backtick is pressed and BacktickFilterWindows is true, then filter
                ; only the windows of the same application.
                if (IsAltBacktick && BacktickFilterWindows) {
                    if (DisplayListShown == 0 && Window_Found_Count == 0) {
                        BacktickProcName := procName
                        ProcessDictListIndex := GetProcessDictListIndex(ProcessDictList, BacktickProcName)
                        PrintKV("[DisplayList]     BacktickProcName", BacktickProcName)
                        PrintKV("[DisplayList] ProcessDictListIndex", ProcessDictListIndex)
                    }
                    else {
                        ;~ if (BacktickProcName != procName) {
                            ;~ continue
                        ;~ }
                        
                        bIsValidProc := (procName = BacktickProcName)
                            || (ProcessDictListIndex != -1 && ProcessDictList[ProcessDictListIndex].HasKey(procName))
                        if (not bIsValidProc) {
                            continue
                        }
                        
                        ;~ if (ProcessDictListIndex != -1) {
                            ;~ if (not ProcessDictList[ProcessDictListIndex].HasKey(procName)) {
                                ;~ continue
                            ;~ }
                        ;~ }
                        ;~ else {
                            ;~ continue
                        ;~ }
                    }
                }
                
                ;~ FileAppend, A_Index = [%A_Index%] title = [%title%]`, processName = [%procName%]`n, *
                ;~ Print("CurSearchString = " . CurSearchString)
                If (InStr(title, CurSearchString, false) != 0 or InStr(procName, CurSearchString, false) != 0)
                {
                    Window_Found_Count += 1
                    if (ownerES) {
                        ;~ Print("***************************** Getting icon from OwnerID *****************************")
                        GetWindowIcon(ownerID, UseLargeIconsCurrent)          ; (window id, whether to get large icons)
                    } else {
                        ;~ Print("***************************** Getting icon from WindowID *****************************")
                        GetWindowIcon(windowID, UseLargeIconsCurrent)          ; (window id, whether to get large icons)
                    }
                    ;~ PrintKV3("WindowID", windowID, "OwnerID", ownerID, "title", title)
                    ; Use windowID to activate window, ownerID to terminate window
                    WindowStoreAttributes(Window_Found_Count, windowID, ownerID)  ; Index, wid, parent (or blank if none)
                    LV_Add("Icon" . Window_Found_Count, "", Window_Found_Count, title, procName)
                }
            }
        }
    } ; Loop ends here!

    if (ShowHiddenWindows) {
        DetectHiddenWindows, On
        HiddenWindowListLen := GetDictLength(HiddenWindowList)
        PrintKV("[DisplayList] HiddenWindowListLen", HiddenWindowListLen)
        for WindowID, WindowInfo in HiddenWindowList {
            if (IsHiddenWindowExist(WindowInfo.WindowID)) {
                ;~ PrintKV("[DisplayList] WindowID", DecimalToHex(WindowID))
                ;~ PrintKV("[DisplayList] OwnerID", WindowInfo.OwnerID)
                PrintWindowInfo(HiddenWindowList[WindowID])
                Window_Found_Count += 1
                GetWindowIcon(WindowInfo.OwnerID, UseLargeIconsCurrent)          ; (window id, whether to get large icons)
                WindowStoreAttributes(Window_Found_Count, WindowInfo.WindowID, WindowInfo.OwnerID)  ; Index, wid, parent (or blank if none)
                LV_Add("Icon" . Window_Found_Count, "", Window_Found_Count, WindowInfo.Title, WindowInfo.ProcName)
            }
            else {
                HiddenWindowList.Delete(WindowID)
            }
        }
        DetectHiddenWindows, Off
    }
    
    PrintKV("[DisplayList] Window_Found_Count", Window_Found_Count)

    GuiControl, +Redraw, ListView1
    
    ;~ PrintKV("[DisplayList] SelectedRowNumber", SelectedRowNumber)
    ;~ LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible

    ; If there is a hidden window at end and it is the currently selected row
    ;  and ShowHiddenWindows is ON.
    ; When user turned ShowHiddenWindows OFF then change the selection to the
    ;  last row.
    if (SelectedRowNumber > Window_Found_Count) {
        SelectedRowNumber := Window_Found_Count
    }
    ListViewSelectRow(SelectedRowNumber)

    ; TURN ON INCREMENTAL SEARCH
    SetTimer, tIncrementalSearch, 500
Return


; -----------------------------------------------------------------------------
; ListView event handler
; Special cases:
;   Tab: Need to handle Tab pressed key (when Alt+Backtick is pressed)
; -----------------------------------------------------------------------------
ListViewEvent:
    Critical, 50
    ;~ PrintSub("ListViewEvent")
    ;~ Print("ListViewEvent: A_GuiEvent = " . A_GuiEvent)
    ;~ Print("ListViewEvent: A_EventInfo = " . A_EventInfo)
    ;~ key := GetKeyName(Format("vk{:x}", A_EventInfo))
    ;~ SBUpdateInfo("KeyPress: " . key)
    ;~ PrintKV2("ListViewEvent: A_EventInfo", A_EventInfo, "key", key)
    
    if A_GuiEvent = DoubleClick     ; DoubleClick
    {
        LV_GetText(RowText, A_EventInfo)
        ;~ ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"        
        SelectedRowNumber := A_EventInfo
        Print("SelectedRowNumber = " . SelectedRowNumber)
        windowID := Window%SelectedRowNumber%
        Print("Activating windowID = " . windowID)`
        Print("Activating windowTitle = " . WindowTitle%SelectedRowNumber%)
        WinActivate, ahk_id %windowID%
        Gosub, AltTabAlternativeDestroy
    }
    else if A_GuiEvent = Normal          ; Mouse left-click
    {
        LV_GetText(RowText, A_EventInfo)
        ;~ ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"        
        SelectedRowNumber := A_EventInfo
        Print("SelectedRowNumber = " . SelectedRowNumber)
        ;~ windowID := Window%SelectedRowNumber%
        ;~ Print("Activating windowID = " . windowID)
        ;~ Print("Activating windowTitle = " . WindowTitle%SelectedRowNumber%)
        ;~ WinActivate, ahk_id %windowID%
        ;~ Gosub, ListView_Destroy
    }
    ;~ else if A_GuiEvent = RightClick          ; Mouse RightClick
    ;~ {
        ;~ Gosub, ListViewContextMenu
        ;~ Return
    ;~ }
    ;~ if A_GuiEvent = I               ; Item Changed
    ;~ {
        ;~ LV_GetText(RowText, A_EventInfo)
        ;~ ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"        
        ;~ SelectedRowNumber := A_EventInfo
        ;~ Print("[A_GuiEvent = I] SelectedRowNumber = " . SelectedRowNumber)
        ;~ windowID := Window%SelectedRowNumber%
        ;~ Print("Activating windowID = " . windowID)
        ;~ Print("Activating windowTitle = " . WindowTitle%SelectedRowNumber%)
        ;~ WinActivate, ahk_id %windowID%
        ;~ Gosub, ListView_Destroy
    ;~ }
    else if A_GuiEvent = K
    {
        key := GetKeyName(Format("vk{:x}", A_EventInfo))
        PrintKV2("[K] A_EventInfo", A_EventInfo, "key", key)
        PrintKV("[K] LVE_VkCodePrev", LVE_VkCodePrev)
        
        ; Check if Shift key is down
        IsShiftKeyDown := GetKeyState("Shift", "P") or GetKeyState("Shift")
        PrintKV("IsShiftKeyDown", IsShiftKeyDown)
        
        vkCode := A_EventInfo        
        ; -----------------------------------------------------------------------------
        ; Handle AppsKey / Application Key / Menu Key
        ; There is a problem, steps
        ;   1. Display ContextMenu using AppsKey
        ;   2. Left Mouse Click on ListView (not on ContextMenu)
        ;   3. ContextMenu remains there, and AltTabAlternative is not closed.
        ; -----------------------------------------------------------------------------
        ;~ if (vkCode = GetKeyVK("AppsKey")) {
            ;~ Gosub, ListViewContextMenu
            ;~ Return
        ;~ }
        ; -----------------------------------------------------------------------------
        ; Handle F1 Function Key
        ; -----------------------------------------------------------------------------
        if (vkCode = GetKeyVK("F1")) {
            Gosub, AltTabAlternativeDestroy
            if (IsShiftKeyDown) {
                AboutDialog()
            }
            else {
                ShowHelp()
            }
            Return
        }
        ; -----------------------------------------------------------------------------
        ; Handle F2 Function Key
        ; -----------------------------------------------------------------------------
        if (vkCode = GetKeyVK("F2")) {
            Gosub, AltTabAlternativeDestroy
            ShowSettingsDialog()
            Return
        }
        else if (vkCode = GetKeyVK("Tab")) {
            if (IsShiftKeyDown) {
                Gosub, AltBacktickAlternative
            }
            else {
                Gosub, AltShiftBacktickAlternative
            }
            SBUpdateInfo("KeyPress: " . key)
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; Handle NumpadDown - 40
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadDown")) {
            if (IsAltBacktick) {
                Gosub, AltBacktickAlternative
            }
            else {
                Gosub, AltTabAlternative
            }
            SBUpdateInfo("KeyPress: " . key)
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; NumpadUp - 38
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadUp")) {
            if (IsAltBacktick) {
                Gosub, AltShiftBacktickAlternative
            }
            else {
                Gosub, AltShiftTabAlternative
            }
            SBUpdateInfo("KeyPress: " . key)
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; NumpadHome - 36, NumpadPgUp - 33
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadHome") or vkCode = GetKeyVK("NumpadPgUp")) {
            SelectedRowNumber = 1
            ;~ LV_Modify(SelectedRowNumber, "Select Vis Focus")
            ListViewSelectRow(SelectedRowNumber)
            SBUpdateInfo("KeyPress: " . key)
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; NumpadEnd - 35, NumpadPgDn - 34
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadEnd") or vkCode = GetKeyVK("NumpadPgDn")) {
            SelectedRowNumber := Window_Found_Count
            ;~ LV_Modify(SelectedRowNumber, "Select Vis Focus")
            ListViewSelectRow(SelectedRowNumber)
            SBUpdateInfo("KeyPress: " . key)
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; Handle NumpadDel to terminate selected process
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadDel")) {  ; NumpadDel - 46
            GetSelectedRowInfo()
            Print("[A_GuiEvent] SelectedRowNumber = " . SelectedRowNumber)
            windowID := Window%SelectedRowNumber%
            ownerID := WindowParent%SelectedRowNumber%
            exeName := Exe_Name%SelectedRowNumber%
            procID := PID%SelectedRowNumber%
            Print("   windowID = " . windowID)
            Print("    ownerID = " . ownerID)
            Print("windowTitle = " . WindowTitle%SelectedRowNumber%)
            Print("    exeName = " . exeName)
            Print("     procID = " . procID)
            explorerName = "explorer.exe"
            
            ; Focus will be lost from Alt+Tab main window and it may ask to save data
            ; if we specify a waittime, so it is better to not to wait.
            ; *** Never kill explorer.exe forcefully
            if (exeName <> "explorer.exe" && IsShiftKeyDown) {
                Print("Shift+Del pressed")
                KillProcessForcefully(procID)
                Sleep, 50
            }
            else {
                ; User ownerID to terminate window, otherwise topmost popwindow will be
                ; closed instead of process/main window.
                Print("NumpadDel pressed")
                ; Do NOT use WinClose, because
                ; WinClose sends a WM_CLOSE message to the target window, which is a somewhat
                ; forceful method of closing it. An alternate method of closing is to send the
                ; following message.
                ; It might produce different behavior because it is similar in effect to
                ; pressing Alt-F4 or clicking the window's close button in its title bar:
                ; Now, skype, jabber won't get killed on pressing NumpadDel key
                ;~ WinClose, ahk_id %ownerID%
                ;~ PostMessage, 0x112, 0xF060, , , ahk_id %windowID%  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
                Print("A_DetectHiddenWindows = " . A_DetectHiddenWindows)
                TerminateWindow(windowID)
                Sleep, 50
            }

            LV_Delete(SelectedRowNumber)

            if (SelectedRowNumber = Window_Found_Count) {
                SelectedRowNumber := Window_Found_Count - 1
            }

            Gosub, DisplayList
            WinActivate, ahk_id %MainWindowHwnd%
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; Handle NumpadDiv to terminate all processes
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadDiv")) {  ; NumpadDiv - 111
            ; I think, it is better to turn off IncrementalSearch before terminating
            ;   window, and enable it after completion of all windows list.
            ; And, traverse windows list in reverse order, when a listview item gets
            ;   deleted, no need to redraw remaining items of listview.
            
            ;~ if (IsShiftKeyDown) {
                ;~ Print("[ListViewEvent] Shift+NumpadDiv pressed")
            ;~ }
            ;~ else {
                ;~ Print("[ListViewEvent] NumpadDiv")
            ;~ }

            Gosub, DisableIncrementalSearch

            ; Prompts for confirmation before terminating
            if (PromptTerminateAll) {
                Gui, +OwnDialogs    ; To display a modal dialog
                ;   0x4 : Yes/No
                ;  0x20 : Icon Question
                ; 0x100 : Makes the 2nd button the default
                if (IsShiftKeyDown) {
                    MsgBox, 292, AltTabAlternative: Kill All Processes, Are you sure you want to kill all processes?
                }
                else {
                    MsgBox, 292, AltTabAlternative: Close All Windows, Are you sure you want to close all windows?
                }
                
                IfMsgBox, No
                {
                    Gosub, EnableIncrementalSearch
                    return
                }                
            }

            Loop, %Window_Found_Count%
            {
                windowID := Window%A_Index%
                index := Window_Found_Count - A_Index + 1
                ;~ PrintKV3("[ListViewEvent, NumpadDiv] A_Index", A_Index , "PID", PID%A_Index%, "windowTitle", WindowTitle%A_Index%)
                PrintKV3("[ListViewEvent, NumpadDiv] index", index, "PID", PID%index%, "windowTitle", WindowTitle%index%)

                if (IsShiftKeyDown) {
                    ;~ Print("[ListViewEvent] Shift+NumpadDiv pressed")
                    KillProcessForcefully(PID%index%)
                }
                else {
                    ;~ Print("[ListViewEvent] NumpadDiv")
                    TerminateWindow(windowID)
                }
                LV_Delete(index)
            }
            
            ; Set Window_Found_Count to 0, then only ListView gets updated with new windows
            Window_Found_Count := 0
            Gosub, EnableIncrementalSearch
        }
        else if (vkCode = GetKeyVK("``")) {  ; Backtick (`) - 192/vkc0
            Print("[LVEvent:Backtick] Backtick pressed")
            Print("[LVEvent:Backtick] SelectedRowNumber = " . SelectedRowNumber)
            windowID := Window%SelectedRowNumber%
            ownerID := WindowParent%SelectedRowNumber%
            exeName := Exe_Name%SelectedRowNumber%
            procID := PID%SelectedRowNumber%
            Print("   windowID = " . windowID)
            Print("    ownerID = " . ownerID)
            Print("windowTitle = " . WindowTitle%SelectedRowNumber%)
            Print("    exeName = " . exeName)
            Print("     procID = " . procID)
            
            ProcessDictListIndex := GetProcessDictListIndex(ProcessDictList, exeName)
            
            ; Get next/prev row number of process exeName
            if (IsShiftKeyDown) {
                SelectedRowNumber := GetPrevRowInfoOfSameProcess()
            }
            else {
                SelectedRowNumber := GetNextRowInfoOfSameProcess()
            }
            
            ;~ LV_Modify(SelectedRowNumber, "Select Vis Focus")
            ListViewSelectRow(SelectedRowNumber)
            SBUpdateInfo("KeyPress: " . "Backtick")
            LVE_VkCodePrev := vkCode
            Return
            
        }
        
        IsCtrlKeyDown := GetKeyState("Ctrl", "P") or GetKeyState("Ctrl")
        PrintKV("IsCtrlKeyDown", IsCtrlKeyDown)

        ; If a digit is pressed along with control (Ctrl+Num)
        if (IsCtrlKeyDown && (vkCode >= 48 && vkCode <= 57)) {
            ; TODO: activate that nth window and close
            Print("--- Ctrl+Num")
        }
        
        ; -----------------------------------------------------------------------------
        ; If control comes to here means:
        ; User has entered AlphaNumerics to search/filter processes
        ; Note: Always getting lower case letters even the capslock is turned on
        ; Hence, no need to check for upper case letters.
        ; -----------------------------------------------------------------------------
        if ((vkCode >= 65 && vkCode <= 90) || (vkCode >= 48 && vkCode <= 57)) {
            IsCapsLockKeyDown := GetKeyState("CapsLock", "T")
            if ((IsShiftKeyDown && !IsCapsLockKeyDown) ||(!IsShiftKeyDown && IsCapsLockKeyDown)) {
                StringUpper, key, key
            }
            
            ;~ Print("Key is alnum")
            SBUpdateInfo("KeyPress: " . key)
            NewSearchString := NewSearchString . key
            SelectedRowNumber := 1
        }        
        else if (vkCode = 8) { ; Backspace
            ;~ Print("Key is Backspace")
            SBUpdateInfo("KeyPress: Backspace")
            NewSearchString := SubStr(NewSearchString, 1, StrLen(NewSearchString) - 1)
            SelectedRowNumber := 1
        }
        ;~ PrintKV("[ListViewEvent] NewSearchString", NewSearchString)
        ;~ SB_SetText("SearchString: " . NewSearchString)
        SearchStringText := (NewSearchString = "" ? "Search String: empty" : "Search String: " . NewSearchString)
        ControlSetText, Static1, %SearchStringText%
        
        LVE_VkCodePrev := vkCode
    }
Return


ListViewSelectRow(RowNumber)
{
    LV_Modify(RowNumber, "Select Vis Focus")
    ;~ SBUpdateInfo()
    SBUpdatePID()
    SBUpdateActiveWindowPos()
}

IsAlpha(x) {
   If x is Alpha
      Return 1
   Return 0
}

IsNum(x) {
   If x is Number
      Return 1
   Return 0
}

IsAlNum(x) {
   If x is alnum
      Return 1
   Return 0
}

IsSymbol(x) {
   List = 43,45,47,61
   x := Asc(x)
   If List contains %x%
      Return 1
   Return 0
}


; -----------------------------------------------------------------------------
; AltTabAlternative Destory
; Disable all the hotkeys listed below that are enabled when Alt+Tab /
;  Alt+Shift+Tab is pressed.
;  * Alt+Esc Key
;  * ContextSensitive Keys (to hide/unhide windows)
; -----------------------------------------------------------------------------
AltTabAlternativeDestroy:
    PrintSub("AltTabAlternativeDestroy Begin")
    PrintKV("AltTabAlternativeDestroy: ActivateWindow", ActivateWindow)
    Gui, 1: Default
    Gosub, DisableTimers
    ToggleAltEscHotkey("Off")
    ToggleATACSHotkeys("Off")
    
    ; Toggle on all the hotkeys / invoke initialize hotkeys label.
    ToggleAltTabHotkeys("On")
    ToggleAltBacktickHotkeys("On")
    
    ; Save the hidden windows information into file
    Gosub, HiddenWindowsFileSave
    
    ; First check for AltEsc
    if (AltEscPressed = 1) {
        Gui, 1: Destroy
    }    
    else if (ActivateWindow) {
        ActivateWindow := false
        GetSelectedRowInfo()
        PrintKV("SelectedRowNumber", SelectedRowNumber)
        windowID := Window%SelectedRowNumber%
        PrintKV("Activating windowID", windowID)`
        PrintKV("Activating windowTitle", WindowTitle%SelectedRowNumber%)
        Gui, 1: Destroy
        WinActivate, ahk_id %windowID%
    }
    else {
        Gui, 1: Destroy
    }
    DisplayListShown := 0
    PrintSub("AltTabAlternativeDestroy End")
Return
    
; -----------------------------------------------------------------------------
; Returns the screen center X
; -----------------------------------------------------------------------------
GuiCenterX()
{
    Global WindowWidth
    Coordmode, Mouse, Screen
    MouseGetPos, x, y
    SysGet, m, MonitorCount
    ; Iterate through all monitors.
    Loop, %m%
    {   ; Check if the window is on this monitor.
        SysGet, Mon, Monitor, %A_Index%
        if (x >= MonLeft && x <= MonRight && y >= MonTop && y <= MonBottom)
        {
            return (0.5 * (MonRight - MonLeft) + MonLeft - WindowWidth / 2)
        }
    }
}


; -----------------------------------------------------------------------------
; Store the windowID, Process Name/Path/ID and etc of the given WindowID.
; -----------------------------------------------------------------------------
WindowStoreAttributes(index, windowID, ownerID) 
{
    Local State_temp
    ;~ PrintSub("WindowStoreAttributes")
    ;~ PrintKV3("[WindowStoreAttributes] index", index, "windowID", windowID, "ownerID", ownerID)
    WinGetTitle, windowTitle, ahk_id %ownerID%
    WinGet, procPath, ProcessPath, ahk_id %windowID%
    WinGet, procName, ProcessName, ahk_id %windowID%
    WinGet, procID, PID, ahk_id %windowID%
    
    Window%index%        := windowID        ; Store ahk_id's to a list
    WindowParent%index%  := ownerID         ; Store Parent ahk_id's to a list to later see if window is owned
    WindowTitle%index%   := windowTitle     ; Store titles to a list
    hw_popup%index%      := hw_popup        ; Store the active popup window to a list (eg the find window in notepad)
    Exe_Name%index%      := procName        ; Store the process name
    Exe_Path%index%      := procPath        ; Store the process path
    PID%index%           := procID          ; Store the process id
    Dialog%index%        := Dialog          ; S if found a Dialog window, else 0

    ; If ShowHiddenWindows is turned ON, WM_NOTIFY will be set.
    ; Hence, the colors passed to LV_ColorChange should be BGR format colors.
    if (ShowHiddenWindows) {
        if (HiddenWindowList.HasKey(windowID)) {
            PrintKV("[WindowStoreAttributes] Applying HideWindow Colors to WindowID", WindowID)
            LV_ColorChange(index, ListViewHWFontColorBGR, ListViewHWBackgroundColorBGR)
        }
    }

    if (!true) {
        Print("[WindowStoreAttributes] -------------------------------------------")
        Print("[WindowStoreAttributes]       Index = " . index)
        Print("[WindowStoreAttributes]    WindowID = " . windowID)
        Print("[WindowStoreAttributes]     OwnerID = " . ownerID)
        Print("[WindowStoreAttributes] WindowTitle = " . windowTitle)
        Print("[WindowStoreAttributes]    ProcName = " . procName)
        Print("[WindowStoreAttributes]      ProcID = " . procID)
        Print("[WindowStoreAttributes] -------------------------------------------")
    }
}


; -----------------------------------------------------------------------------
; GetSelectedRowInfo
; -----------------------------------------------------------------------------
GetSelectedRowInfo()
{
    Global
    PrintSub("GetSelectedRowInfo")
    
    SelectedRowNumber := LV_GetNext(0, "F")
    Local WindowID := Window%SelectedRowNumber%
    SelectedProcName := Exe_Name%SelectedRowNumber%
    
    PrintKV("[GetSelectedRowInfo] SelectedRowNumber", SelectedRowNumber)
    PrintKV("[GetSelectedRowInfo]          WindowID", WindowID)
    PrintKV("[GetSelectedRowInfo]  SelectedProcName", SelectedProcName)

    ; Get the row's 2nd column's text for real order number (hidden column).
    LV_GetText(RowText, SelectedWinNumber, 2)
}


PrintSelectedRowInfo()
{
    PrintSub("PrintSelectedRowInfo")    
    SelectedRowNumber := LV_GetNext(0, "F")
    WindowID := Window%SelectedRowNumber%
    PrintKV("[PrintSelectedRowInfo] SelectedRowNumber", SelectedRowNumber)
    PrintKV("[PrintSelectedRowInfo]          WindowID", WindowID)
}


; -----------------------------------------------------------------------------
; ListViewResizeVertically
; -----------------------------------------------------------------------------
ListViewResizeVertically(Gui_ID) ; Automatically resize listview vertically
{
    Global Window_Found_Count, lv_h_win_2000_adj
    PrintSub("ListViewResizeVertically")
    if (Window_Found_Count = 0) {
        itemsCount := 1
        LV_Add("", "", "", "", "")
    }
    else {
        itemsCount := Window_Found_Count
    }
    
    SendMessage, 0x1000+31, 0, 0, SysListView321, ahk_id %Gui_ID% ; LVM_GETHEADER
    WinGetPos,,,, lv_header_h, ahk_id %ErrorLevel%
    VarSetCapacity(rect, 16, 0)
    SendMessage, 0x1000+14, 0, &rect, SysListView321, ahk_id %Gui_ID% ; LVM_GETITEMRECT ; LVIR_BOUNDS
    ;~ Print("rect = " . &rect)
    y1 := 0
    y2 := 0
    Loop, 4
    {
        ;~ Print("*( &rect + 3 + A_Index ) = " . *( &rect + 3 + A_Index ))
        ;~ Print("*( &rect + 11 + A_Index ) = " . *( &rect + 11 + A_Index ))
        y1 += *(&rect + 3 + A_Index)
        y2 += *(&rect + 11 + A_Index)
    }
    ;~ Print("y1 = " . y1)
    ;~ Print("y2 = " . y2)
    lv_row_h := y2 - y1
    lv_row_h := (lv_row_h < 0 ? 24 : lv_row_h)
    ;~ Print("lv_row_h = " . lv_row_h)
    ;~ Print("lv_header_h = " . lv_header_h)
    ;~ Print("lv_row_h = " . lv_row_h)
    ;~ Print("Window_Found_Count = " . Window_Found_Count)
    ;~ Print("lv_h_win_2000_adj = " . lv_h_win_2000_adj)
    lv_h := 4 + lv_header_h + ( lv_row_h * itemsCount ) + lv_h_win_2000_adj
    ; tab_y := lv_h - 6
    ; Tooltip % lv_header_h
    ;~ Print("lv_h = " . lv_h)
    GuiControl, Move, SysListView321, h%lv_h%
    ; GuiControl, Move, Gui1_Tab, y%tab_y%
}


; -----------------------------------------------------------------------------
; Automatically conduct real-time incremental search to find matching records
; without waiting for user
; -----------------------------------------------------------------------------
tIncrementalSearch:
    ;~ Print("tIncrementalSearch")
    Loop
    ; REPEAT SEARCHING UNTIL USER HAS STOPPED CHANGING THE QUERY STRING
    {
        ;~ Gui, %MainWindowHwnd%:Submit, NoHide
        ; TODO
        If (CurSearchString <> NewSearchString) {
            Print("CurSearchString = [" . CurSearchString . "], NewSearchString = [" . NewSearchString . "]")
            ;~ OpenTarget =
            CurSearchString := NewSearchString
            Gosub, DisplayList
            ;~ Sleep, 100 ; DON'T HOG THE CPU!
            ;~ If OpenTarget <>			
                FileAppend, [tIncrementalSearch] OpenTarget is not empty`n, *
                ;~ GuiControl, 1:Choose, OpenTarget, |1
        }
        Else
        {
            ; If any new process found, then display ListView with new windows
            ; list with resize and position the window center.
            ; Do not resize the window if any process terminated.
            tWindowsCount := GetWindowsCount(CurSearchString)
            if (tWindowsCount != Window_Found_Count) {
                PrintKV2("tWindowsCount", tWindowsCount, "Window_Found_Count", Window_Found_Count)
            }
            if (tWindowsCount > Window_Found_Count) {
                Gosub, DisplayList
                Gosub, GuiResizeAndPosition
                Gosub, ShowWindow
            } else if (tWindowsCount < Window_Found_Count) {
                Gosub, DisplayList
            }
            else {
                ; QUERY STRING HAS STOPPED CHANGING
                Break
            }
        }
    }

    ; USER HAS HIT <ENTER> TO LOOK FOR MATCHING RECORDS.
    ; RUN FindMatches NOW.
    If ResumeFindMatches = TRUE
    {
        ResumeFindMatches = FALSE
        ;~ Gosub FindMatches
    }

    ; CONTINUE MONITORING FOR CHANGES
    SetTimer, tIncrementalSearch, 100
Return


; -----------------------------------------------------------------------------
; Disable Timers
; -----------------------------------------------------------------------------
DisableTimers:
    PrintSub("DisableTimers")
    SetTimer, CheckAltHotkeyUp, Off
    SetTimer, tIncrementalSearch, Off    
Return
    
; -----------------------------------------------------------------------------
; Disable IncrementalSearch
; -----------------------------------------------------------------------------
DisableIncrementalSearch:
    PrintSub("DisableIncrementalSearch")
    SetTimer, tIncrementalSearch, Off    
Return
    
; -----------------------------------------------------------------------------
; Enable IncrementalSearch
; -----------------------------------------------------------------------------
EnableIncrementalSearch:
    PrintSub("EnableIncrementalSearch")
    SetTimer, tIncrementalSearch, On    
Return


; -----------------------------------------------------------------------------
; Handle Up/Down when the are pressed in Filename Edit Control
; Select the ListBox items or move the selection to up/down when
;  Up/Down keys are pressed.
; -----------------------------------------------------------------------------
OnKeyDown(wParam, lParam, msg, hwnd)
{
    Global
    PrintFunc(A_ThisFunc)
    ;~ Global ListView1
    key := Format("vk{1:x}", wParam)
    keyName := GetKeyName(key)
    FileAppend, [OnKeyDown] wParam = [%wParam% %keyName%] lParam = [%lParam%] msg = [%msg%] hwnd = [%hwnd%]`n, *

    nItems := LV_GetCount()
    if (wParam = GetKeyVK("Control")) {
        CtrlBtnDown := true
        Print("CtrlBtnDown := true")
    }
    else if (wParam >= 48 && wParam <= 57) {    ; Number Key (not Numpad key)
        NumberBtnDown := true
        NumberBtnValue := (keyName = 0 ? 10 : keyName)
        Print("NumberBtnDown := true, NumberBtnValue = " . NumberBtnValue)
    }
    
    if (CtrlBtnDown && NumberBtnDown && (NumberBtnValue >= 1 && NumberBtnValue <= 10)) {
        Print("CtrlBtnDown && NumberBtnDown, NumberBtnValue = " . NumberBtnValue)
        windowID := Window%NumberBtnValue%
        ;~ Print("windowID = " . windowID)
        WinActivate, ahk_id %windowID%
        Gosub, AltTabAlternativeDestroy
    }

    if (hwnd = ListView1Hwnd) {
        nItems := LV_GetCount()
        ;~ Print("Current SelectedRowNumber = " . SelectedRowNumber)
        if (wParam = GetKeyVK("Esc")) {
            ;~ Print("[OnKeyDown] ListView1Hwnd: Esc key pressed.")
            Gosub, AltTabAlternativeDestroy
        }
        else if (wParam = GetKeyVK("Enter") and SelectedRowNumber <> 0) {
            ;~ Print("Opening...")
            windowID := Window%SelectedRowNumber%
            ;~ Print("windowID = " . windowID)
            WinActivate, ahk_id %windowID%
            Gosub, AltTabAlternativeDestroy
        }
        else if (wParam = GetKeyVK("Down")) {
            SelectedRowNumber := (SelectedRowNumber >= nItems ? 1 : (SelectedRowNumber + 1))
            LV_Modify(SelectedRowNumber, "Select Vis")
            ;~ Print("LV_Modify")
        }
        else if (wParam = GetKeyVK("Up")) {
            SelectedRowNumber := (SelectedRowNumber <= 1 ? nItems : (SelectedRowNumber - 1))
            LV_Modify(SelectedRowNumber, "Select Vis")
            ;~ Print("LV_Modify")
        }
        ;~ Print("New SelectedRowNumber = " . SelectedRowNumber)
    }
}


; -----------------------------------------------------------------------------
; OnKeyUp
; -----------------------------------------------------------------------------
OnKeyUp(wParam, lParam, msg, hwnd) {
    Global
    ;~ Global ListView1
    key := Format("vk{1:x}", wParam)
    keyName := GetKeyName(key)
    FileAppend, [OnKeyUp] wParam = [%wParam% %keyName%] lParam = [%lParam%] msg = [%msg%] hwnd = [%hwnd%]`n, *
}


; -----------------------------------------------------------------------------
; Gives the windows icon of a given windowID
; -----------------------------------------------------------------------------
GetWindowIcon(windowID, UseLargeIconsCurrent) ; (window id, whether to get large icons)
{
    Local NR_temp, h_icon
    ; check status of window - if window is responding or "Not Responding"
    NR_temp = 0 ; init
    h_icon =
    Responding := DllCall("SendMessageTimeout", "UInt", windowID, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", NR_temp) ; 150 = timeout in millisecs
    If (Responding) {
        ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
        If (UseLargeIconsCurrent = 1) {
            SendMessage, 0x7F, 1, 0,, ahk_id %windowID%
            h_icon := ErrorLevel
        }
        If (!h_icon) {
            SendMessage, 0x7F, 2, 0,, ahk_id %windowID%
            h_icon := ErrorLevel
            If (!h_icon) {
                SendMessage, 0x7F, 0, 0,, ahk_id %windowID%
                h_icon := ErrorLevel
                If (!h_icon) {
                    If UseLargeIconsCurrent = 1
                        h_icon := DllCall( GetClassLong_API, "uint", windowID, "int", -14 )  ; GCL_HICON is -14
                    If (!h_icon) {
                        h_icon := DllCall( GetClassLong_API, "uint", windowID, "int", -34 )  ; GCL_HICONSM is -34
                        If (!h_icon) {
                            h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 )   ; IDI_APPLICATION is 32512
                        }
                    }
                }
            }
        }
    }
    
    If (!(h_icon = "" or h_icon = "FAIL")) {
        ; Add the HICON directly to the icon list
        ;~ Print("Got icon, Add the HICON directly to the icon list")
        Gui_Icon_Number := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon)
    }
    Else { ; use a generic icon
        Gui_Icon_Number := IL_Add(ImageListID1, "shell32.dll" , 3)
    }
    ;~ Print("Gui_Icon_Number = " . Gui_Icon_Number)
}


; -----------------------------------------------------------------------------
; Resize and position
; -----------------------------------------------------------------------------
GuiResizeAndPosition:
    PrintSub("GuiResizeAndPosition")
    DetectHiddenWindows, On ; retrieving column widths to enable calculation of col 3 width
    Gui, +LastFound
    
    If (true) ; resize listview columns - no need to resize columns for updating listview
    {
        LV_ModifyCol(1, Col_1) ; icon column
        LV_ModifyCol(2, Col_2) ; hidden column for row number
        ; col 3 - see below
        LV_ModifyCol(4, Col_4) ; exe
        SendMessage, 0x1000+29, 3, 0,, ahk_id %ListView1Hwnd% ; LVM_GETCOLUMNWIDTH is 0x1000+29
        Width_Column_4 := ErrorLevel
        Width_Column_4 := Width_Column_4 < Col_4_Width_Min ? Col_4_Width_Min : (Width_Column_4 > Col_4_Width_Max ? Col_4_Width_Max : Width_Column_4)
        LV_ModifyCol(4, Width_Column_4) ; resize title column

        Loop, 4
        {
            SendMessage, 0x1000+29, A_Index - 1, 0,, ahk_id %ListView1Hwnd% ; LVM_GETCOLUMNWIDTH is 0x1000+29
            Width_Column_%A_Index% := ErrorLevel
            Print("Width_Column_" . A_Index . " = " . Width_Column_%A_Index%)
        }

        Col_3_w := WindowWidth - Width_Column_1 - Width_Column_2 - Width_Column_4 - 4 ; total width of columns - 4 for border
        LV_ModifyCol(3, Col_3_w) ; resize title column
    }
    
    Gui_ID := WinExist() ; for auto-sizing columns later
    ;~ Print("Gui_ID = " . Gui_ID)
    ListViewResizeVertically(Gui_ID) ; Automatically resize listview vertically - pass the gui id value

    GuiControlGet, Listview_Now, Pos, ListView1 ; retrieve listview dimensions/position ; for auto-sizing (elsewhere)
    ; resize listview according to scrollbar presence
    ; If (Listview_NowH > WindowHeightMax AND UseLargeIconsCurrent =0) ; already using small icons so limit height
    If (Listview_NowH > WindowHeightMax) ; limit height to specified fraction of window size
    {
        Col_3_w -= ScrollbarVerticalThickness ; allow for vertical scrollbar being visible
        LV_ModifyCol(3, Col_3_w) ; resize title column
        ; GuiControl, MoveDraw, Gui1_Tab
        GuiControl, Move, ListView1, h%WindowHeightMax%
    }
    DetectHiddenWindows, Off
Return


; -----------------------------------------------------------------------------
; Resize the ListView columns width
; -----------------------------------------------------------------------------
GuiResizeListViewColumnSize:
    DetectHiddenWindows, On ; retrieving column widths to enable calculation of col 3 width
    Gui, +LastFound
    
    LV_ModifyCol(1, Col_1) ; icon column
    LV_ModifyCol(2, Col_2) ; hidden column for row number
    ; col 3 - see below
    LV_ModifyCol(4, Col_4) ; exe
    SendMessage, 0x1000+29, 3, 0,, ahk_id %ListView1Hwnd% ; LVM_GETCOLUMNWIDTH is 0x1000+29
    Width_Column_4 := ErrorLevel
    If Width_Column_4 > %ExeWidthMax%
    LV_ModifyCol(4, ExeWidthMax) ; resize title column

    Loop, 4
    {
        SendMessage, 0x1000+29, A_Index - 1, 0,, ahk_id %ListView1Hwnd% ; LVM_GETCOLUMNWIDTH is 0x1000+29
        Width_Column_%A_Index% := ErrorLevel
        ;~ Print("Width_Column_" . A_Index . " = " . Width_Column_%A_Index%)
    }

    Col_3_w := WindowWidth - Width_Column_1 - Width_Column_2 - Width_Column_4 - 4 ; total width of columns - 4 for border
    LV_ModifyCol(3, Col_3_w) ; resize title column
    
    ;~ Gui_ID := WinExist() ; for auto-sizing columns later
    Print("Gui_ID = " . Gui_ID)
    ListViewResizeVertically(Gui_ID) ; Automatically resize listview vertically - pass the gui id value

    GuiControlGet, Listview_Now, Pos, ListView1 ; retrieve listview dimensions/position ; for auto-sizing (elsewhere)
    ; Resize listview according to scrollbar presence
    ; If (Listview_NowH > WindowHeightMax AND UseLargeIconsCurrent =0) ; already using small icons so limit height
    If (Listview_NowH > WindowHeightMax) ; limit height to specified fraction of window size
    {
        Col_3_w -= ScrollbarVerticalThickness ; allow for vertical scrollbar being visible
        LV_ModifyCol(3, Col_3_w) ; resize title column
        ; GuiControl, MoveDraw, Gui1_Tab
        GuiControl, Move, ListView1, h%WindowHeightMax%
    }
    DetectHiddenWindows, Off
Return


; -----------------------------------------------------------------------------
; Returns the hex format of the given decimal
; -----------------------------------------------------------------------------
DecimalToHex(var) {
    SetFormat, IntegerFast, H
    var += 0 
    var .= ""
    SetFormat, Integer, D
    return var
}


; -----------------------------------------------------------------------------
; DWMWA_CLOAKED: If the window is cloaked, the following values explain why:
; 1  The window was cloaked by its owner application (DWM_CLOAKED_APP)
; 2  The window was cloaked by the Shell (DWM_CLOAKED_SHELL)
; 4  The cloak value was inherited from its owner window (DWM_CLOAKED_INHERITED)
; -----------------------------------------------------------------------------
IsInvisibleWin10BackgroundAppWindow(hWindow) {
    result := 0
    VarSetCapacity(cloakedVal, A_PtrSize) ; DWMWA_CLOAKED := 14
    hr := DllCall("DwmApi\DwmGetWindowAttribute", "Ptr", hWindow, "UInt", 14, "Ptr", &cloakedVal, "UInt", A_PtrSize)
    if !hr ; returns S_OK (which is zero) on success. Otherwise, it returns an HRESULT error code
    result := NumGet(cloakedVal) ; omitting the "&" performs better
    return result ? true : false
}


; -----------------------------------------------------------------------------
; 
; -----------------------------------------------------------------------------
LV_SetSI(hList, iItem, iSubItem, iImage) {
    Print("LV_SetSI")
	VarSetCapacity(LVITEM, 13 * 4 + 2 + A_PtrSize, 0)
	LVM_SETITEM := 0x1006, mask := 2    ; LVIF_IMAGE := 0x2
	iItem-- , iSubItem-- , iImage--		; Note first column (iSubItem) is #ZERO, hence adjustment
	NumPut(mask, LVITEM, 0, "UInt")
	NumPut(iItem, LVITEM, 4, "Int")
	NumPut(iSubItem, LVITEM, 8, "Int")
	NumPut(iImage, LVITEM, 28 + A_PtrSize, "Int")
	result := DllCall("SendMessage", UInt, hList, UInt, LVM_SETITEM, UInt, 0, UInt, &LVITEM)
	SendMessage, LVM_SETITEM, -1, &LVITEM, , ahk_id %hList%
	return result
}


; -----------------------------------------------------------------------------
; Returns the number of windows
; Do NOT worry about the deletion of windows from the HiddenWindowList, this
;   function will take care of it.
; -----------------------------------------------------------------------------
GetWindowsCount(SearchString:="", SearchInTitle:=true, SearchInProcName:=true) {
    Global WS_EX_APPWINDOW, WS_EX_TOOLWINDOW, GW_OWNER
    Global BacktickFilterWindows
    Global BacktickProcName
    Global ProcessDictListIndex
    Global ProcessDictList
    windowList =
    windowFoundCount := 0
    
    ;~ PrintKV2("[GetWindowsCount] ProcessDictListIndex", ProcessDictListIndex, "BacktickProcName", BacktickProcName)
    
    DetectHiddenWindows, Off ; makes DllCall("IsWindowVisible") unnecessary
    
    WinGet, windowList, list, , , Program Manager   ; gather a list of running programs
    Loop, %windowList%
    {
        ownerID := windowID := windowList%A_Index%
        
        Loop {
            ownerID := DecimalToHex(DllCall("GetWindow", "UInt", ownerID, "UInt", GW_OWNER))
        } Until !DecimalToHex(DllCall("GetWindow", "UInt", ownerID, "UInt", GW_OWNER))
        
        ownerID := ownerID ? ownerID : windowID
        
        If (DecimalToHex(DllCall("GetLastActivePopup", "UInt", ownerID)) = windowID)
        {
            WinGet, windowES, ExStyle, ahk_id %windowID%
            WinGet, ownerES, ExStyle, ahk_id %ownerID%
            
            isAltTabWindow := false
            if (ownerES && !((ownerES & WS_EX_TOOLWINDOW) && !(ownerES & WS_EX_APPWINDOW)) && !IsInvisibleWin10BackgroundAppWindow(ownerID)) {
                isAltTabWindow := true
                WinGetTitle, ownerTitle, ahk_id %ownerID%
                ;~ PrintKV("Title", OwnerTitle)
                title := OwnerTitle
            }
            else if (windowES && !((windowES & WS_EX_TOOLWINDOW) && !(windowES & WS_EX_APPWINDOW)) && !IsInvisibleWin10BackgroundAppWindow(windowID)) {
                isAltTabWindow := true
                WinGetTitle, windowTitle, ahk_id %windowID%
                if (windowTitle = "") {
                    WinGetTitle, windowTitle, ahk_id %ownerID%
                }
                title := WindowTitle
                ;~ PrintKV("Title", WindowTitle)
            }
            else if (windowES = 0x0 && ownerES = 0x0) {
                ; I have no idea why the windowES or ownerES are 0x0 when watching videos in fullscreen
                ; mode in Google Chrome / Internet Explorer and etc, but getting the title correctly.
                ;~ FileAppend, windowES = 0x0 && ownerES = 0x0`n, *
                isAltTabWindow := true
                WinGetTitle, windowTitle, ahk_id %windowID%
                if (windowTitle = "") {
                    WinGetTitle, windowTitle, ahk_id %ownerID%
                }
                title := WindowTitle
            }

            if (isAltTabWindow)
            {
                WinGet, procName, ProcessName, ahk_id %windowID%
                ;~ bIsValidProc := (procName = BacktickProcName)
                    ;~ || (ProcessDictListIndex != -1 && ProcessDictList[ProcessDictListIndex].HasKey(procName))
                ;~ PrintKV2("[GetWindowsCount] procName", procName, "bIsValidProc", bIsValidProc)
                
                ; If Alt+Backtick is pressed and BacktickFilterWindows is true, then filter
                ;   only the windows of the same application.
                ; Use the BacktickProcName that is used to filter the windows when
                ;   Alt+Backtick is pressed.
                if (IsAltBacktick && BacktickFilterWindows) {
                    bIsValidProc := (procName = BacktickProcName)
                        || (ProcessDictListIndex != -1 && ProcessDictList[ProcessDictListIndex].HasKey(procName))
                    if (not bIsValidProc) {
                        continue
                    }
                }
                
                ;~ FileAppend, A_Index = [%A_Index%] title = [%title%]`, processName = [%procName%]`n, *
                ;~ Print("SearchString = " . SearchString)
                ok := false
                if (SearchString = "") {
                    ok := true
                } else if (SearchInTitle and SearchInProcName) {
                    if (InStr(title, SearchString, false) != 0 or InStr(procName, SearchString, false) != 0) {
                        ok := true
                    }
                } else if (SearchInTitle) {
                    if (InStr(title, SearchString, false) != 0) {
                        ok := true
                    }
                } else if (SearchInProcName) {
                    if (InStr(procName, SearchString, false) != 0) {
                        ok := true
                    }
                }
                
                if (ok) {
                    windowFoundCount += 1
                } else {
                    ;~ FileAppend, Filtered: A_Index = [%A_Index%] title = [%title%]`, processName = [%procName%]`n, *
                }
            }
        }
    } ; Loop ends here!
    
    if (ShowHiddenWindows) {
        ;~ HiddenWindowListLen := GetDictLength(HiddenWindowList)
        ;~ PrintKV("[GetWindowsCount] HiddenWindowListLen", HiddenWindowListLen)        
        DetectHiddenWindows, On
        for WindowID, WindowInfo in HiddenWindowList {
            if (IsHiddenWindowExist(WindowInfo.WindowID)) {
                windowFoundCount += 1
            }
            else {
                HiddenWindowList.Delete(WindowID)
            }
        }
        DetectHiddenWindows, Off
    }

    ;~ PrintKV("[GetWindowsCount] windowFoundCount", windowFoundCount)
    ;~ ExitApp
    return windowFoundCount
}


; -----------------------------------------------------------------------------
; Terminate a process based on given WindowID
;
; Do NOT use WinClose, because
;   WinClose sends a WM_CLOSE message to the target window, which is a somewhat
;   forceful method of closing it. An alternate method of closing is to send the
;   following message.
;
; It might produce different behavior because it is similar in effect to
;   pressing Alt-F4 or clicking the window's close button in its title bar:
;
; Now, skype, jabber won't get killed on pressing NumpadDel key
; -----------------------------------------------------------------------------
TerminateWindow(windowID) {
    ;~ WinClose, ahk_id %windowID%
    if (HiddenWindowList.HasKey(windowID)) {
        Print("[TerminateWindow] INFO: You can NOT close hidden window.")
        SB_SetText("You can NOT close hidden window")
        Return
    }
    PostMessage, 0x112, 0xF060, , , ahk_id %windowID%  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
    SB_SetText("Sent SC_CLOSE message on window")
    ;~ Sleep, 50
}


; -----------------------------------------------------------------------------
; Kill the given process forcefully
; -----------------------------------------------------------------------------
KillProcessForcefully(procID) {
    PrintKV("Forcefully kill PID = ", procID)
    KillCmd := "TASKKILL /PID " . procID . " /T /F"
    PrintKV("KillCmd", KillCmd)
    RunWait, %KillCmd%, , Hide
}


; -----------------------------------------------------------------------------
; Hide Window
; -----------------------------------------------------------------------------
HideWindow(windowID) {
    WinHide, ahk_id %windowID%
}


; -----------------------------------------------------------------------------
; Show/UnHide Window
; -----------------------------------------------------------------------------
ShowWindow(windowID) {
    WinShow, ahk_id %windowID%
}


; -----------------------------------------------------------------------------
; Create RowData record from WindowInfo structure
; WindowInfo Definition
;   WindowInfo := {}
;   WindowInfo.WindowID := 0xd066c
;   WindowInfo.OwnerID  := 0xd066c
;   WindowInfo.Title    := "Untitled - Notepad, Lokesh Govindu"
;   WindowInfo.ProcName := "notepad.exe"
;   WindowInfo.ProcID   := 7740
; -----------------------------------------------------------------------------
CreateHiddenWindowRowData(wi)
{
    rowdata := wi.WindowID . "," . wi.OwnerID . "," . Format4CSV(wi.Title) . "," . Format4CSV(wi.ProcName) . "," . wi.ProcID
    return rowdata
}


; -----------------------------------------------------------------------------
; Print WindowInfo on stdout
; -----------------------------------------------------------------------------
PrintWindowInfo(wi) {
    Print("[PrintWindowInfo] ---------------------------------------------")
    Print("[PrintWindowInfo]     WindowID = " . wi.WindowID)
    Print("[PrintWindowInfo]      OwnerID = " . wi.OwnerID)
    Print("[PrintWindowInfo]  WindowTitle = " . wi.Title)
    Print("[PrintWindowInfo]     ProcName = " . wi.ProcName)
    Print("[PrintWindowInfo]       ProcID = " . wi.ProcID)
    Print("[PrintWindowInfo] ---------------------------------------------")
}

; -----------------------------------------------------------------------------
; Open HiddenWindowFile
; -----------------------------------------------------------------------------
HiddenWindowsFileOpen:
    PrintSub("HiddenWindowsFileOpen")
    HiddenWindowsFileOpenFun()
Return

HiddenWindowsFileOpenFun()
{
    Global HiddenWindowsFilePath
    Global HiddenWindowsFile_ID
    Global HiddenWindowList := {}
    PrintSub("HiddenWindowsFileOpenFun")
    
    CSV_Load(HiddenWindowsFilePath, HiddenWindowsFile_ID)
    nRows := CSV_TotalRows(HiddenWindowsFile_ID)
    nCols := CSV_TotalCols(HiddenWindowsFile_ID)
    PrintKV2("Rows", nRows, "Cols", nCols)
    Loop, % nRows {
        row := A_Index
        WindowInfo := {}
        WindowInfo.WindowID := CSV_ReadCell(HiddenWindowsFile_ID, row, 1)
        WindowInfo.OwnerID  := CSV_ReadCell(HiddenWindowsFile_ID, row, 2)
        WindowInfo.Title    := CSV_ReadCell(HiddenWindowsFile_ID, row, 3)
        WindowInfo.ProcName := CSV_ReadCell(HiddenWindowsFile_ID, row, 4)
        WindowInfo.ProcID   := CSV_ReadCell(HiddenWindowsFile_ID, row, 5)
        if (IsHiddenWindowExist(WindowInfo.WindowID)) {
            PrintWindowInfo(windowInfo)
            HiddenWindowList[WindowInfo.WindowID] := WindowInfo
            PrintWindowsInfoList("[HiddenWindowsFileOpenFun] HiddenWindowList", HiddenWindowList)        
        }
        else {
            Print("[HiddenWindowsFileOpenFun] Window does NOT exist. WindowID = " . WindowInfo.WindowID)
        }
    }
}

; -----------------------------------------------------------------------------
; Close/Save HiddenWindowFile
; Write the hidden window information in the following format (CSV):
;  WindowID,OwnerID,Title,ProcessName,ProcessID
;  Ex: 787432,0xc03e8,Untitled - Notepad,notepad.exe,1092
; -----------------------------------------------------------------------------
HiddenWindowsFileSave:
HiddenWindowsFileClose:
    PrintLabel()
    FileDelete, %HiddenWindowsFilePath%
    CSV_Create(HiddenWindowsFilePath, HiddenWindowsFile_Cols, HiddenWindowsFile_ID)
    for windowID, windowInfo in HiddenWindowList {
        RowData := CreateHiddenWindowRowData(windowInfo)
        PrintKV("RowData", RowData)
        CSV_AddRow(HiddenWindowsFile_ID, RowData)
    }
    CSV_Save(HiddenWindowsFilePath, HiddenWindowsFile_ID)
Return

HiddenWindowsFileSaveFun()
{
    Global HiddenWindowsFilePath
    Global HiddenWindowsFile_ID
    Global HiddenWindowList := {}
    PrintSub("HiddenWindowsFileSaveFun")

    ; Delete existing file and re-write the contents
    FileDelete, %HiddenWindowsFilePath%
    
    CSV_Create(HiddenWindowsFilePath, HiddenWindowsFile_Cols, HiddenWindowsFile_ID)
    for windowID, windowInfo in HiddenWindowList {
        ; Skip the windows those do NOT exist
        if (IsHiddenWindowExist(WindowInfo.WindowID)) {        
            RowData := CreateHiddenWindowRowData(windowInfo)
            PrintKV("RowData", RowData)
            CSV_AddRow(HiddenWindowsFile_ID, RowData)
        }
    }
    CSV_Save(HiddenWindowsFilePath, HiddenWindowsFile_ID)
}

; -----------------------------------------------------------------------------
; Returns 
;   True if hidden window exists
;   False otherwise.
; Note: Hidden windows cannot be detected if DetectHiddenWindows is Off
; -----------------------------------------------------------------------------
IsHiddenWindowExist(WindowID)
{
    prevState := A_DetectHiddenWindows
    DetectHiddenWindows, On
    exists := IsWindowExist(WindowID)
    DetectHiddenWindows, %prevState%
    return exists
}

; -----------------------------------------------------------------------------
; Returns 
;   True if window exists
;   False otherwise.
; -----------------------------------------------------------------------------
IsWindowExist(WindowID)
{
    exists := false
    if (WinExist("ahk_id " WindowID)) {
        exists := true
    }
    else {
        exists := false
    }
    return exists
}


; -----------------------------------------------------------------------------
; ListView initiate color
; WM_NOTIFY msg sent by a common control to its parent window when an event
;  has occurred or the control requires some information. Invoke this method
;  to start displaying the hidden windows with specified colors.
; -----------------------------------------------------------------------------
LV_ColorInitiateStart() ; initiate listview color change procedure
{
    Global
    PrintSub("LV_ColorInitiateStart")
    ; MUST include HWNDListView1Hwnd when creating listview (Gui, Add, ListView, ... HWNDListView1Hwnd)
    VarSetCapacity(LvItem, 36, 0)
    OnMessage(WM_NOTIFY, "OnNotify")
}


; -----------------------------------------------------------------------------
; ListView stop OnNotify message hook
; Reset WM_NOTIFY message to an empty function when not displaying the hidden
;  windows. This will improve the performance of rendering ListView.
; -----------------------------------------------------------------------------
LV_ColorInitiateStop() ; initiate listview color change procedure
{
    Global
    PrintSub("LV_ColorInitiateStop")
    OnMessage(WM_NOTIFY, "")
}


; -----------------------------------------------------------------------------
; Cache the given TextColor and BackColor to display the specified window
; Invoke TextColor, BackColor with empty strings to clear the highlighting, so
;  this function used default font/background color to clear.
; -----------------------------------------------------------------------------
LV_ColorChange(Index="", TextColor="", BackColor="") ; change specific line's color or reset all lines
{
    Global
    ; Use the ListView font color and background color to clear the highlighting
    if (TextColor = "") {
        TextColor := ListViewFontColor
    }
    if (BackColor = "") {
        BackColor := ListViewBackgroundColor
    }
    
    PrintSub("LV_ColorChange: Index = " . Index . ", TextColor = " . TextColor . ", BackColor = " . BackColor)
    If Index =
    {
        Print("Clearing all highlights - Begin")
        Loop, %Window_Found_Count% ; or use another count if listview not visible
            LV_ColorChange(A_Index)
        Print("Clearing all highlights - End")
    }
    Else
    {
        Line_Color_%Index%_Text := TextColor
        Line_Color_%Index%_Back := BackColor
        ;~ WinSet, Redraw,, ahk_id %ListView1Hwnd%
    }
}


; -----------------------------------------------------------------------------
; ON_NOTIFY( wNotifyCode, id, memberFxn )
;
; wNotifyCode : The code for the notification message to be handled, such as LVN_KEYDOWN.
;          id : The child identifier of the control for which the notification is sent.
;   memberFxn : The member function to be called when this notification is sent.
;
; Your member function must be declared with the following prototype:
;   afx_msg void memberFxn( NMHDR * pNotifyStruct, LRESULT * result );
; -----------------------------------------------------------------------------
OnNotify(W, L, M)
{
    Local DrawStage, Current_Line, Index, IsSelected := 0
    Static NM_CUSTOMDRAW          := -12
    Static LVN_COLUMNCLICK        := -108
    
    ; Size off NMHDR structure
    Static CDDS_PREPAINT          := 0x00000001
    Static CDDS_ITEMPREPAINT      := 0x00010001
    Static CDDS_SUBITEMPREPAINT   := 0x00030001
    Static CDRF_DODEFAULT         := 0x00000000
    Static CDRF_NEWFONT           := 0x00000002
    Static CDRF_NOTIFYITEMDRAW    := 0x00000020
    Static CDRF_NOTIFYSUBITEMDRAW := 0x00000020
    Static CLRDEFAULT             := 0xFF000000
    
    ; Size off NMHDR structure
    Static NMHDRSize := (2 * A_PtrSize) + 4 + (A_PtrSize - 4)
    ; Offset of dwItemSpec (NMCUSTOMDRAW)
    Static ItemSpecP := NMHDRSize + (5 * 4) + A_PtrSize + (A_PtrSize - 4)
    ; Size of NMCUSTOMDRAW structure
    Static NCDSize  := NMHDRSize + (6 * 4) + (3 * A_PtrSize) + (2 * (A_PtrSize - 4))
    ; Offset of clrText (NMLVCUSTOMDRAW)
    Static ClrTxP   :=  NCDSize
    ; Offset of clrTextBk (NMLVCUSTOMDRAW)
    Static ClrTxBkP := ClrTxP + 4
    ; Offset of iSubItem (NMLVCUSTOMDRAW)
    Static SubItemP := ClrTxBkP + 4
    ; Offset of clrFace (NMLVCUSTOMDRAW)
    Static ClrBkP   := SubItemP + 8

    ;~ PrintSub("OnNotify")
    
    Critical, 100
    If (NumGet(L + 0, 0, "UPtr") = ListView1Hwnd) {
        ;~ PrintSub("OnNotify: ListView1Hwnd")
        M := NumGet(L + (A_PtrSize * 2), 0, "Int")
        If (M = NM_CUSTOMDRAW) {
            DrawStage := NumGet(L + NMHDRSize, 0, "UInt")
            Current_Line := NumGet(L + ItemSpecP, 0, "UPtr") + 1
            if (DrawStage = CDDS_PREPAINT) {
                return CDRF_NOTIFYITEMDRAW
            }
            else if (DrawStage = CDDS_ITEMPREPAINT) {
                If (DllCall("GetFocus") = ListView1Hwnd) {                                      ; Control has Keyboard Focus?
                    SendMessage, 4140, Current_Line - 1, 2, , ahk_id %ListView1Hwnd%            ; LVM_GETITEMSTATE
                    IsSelected := ErrorLevel
                    If (IsSelected = 2) {                                                       ; LVIS_SELECTED
                        ; Custom selected color highlighting
                        ;~ NumPut(Listview_Colour_Selected_Text, L + ClrTxP, 0, "UInt")
                        ;~ NumPut(Listview_Colour_Selected_Back, L + ClrTxBkP, 0, "UInt")
                        ;~ NumPut(Listview_Colour_Selected_Back, L + ClrBkP, 0, "UInt")
                        ;~ EncodeInteger(0x0, 4, &LvItem, 12)                                       ; LVITEM->state
                        ;~ EncodeInteger(0x2, 4, &LvItem, 16)                                       ; LVITEM->stateMask         ; LVIS_SELECTED
                        ;~ SendMessage, 4139, Current_Line - 1, &LvItem, , ahk_id %ListView1Hwnd%   ; Disable Highlighting

                        ; We want item post-paint notifications
                        Return, 0x00000010                                                       ; CDRF_NOTIFYPOSTPAINT
                    }
                    
                    ; Change the 3rd parameter in the line below if the line number isn't in the 2nd column!
                    ;~ PrintKV2("[OnNotify] Index", Index, "Current_Line", Current_Line)
                    LV_GetText(Index, Current_Line, 2)
                    If (Line_Color_%Index%_Text != "") {
                        NumPut(Line_Color_%Index%_Text, L + ClrTxP, 0, "UInt")
                        NumPut(Line_Color_%Index%_Back, L + ClrTxBkP, 0, "UInt")
                    }
                }
            }
            else if (DrawStage = 0x10000|2) {                                                   ; CDDS_ITEMPOSTPAINT
                If (IsSelected) {
                  EncodeInteger(0x02, 4, &LvItem, 12)                                           ; LVITEM->state
                  EncodeInteger(0x02, 4, &LvItem, 16)                                           ; LVITEM->stateMask         ; LVIS_SELECTED
                  SendMessage, 4139, Current_Line - 1, &LvItem, , ahk_id %ListView1Hwnd%        ; LVM_SETITEMSTATE
                }
            }
        }
    }
}


EncodeInteger(p_value, p_size, p_address, p_offset) {
    loop, %p_size%
        DllCall("RtlFillMemory", "uint", p_address + p_offset + A_Index - 1, "uint", 1, "uchar", p_value >> (8 * (A_Index - 1)))
}


; -----------------------------------------------------------------------------
; ::StatusBar related stuff
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; 
; -----------------------------------------------------------------------------
SBUpdateInfo(info="") {
    SB_SetText(info)
}

; -----------------------------------------------------------------------------
; Update selected window process ID
; Always display the information center of the part using "`t" (tab character)
; -----------------------------------------------------------------------------
SBUpdatePID() {
    Global SelectedRowNumber
    Global Window_Found_Count
    if (Window_Found_Count > 0) {
        procID := PID%SelectedRowNumber%
        fmtString := Format("`tPID: {1:5}", procID)
    }
    else {
        fmtString := ""
    }
    SB_SetText(fmtString, SBPartPIDPos)
}


; -----------------------------------------------------------------------------
; Update selected window position
; Always display the information center of the part using "`t" (tab character)
; -----------------------------------------------------------------------------
SBUpdateActiveWindowPos() {
    Global SelectedRowNumber
    Global Window_Found_Count
    if (Window_Found_Count > 0) {
        fmtString := Format("`t{1:2}/{2:-2}", SelectedRowNumber, Window_Found_Count)
    }
    else {
        fmtString := ""
    }
    SB_SetText(fmtString, SBPartActiveWindowPos)
}


; -----------------------------------------------------------------------------
; ToolTip cannot be displayed if the static text control doesn't have a gHandler.
; So, adding DoNothing event handler for static text controls to display tooltip
; information.
; -----------------------------------------------------------------------------
MainDoNothingHandler:
Return


; -----------------------------------------------------------------------------
; GetNextRowInfoOfSameProcess
; This method returns the row number of the
; -----------------------------------------------------------------------------
GetNextRowInfoOfSameProcess() {
    Global
    
    PrintSub("GetNextRowInfoOfSameProcess")
    ; If there is only one window, no need to proceed further
    if (Window_Found_Count == 1) {
        return SelectedRowNumber
    }
    
    SelectedProcName := Exe_Name%SelectedRowNumber%
    ind := 0
    ;~ PrintKV2("[GetNextRowInfoOfSameProcess] SelectedProcName", SelectedProcName, "ProcessDictListIndex", ProcessDictListIndex)
    ;~ MsgBox, 0, Title, Text
    
    Loop, %Window_Found_Count% {
        ind := SelectedRowNumber + A_Index
        ;~ PrintKV2("[GetNextRowInfoOfSameProcess] ind", ind, "ExeName", ind)
        
        if (ind > Window_Found_Count) {
            ind := Mod(ind, Window_Found_Count)
        }
        exeName := Exe_Name%ind%
        PrintKV2("[GetNextRowInfoOfSameProcess] ind", ind, "ExeName", exeName)
        
        ; Do case insensitive comparision using '=' (single equal)
        if (SelectedProcName = exeName
            || (ProcessDictListIndex != -1 && ProcessDictList[ProcessDictListIndex].HasKey(exeName))) {
            SelectedRowNumber := ind
            break
        }
    }
    
    return SelectedRowNumber
}


; -----------------------------------------------------------------------------
; GetPrevRowInfoOfSameProcess
; This method returns the row number of the
; -----------------------------------------------------------------------------
GetPrevRowInfoOfSameProcess() {
    Global

    PrintSub("GetPrevRowInfoOfSameProcess")
    ; If there is only one window, no need to proceed further
    if (Window_Found_Count == 1) {
        return SelectedRowNumber
    }
    
    SelectedProcName := Exe_Name%SelectedRowNumber%
    Local ind := 0
    
    Loop, %Window_Found_Count% {
        ind := SelectedRowNumber - A_Index
        if (ind < 1) {
            ind := ind + Window_Found_Count
        }
        
        exeName := Exe_Name%ind%
        ; Do case insensitive comparision using '=' (single equal)
        if (SelectedProcName = exeName
            || (ProcessDictListIndex != -1 && ProcessDictList[ProcessDictListIndex].HasKey(exeName))) {
            ;~ Print("[GetNextRowInfoOfSameProcess] ExeName[" . ind . "] = " . exeName)
            SelectedRowNumber := ind
            break
        }
    }
    
    return SelectedRowNumber
}


; -----------------------------------------------------------------------------
; Include files
; -----------------------------------------------------------------------------
#Include %A_ScriptDir%\Lib\CSVLib.ahk
#Include %A_ScriptDir%\Lib\AddTooltip.ahk
#Include %A_ScriptDir%\CommonUtils.ahk
#Include %A_ScriptDir%\AboutDialog.ahk
#Include %A_ScriptDir%\ReadMe.ahk
#Include %A_ScriptDir%\Help.ahk
#Include %A_ScriptDir%\ReleaseNotes.ahk
#Include %A_ScriptDir%\SettingsDialog.ahk
