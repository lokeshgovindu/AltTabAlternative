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


SetWorkingDir, %A_ScriptDir%

; -----------------------------------------------------------------------------
; 
; -----------------------------------------------------------------------------
; Windows Messages

WM_KEYDOWN := 0x100
WM_KEYUP   := 0x101

; -----------------------------------------------------------------------------
; Product Information 
; -----------------------------------------------------------------------------

ProductPage 	        := "http://alttabalternative.sourceforge.net/"
AuthorName 		        := "Lokesh Govindu"
AuthorPage 		        := "http://lokeshgovindu.blogspot.in/"
AboutDialogText	         = AltTabAlternative is a small application created in <a href=`"https://autohotkey.com/`">AutoHotkey</a>, an alternative for windows native Alt+Tab switcher.

SettingsDirPath         := A_AppData . "\" . ProductName
SettingsINIFileName     := "AltTabAlternativeSettings.ini"
SettingsINIFilePath     := SettingsDirPath . "\" . SettingsINIFileName

TrayIcon                := "AltTabAlternative.ico"
ApplicationName         := ProductName
ProgramName             := ApplicationName
ReadMeFileName          := "ReadMe.txt"
HelpFileName            := "Help.txt"
ReleaseNotesFileName    := "ReleaseNotes.txt"


; -----------------------------------------------------------------------------
; 
; -----------------------------------------------------------------------------
CurSearchString         := ""
NewSearchString         := ""
DisplayListShown        := 0
CtrlBtnDown             := false
NumberBtnDown           := false
NumberBtnValue          := -1
Window_Found_Count      := 0
SelectedRowNumber       := 1
SelectedWinNumber       := 0
LVE_VkCodePrev           =
HotkeysDisabled         := false
CSHotkeysDisabled       := false    ; ContextSensitive Hotkeys
ActivateWindow          := false


; -----------------------------------------------------------------------------
; USER EDITABLE SETTINGS:
; -----------------------------------------------------------------------------
; Icons
UseLargeIcons       := 1     ; 0 = small icons, 1 = large icons in listview
ListviewResizeIcons := 0     ; Resize icons to fit listview area


; -----------------------------------------------------------------------------
; Read settings here
; -----------------------------------------------------------------------------
IniFileData("Read")
PrintSettings()

; Position
GuiX = Center
GuiY = Center


; -----------------------------------------------------------------------------
; USER OVERRIDABLE SETTINGS:
; -----------------------------------------------------------------------------

; ListView Column Widths
Col_1 = Auto    ; Icon Column
Col_2 = 0       ; Row Number
; col 3 is autosized based on other column sizes
Col_4 = Auto    ; Process Name

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

Gosub, InitiateHotkeys

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
Menu, Tray, Add, Run at startup, RunAtStartupHandler
Menu, Tray, Add  ; Separator
Menu, Tray, Add, Exit, ExitHandler
Menu, Tray, Tip, % ProgramName " " ProductVersion
Menu, Tray, Default, About %ATAPRODUCTNAME%

; Check if the application is marked "Run at startup"
IfExist, %A_Startup%/%ProgramName%.lnk
{
	FileDelete, %A_Startup%/%ProgramName%.lnk
	FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/%ProgramName%.lnk
	Menu, Tray, Check, Run at startup
}

Return


; -----------------------------------------------------------------------------
; ExitApp
; -----------------------------------------------------------------------------
ExitHandler:
    ExitApp


; -----------------------------------------------------------------------------
; RunAtStartup Handler
; -----------------------------------------------------------------------------
RunAtStartupHandler:
	Menu, Tray, Togglecheck, Run at startup
	IfExist, %A_Startup%/%ProgramName%.lnk
		FileDelete, %A_Startup%/%ProgramName%.lnk
	else
        FileCreateShortcut, % H_Compiled ? A_AhkPath : A_ScriptFullPath, %A_Startup%/%ProgramName%.lnk
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
    ShowSettingsDialog()
Return


; -----------------------------------------------------------------------------
; Display Release Notes dialog
; -----------------------------------------------------------------------------
ReleaseNotesHandler:
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
    ShowHelp()
Return


; -----------------------------------------------------------------------------
; Display ReadMe window
; -----------------------------------------------------------------------------
ReadMeHandler:
    ShowReadMe()
Return


; -----------------------------------------------------------------------------
; Initiate hotkeys
; -----------------------------------------------------------------------------
InitiateHotkeys:
    PrintSub("InitiateHotkeys")
    AltHotKey       = !
    AltHotKey2      = Alt
    TabHotKey       = Tab
    ShiftTabHotkey  = +Tab
    EscHotKey       = Esc
    HelpHotKey      = F1
    SettingsHotKey  = F2
    
    PrintKV("AltHotkey", AltHotkey)
    PrintKV("TabHotkey", TabHotkey)
    PrintKV("ShiftTabHotkey", ShiftTabHotkey)
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

    Hotkey, %AltHotkey%%TabHotkey%, AltTabAlternative, %state% UseErrorLevel
    Hotkey, %AltHotkey%%ShiftTabHotkey%, AltShiftTabAlternative, %state% UseErrorLevel
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
; This hotkey displays the actual window
; -----------------------------------------------------------------------------
AltTabCommonFunction(direction)
{
    Global DisplayListShown
    Global Window_Found_Count
    Global LVE_VkCodePrev
    
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
        ToggleAltEscHotkey("On")
    }

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
    PrintKV("SelectedRowNumber", SelectedRowNumber)
    LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible
    Return
}


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
    Gui, 1: +AlwaysOnTop +ToolWindow -Caption +HwndMainWindowHwnd
    Gui, 1: Margin, 0, 0

    Gui, 1: Font, s%SearchStringFontSize% c%SearchStringFontColor% %SearchStringFontStyle%, %SearchStringFontName%
    Gui, 1: Add, Text, vTextCtrlVar hwndhTextCtrl Center w%WindowWidth% +Border, Search String: empty

    Gui, 1: Font, s%ListViewFontSize% c%ListViewFontColor% %ListViewFontStyle%, %ListViewFontName%
    Gui, 1: Add, ListView, w%WindowWidth% h200 AltSubmit +Redraw -Multi NoSort +LV0x2 Background%ListViewBackgroundColor% Count10 gListViewEvent vListView1 HwndListView1Hwnd, %ColumnTitleList%
    
    Print("ListView1Hwnd = [" . ListView1Hwnd . "]")
    
    Gui, 1: Font, s%FontSize% c%FontColorEdit% %FontStyle%, %FontType%

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
    PrintSub("DisplayList")
    PrintKV("[DisplayList] SelectedRowNumber", SelectedRowNumber)
    
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
            
            if (isAltTabWindow) {
                WinGet, procPath, ProcessPath, ahk_id %windowID%
                WinGet, procName, ProcessName, ahk_id %windowID%
                
                ;~ FileAppend, A_Index = [%A_Index%] title = [%title%]`, processName = [%procName%]`n, *
                ;~ Print("CurSearchString = " . CurSearchString)
                If (InStr(title, CurSearchString, false) != 0 or InStr(procName, CurSearchString, false) != 0)
                {
                    Window_Found_Count += 1
                    if (ownerES) {
                        GetWindowIcon(ownerID, UseLargeIconsCurrent)          ; (window id, whether to get large icons)
                    } else {
                        GetWindowIcon(windowID, UseLargeIconsCurrent)          ; (window id, whether to get large icons)
                    }
                    ;~ PrintKV3("WindowID", windowID, "OwnerID", ownerID, "title", title)
                    ; Use windowID to activate window, ownerID to terminate window
                    WindowStoreAttributes(Window_Found_Count, windowID, ownerID)  ; Index, wid, parent (or blank if none)
                    LV_Add("Icon" . Window_Found_Count, "", Window_Found_Count, title, procName)
                }
            }
        }
    }

    GuiControl, +Redraw, ListView1
    ;~ PrintKV("[DisplayList] SelectedRowNumber", SelectedRowNumber)
    LV_Modify(SelectedRowNumber, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible
    ;~ LV_Modify(1, "Select Vis Focus") ; Get selected row and ensure selection & focus is visible

    ; TURN ON INCREMENTAL SEARCH
    SetTimer, tIncrementalSearch, 500
Return


; -----------------------------------------------------------------------------
; ListView event handler
; -----------------------------------------------------------------------------
ListViewEvent:
    Critical, 50
    ;~ PrintSub("ListViewEvent")
    ;~ Print("ListViewEvent: A_GuiEvent = " . A_GuiEvent)
    ;~ Print("ListViewEvent: A_EventInfo = " . A_EventInfo)
    ;~ key := GetKeyName(Format("vk{:x}", A_EventInfo))
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
    if A_GuiEvent = Normal          ; Mouse left-click
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
    if A_GuiEvent = K
    {
        key := GetKeyName(Format("vk{:x}", A_EventInfo))
        PrintKV2("[K] A_EventInfo", A_EventInfo, "key", key)
        
        PrintKV("[K] LVE_VkCodePrev", LVE_VkCodePrev)
        
        ; Check if Shift key is down
        IsShiftKeyDown := GetKeyState("Shift", "P") or GetKeyState("Shift")
        PrintKV("IsShiftKeyDown", IsShiftKeyDown)
        
        vkCode := A_EventInfo        
        ; -----------------------------------------------------------------------------
        ; Handle F1 Function Key
        ; -----------------------------------------------------------------------------
        if (vkCode = GetKeyVK("F1")) {
            Gosub, AltTabAlternativeDestroy
            ShowHelp()
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
        ; -----------------------------------------------------------------------------
        ; Handle NumpadDown - 40
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadDown")) {
            Gosub, AltTabAlternative
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; NumpadUp - 38
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadUp")) {
            Gosub, AltShiftTabAlternative
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; NumpadHome - 36, NumpadPgUp - 33
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadHome") or vkCode = GetKeyVK("NumpadPgUp")) {
            SelectedRowNumber = 1
            LV_Modify(SelectedRowNumber, "Select Vis Focus")
            LVE_VkCodePrev := vkCode
            Return
        }
        ; -----------------------------------------------------------------------------
        ; NumpadEnd - 35, NumpadPgDn - 34
        ; -----------------------------------------------------------------------------
        else if (vkCode = GetKeyVK("NumpadEnd") or vkCode = GetKeyVK("NumpadPgDn")) {
            SelectedRowNumber := Window_Found_Count
            LV_Modify(SelectedRowNumber, "Select Vis Focus")
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
                procID := PID%SelectedRowNumber%
                PrintKV("Forcefully kill PID = ", procID)
                KillCmd := "TASKKILL /PID " . procID . " /T /F"
                PrintKV("KillCmd", KillCmd)
                ;~ RunWait, %KillCmd%, , Hide
                Run, %KillCmd%, , Hide
                ;~ WinKill, ahk_id %ownerID%
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
                PostMessage, 0x112, 0xF060, , , ahk_id %windowID%  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
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
                MsgBox, 292, AltTabAlternative: Terminate All, Are you sure you want to terminate all processes?
                IfMsgBox, No
                {
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
            NewSearchString := NewSearchString . key
            SelectedRowNumber := 1
        }        
        else if (vkCode = 8) { ; Backspace
            ;~ Print("Key is Backspace")
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
; -----------------------------------------------------------------------------
AltTabAlternativeDestroy:
    PrintSub("AltTabAlternativeDestroy Begin")
    PrintKV("AltTabAlternativeDestroy: ActivateWindow", ActivateWindow)
    Gui, 1: Default
    Gosub, DisableTimers
    ToggleAltEscHotkey("Off")
    
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
WindowStoreAttributes(index, windowID, ID_Parent) 
{
    Local State_temp
    ;~ PrintSub("WindowStoreAttributes")
    WinGetTitle, windowTitle, ahk_id %ownerID%
    WinGet, procPath, ProcessPath, ahk_id %windowID%
    WinGet, procName, ProcessName, ahk_id %windowID%
    WinGet, procID, PID, ahk_id %windowID%
    
    Window%index%        := windowID        ; Store ahk_id's to a list
    WindowParent%index%  := ID_Parent       ; Store Parent ahk_id's to a list to later see if window is owned
    WindowTitle%index%   := windowTitle     ; Store titles to a list
    hw_popup%index%      := hw_popup        ; Store the active popup window to a list (eg the find window in notepad)
    Exe_Name%index%      := procName        ; Store the process name
    Exe_Path%index%      := procPath        ; Store the process path
    PID%index%           := procID          ; Store the process id
    Dialog%index%        := Dialog          ; S if found a Dialog window, else 0
}


; -----------------------------------------------------------------------------
; GetSelectedRowInfo
; -----------------------------------------------------------------------------
GetSelectedRowInfo()
{
    Global
    PrintSub("GetSelectedRowInfo")
    
    SelectedRowNumber := LV_GetNext(0, "F")
    PrintKV("[GetSelectedRowInfo] SelectedRowNumber", SelectedRowNumber)

    ; Get the row's 2nd column's text for real order number (hidden column).
    LV_GetText(RowText, SelectedWinNumber, 2)
}


; -----------------------------------------------------------------------------
; ListViewResizeVertically
; -----------------------------------------------------------------------------
ListViewResizeVertically(Gui_ID) ; Automatically resize listview vertically
{
    Global Window_Found_Count, lv_h_win_2000_adj
    SendMessage, 0x1000+31, 0, 0, SysListView321, ahk_id %Gui_ID% ; LVM_GETHEADER
    WinGetPos,,,, lv_header_h, ahk_id %ErrorLevel%
    VarSetCapacity( rect, 16, 0 )
    SendMessage, 0x1000+14, 0, &rect, SysListView321, ahk_id %Gui_ID% ; LVM_GETITEMRECT ; LVIR_BOUNDS
    ;~ Print("rect = " . &rect)
    y1 := 0
    y2 := 0
    Loop, 4
    {
        ;~ Print("*( &rect + 3 + A_Index ) = " . *( &rect + 3 + A_Index ))
        ;~ Print("*( &rect + 11 + A_Index ) = " . *( &rect + 11 + A_Index ))
        y1 += *( &rect + 3 + A_Index )
        y2 += *( &rect + 11 + A_Index )
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
    lv_h := 4 + lv_header_h + ( lv_row_h * Window_Found_Count ) + lv_h_win_2000_adj
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
; -----------------------------------------------------------------------------
GetWindowsCount(SearchString:="", SearchInTitle:=true, SearchInProcName:=true) {
    Global WS_EX_APPWINDOW, WS_EX_TOOLWINDOW, GW_OWNER
    windowList =
    windowFoundCount := 0
    
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

            if (isAltTabWindow)
            {
                WinGet, procName, ProcessName, ahk_id %windowID%
                
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
    }
    
    return windowFoundCount
}


; -----------------------------------------------------------------------------
; Terminate a process based on given WindowID
; -----------------------------------------------------------------------------
TerminateWindow(windowID) {
    WinClose, ahk_id %windowID%
    Sleep, 50
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
; Include files
; -----------------------------------------------------------------------------
#Include %A_ScriptDir%\CommonUtils.ahk
#Include %A_ScriptDir%\AboutDialog.ahk
#Include %A_ScriptDir%\ReadMe.ahk
#Include %A_ScriptDir%\Help.ahk
#Include %A_ScriptDir%\ReleaseNotes.ahk
#Include %A_ScriptDir%\SettingsDialog.ahk
