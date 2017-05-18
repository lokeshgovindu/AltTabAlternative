/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
(-----------------------------------------------------------------------------)
| AltTabAlternative Settings Dialog    / A Script file for AutoHotkey 1.1.23+ |
|                                     ----------------------------------------|
|                                                                             |
o-----------------------------------------------------------------------------o
*/

#Include %A_ScriptDir%\CommonUtils.ahk


; This is for my testing
;~ If (true) {
    ;~ #Include %A_ScriptDir%\Lib\AddTooltip.ahk
    ;~ #Include %A_ScriptDir%\ATATooltips.ahk

    ;~ ProductName                 := "AltTabAlternative"
    ;~ SettingsINIFileName         := "AltTabAlternativeSettings.ini"
    ;~ SettingsDirPath             := A_AppData . "\" . ProductName
    ;~ SettingsINIFilePath         := SettingsDirPath . "\" . SettingsINIFileName
    ;~ PrintKV("SettingsDirPath", SettingsDirPath)
    ;~ PrintKV("SettingsINIFilePath", SettingsINIFilePath)
    ;~ IniFileData("Read")
    ;~ ShowSettingsDialog()
    ;~ Return
    ;~ Esc::
        ;~ ExitApp
;~ }


; -----------------------------------------------------------------------------
; Please use the prefix SD for all the variables inside Settings Dialog
; -----------------------------------------------------------------------------
ShowSettingsDialog()
{
    Global
    ; -----------------------------------------------------------------------------
    ; Below are the default settings used in creating INI file and reading also.
    ; If you want to modify any default setting or add, please do it here.
    ; -----------------------------------------------------------------------------
    DefineDefaultSettings()

    ; -----------------------------------------------------------------------------
    ; Using Progress control to display the color bar, but I couldn't find
    ;	a way to get the color information from Progress control. So, I am
    ;	maintaining additional variables to store this information.
    ;
    ; tSDSearchStringFontColor   : for SearchString font color
    ; tSDListViewFontColor	     : for ListView font color
    ; tSDListViewBackgroundColor : for ListView background color
    ; -----------------------------------------------------------------------------
    StoreSettingsInTempVariables()
    
    ;~ PrintKV("tSDSearchStringFontColor", tSDSearchStringFontColor)
    ;~ PrintKV("tSDListViewBackgroundColor", tSDListViewBackgroundColor)
    
    ; -----------------------------------------------------------------------------
    ; Get the available fonts on the system
    ; And, find the indexes of the fonts for SearchString, ListView
    ; -----------------------------------------------------------------------------
    FontList := Fnt_GetListOfFonts()

    SearchStringFontIndex := 0
    ListViewFontIndex := 0

    fontDropDownList := ""
    fontDropDownListIndex := 0

    Loop Parse, FontList, `n, `r
    {
        ++fontDropDownListIndex
        if (fontDropDownList = "") {
            fontDropDownList := A_LoopField
        }
        else {
            fontDropDownList := fontDropDownList . "|" . A_LoopField
        }
        
        if (SearchStringFontIndex = 0 and SearchStringFontName = A_LoopField) {
            SearchStringFontIndex := fontDropDownListIndex
        }
        
        if (ListViewFontIndex = 0 and ListViewFontName = A_LoopField) {
            ListViewFontIndex := fontDropDownListIndex
        }
    }

    SearchStringFontStyleIndex := GetFontStyleIndex(SearchStringFontStyle)
    ListViewFontStyleIndex := GetFontStyleIndex(ListViewFontStyle)

    UpdateOptionsList := "Startup|Daily|Weekly|Never"
    UpdateOptionsIndex := GetCheckForUpdatesIndex(UpdateOptionsList, CheckForUpdates)
    
    SDGroupWidth 		:= 264
    SDGroupHeight 		:= 144
    SDTextCtrlFontSize 	:= 10
    SecondColumnOffset  := 57
    
    Gui, SettingsDialog: New, +hwndhSettingsDialog, %ProductName% Settings
    Gui, Margin, 5, 5

    ; -----------------------------------------------------------------------------
    ; Storage Path & Export Settings
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm ym+5 vSDStorageText hwndhSDStorageText gDoNothing, Storage:
    Gui, Add, Edit, x+3 yp-3 w406 vSDStorageEdit hwndhSDStorageEdit ReadOnly -Multi R1, %SettingsINIFilePath%
    AddTooltip(hSDStorageText, SDStorageTextTooltip)
    AddTooltip(hSDStorageEdit, SDStorageTextTooltip)
    Gui, Add, Button, x+3 yp-1 w80 vSDExportBtn hwndhSDExportBtn gSDExportBtnHandler, &Export...
    AddTooltip(hSDExportBtn, SDExportBtnTooltip)

    ; -----------------------------------------------------------------------------
    ; SearchString Font Group
    ; -----------------------------------------------------------------------------
    Gui, Add, GroupBox, xm y33 Section vSearchStringGroupBox hwndhSearchStringGroupBox W%SDGroupWidth% H%SDGroupHeight% cBlue, SearchString Font
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 yp+21 vSDSearchStringFontNameText hwndhSDSearchStringFontNameText gDoNothing, &Name:
    Gui, Add, DropDownList, xm+%SecondColumnOffset% yp-3 w200 R15 vSDSearchStringFontNameDDL hwndhSDSearchStringFontNameDDL Choose%SearchStringFontIndex% gSDSearchStringFontNameDDLHandler, %fontDropDownList%
    AddTooltip(hSDSearchStringFontNameText, SDSearchStringFontNameTooltip)
    AddTooltip(hSDSearchStringFontNameDDL,  SDSearchStringFontNameTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 y+6 vSDSearchStringFontSizeText hwndhSDSearchStringFontSizeText gDoNothing, &Size:
    Gui, Add, Edit, xm+%SecondColumnOffset% yp-3 w200 hwndhSDSearchStringFontSizeEdit
    Gui, Add, UpDown, vSDSearchStringFontSizeUpDown hwndhSDSearchStringFontSizeUpDown gSDSearchStringFontSizeUpDownHandler Range8-25, %SearchStringFontSize%
    AddTooltip(hSDSearchStringFontSizeText,   SDSearchStringFontSizeTooltip)
    AddTooltip(hSDSearchStringFontSizeEdit,   SDSearchStringFontSizeTooltip)
    AddTooltip(hSDSearchStringFontSizeUpDown, SDSearchStringFontSizeTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 y+6 vSDSearchStringFontColorText hwndhSDSearchStringFontColorText gDoNothing, &Color:
    Gui, Add, Progress, xm+%SecondColumnOffset% yp-3 w200 h21 vSDSearchStringFontColorProgress hwndhSDSearchStringFontColorProgress c%SearchStringFontColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xp yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDSearchStringFontColorProgressText hwndhSDSearchStringFontColorProgressText gSDSearchStringFontColorChangeBtnHandler
    AddTooltip(hSDSearchStringFontColorText,         SDSearchStringFontColorTooltip)
    AddTooltip(hSDSearchStringFontColorProgressText, SDSearchStringFontColorTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 y+6 vSDSearchStringFontStyleText hwndhSDSearchStringFontStyleText gDoNothing, St&yle:
    Gui, Add, DropDownList, xm+%SecondColumnOffset% yp-3 w200 vSDSearchStringFontStyleDDL hwndhSDSearchStringFontStyleDDL gSDSearchStringFontStyleDDLHandler Choose%SearchStringFontStyleIndex%, norm|italic|bold|bold italic
    AddTooltip(hSDSearchStringFontStyleText, SDSearchStringFontStyleTooltip)
    AddTooltip(hSDSearchStringFontStyleDDL,  SDSearchStringFontStyleTooltip)
    ; -----------------------------------------------------------------------------

    ; -----------------------------------------------------------------------------
    ; ListView Font Group
    ; -----------------------------------------------------------------------------
    SDControlPosX := SDGroupWidth + 3
    Gui, Add, GroupBox, xm+%SDControlPosX% y33 Section vListViewGroupBox W%SDGroupWidth% H144 cBlue, ListView Font
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 yp+21 vSDListViewFontNameText hwndhSDListViewFontNameText gDoNothing, &Name:
    Gui, Add, DropDownList, xs+%SecondColumnOffset% yp-3 w200 R15 vSDListViewFontNameDDL hwndhSDListViewFontNameDDL gSDListViewFontNameDDLHandler Choose%ListViewFontIndex%, %fontDropDownList%
    AddTooltip(hSDListViewFontNameText, SDListViewFontNameTooltip)
    AddTooltip(hSDListViewFontNameDDL,  SDListViewFontNameTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewFontSizeText hwndhSDListViewFontSizeText gDoNothing, &Size:
    Gui, Add, Edit, xs+%SecondColumnOffset% yp-3 w200 hwndhSDListViewFontSizeEdit gDoNothing
    Gui, Add, UpDown, vSDListViewFontSizeUpDown hwndhSDListViewFontSizeUpDown gSDListViewFontSizeUpDownHandler Range8-25, %ListViewFontSize%
    AddTooltip(hSDListViewFontSizeText,   SDListViewFontSizeTooltip)
    AddTooltip(hSDListViewFontSizeEdit,   SDListViewFontSizeTooltip)
    AddTooltip(hSDListViewFontSizeUpDown, SDListViewFontSizeTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewFontColorText hwndhSDListViewFontColorText gDoNothing, &Color:
    Gui, Add, Progress, xs+%SecondColumnOffset% yp-3 w200 h21 vSDListViewFontColorProgress c%ListViewFontColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xs yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDListViewFontColorProgressText hwndhSDListViewFontColorProgressText gSDListViewFontColorChangeBtnHandler
    AddTooltip(hSDListViewFontColorText,         SDListViewFontColorTooltip)
    AddTooltip(hSDListViewFontColorProgressText, SDListViewFontColorTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewFontStyleText hwndhSDListViewFontStyleText gDoNothing, St&yle:
    Gui, Add, DropDownList, xs+%SecondColumnOffset% yp-3 w200 vSDListViewFontStyleDDL hwndhSDListViewFontStyleDDL gSDListViewFontStyleDDLHandler Choose%ListViewFontStyleIndex%, norm|italic|bold|bold italic
    AddTooltip(hSDListViewFontStyleText, SDListViewFontStyleTooltip)
    AddTooltip(hSDListViewFontStyleDDL,  SDListViewFontStyleTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewBkColorText hwndhSDListViewBkColorText gDoNothing, &Bk Color:
    Gui, Add, Progress, xs+%SecondColumnOffset% yp-3 w200 h21 vSDListViewBkColorProgress c%ListViewBackgroundColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xs yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDListViewBkColorProgressText hwndhSDListViewBkColorProgressText gSDListViewBkColorChangeBtnHandler
    AddTooltip(hSDListViewBkColorText,         SDListViewBkColorTooltip)
    AddTooltip(hSDListViewBkColorProgressText, SDListViewBkColorTooltip)
    ; -----------------------------------------------------------------------------

    ; -----------------------------------------------------------------------------
    ; HiddenWindows Font Group
    ; -----------------------------------------------------------------------------
    SDControlPosX := SDGroupWidth + 3
    SDControlPosY := SDGroupHeight + 38
    Gui, Add, GroupBox, xm y%SDControlPosY% Section vHiddenWindowsGroupBox W531 H50 cBlue, Hidden Windows Font

    Gui, Add, Text, xs+5 ys+20 vSDListViewHWFontColorText hwndhSDListViewHWFontColorText gDoNothing, &Color:
    Gui, Add, Progress, xs+%SecondColumnOffset% yp-3 w200 h21 vSDListViewHWFontColorProgress c%ListViewHWFontColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xs yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDListViewHWFontColorProgressText hwndhSDListViewHWFontColorProgressText gSDListViewHWFontColorChangeBtnHandler
    AddTooltip(hSDListViewHWFontColorText,         SDListViewHWFontColorTooltip)
    AddTooltip(hSDListViewHWFontColorProgressText, SDListViewHWFontColorTooltip)
    ; -----------------------------------------------------------------------------
    ;~ Gui, Add, Text, xs+5 y+6 vSDListViewHWBkColorText hwndhSDListViewHWBkColorText gDoNothing, &Bk Color:
    Gui, Add, Text, xs+272 ys+20 vSDListViewHWBkColorText hwndhSDListViewHWBkColorText gDoNothing, &Bk Color:
    Gui, Add, Progress, xs+324 yp-3 w200 h21 vSDListViewHWBkColorProgress c%ListViewHWBackgroundColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xs yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDListViewHWBkColorProgressText hwndhSDListViewHWBkColorProgressText gSDListViewHWBkColorChangeBtnHandler
    AddTooltip(hSDListViewHWBkColorText,         SDListViewHWBkColorTooltip)
    AddTooltip(hSDListViewHWBkColorProgressText, SDListViewHWBkColorTooltip)
    ; -----------------------------------------------------------------------------

    ColumnOffset := 141
    ; -----------------------------------------------------------------------------
    ; Alt+Backtick Settings Group
    ; -----------------------------------------------------------------------------
    Gui, Add, GroupBox, xm Section vAltBacktickGroupBox W531 H90 cBlue, AltBacktick
    ; -----------------------------------------------------------------------------
    Gui, Add, Checkbox, xs+5 ys+20 vSDBacktickFilterWindowsCheckBox hwndhSDBacktickFilterWindowsCheckBox gSDBacktickFilterWindowsCheckBoxHandler Checked%BacktickFilterWindows%, &Display windows of the same application only (Alt+Backtick)
    AddTooltip(hSDBacktickFilterWindowsCheckBox, SDBacktickFilterWindowsCheckBoxTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+18 hwndhSDSimilarProcessGroupsText vSDSimilarProcessGroupsText gSDGenericHandler, Similar Process &Groups
    Gui, Font, s10 cBlue, Lucida Console
    Gui, Add, Edit, xs+%ColumnOffset% yp-15 w384 hwndhSDSimilarProcessGroupsEdit vSDSimilarProcessGroupsEdit Multi R3 gSDGenericHandler, %SimilarProcessGroupsStr%
    Gui, Font
    AddTooltip(hSDSimilarProcessGroupsText, SDSimilarProcessGroupsTooltip)
    AddTooltip(hSDSimilarProcessGroupsEdit, SDSimilarProcessGroupsTooltip)
    ; -----------------------------------------------------------------------------

    ColumnOffset := 141
    ; -----------------------------------------------------------------------------
    ; General Settings Group
    ; -----------------------------------------------------------------------------
    Gui, Add, GroupBox, xm Section vGeneralGroupBox W531 H153 cBlue, General
    ; -----------------------------------------------------------------------------
    Gui, Add, Checkbox, xs+5 ys+20 vSDShowStatusBarCheckBox hwndhSDShowStatusBarCheckBox gSDShowStatusBarCheckBoxHandler Checked%ShowStatusBar%, &Show StatusBar
    AddTooltip(hSDShowStatusBarCheckBox, SDShowStatusBarTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Checkbox, xs+5 y+6 vSDPromptTerminateAllCheckBox hwndhSDPromptTerminateAllCheckBox gSDPromptTerminateAllCheckBoxHandler Checked%PromptTerminateAll%, &PromptTerminateAll
    AddTooltip(hSDPromptTerminateAllCheckBox, SDPromptTerminateAllTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 hwndhSDWindowTransparencyText gDoNothing, Window &Transparency
    Gui, Add, Edit, xs+%ColumnOffset% yp-4 w48 hwndhSDWindowTransparencyEdit
    Gui, Add, UpDown, vSDWindowTransparencyUpDown hwndhSDWindowTransparencyUpDown gSDWindowTransparencyUpDownHandler Range100-255, %WindowTransparency%
    AddTooltip(hSDWindowTransparencyText,   SDWindowTransparencyTooltip)
    AddTooltip(hSDWindowTransparencyEdit,   SDWindowTransparencyTooltip)
    AddTooltip(hSDWindowTransparencyUpDown, SDWindowTransparencyTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 hwndhSDWindowWidthPercentageText gDoNothing, Window &Width (`%)
    Gui, Add, Edit, xs+%ColumnOffset% yp-4 w48 hwndhSDWindowWidthPercentageEdit
    Gui, Add, UpDown, vSDWindowWidthPercentageUpDown hwndhSDWindowWidthPercentageUpDown gSDWindowWidthPercentageUpDownHandler Range40-90, %WindowWidthPercentage%
    AddTooltip(hSDWindowWidthPercentageText,   SDWindowWidthPercentageTooltip)
    AddTooltip(hSDWindowWidthPercentageEdit,   SDWindowWidthPercentageTooltip)
    AddTooltip(hSDWindowWidthPercentageUpDown, SDWindowWidthPercentageTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 hwndhSDWindowHeightMaxPercentageText gDoNothing, Window &Height Max (`%)
    Gui, Add, Edit, xs+%ColumnOffset% yp-4 w48 hwndhSDWindowHeightMaxPercentageEdit
    Gui, Add, UpDown, vSDWindowHeightMaxPercentageUpDown hwndhSDWindowHeightMaxPercentageUpDown gSDWindowHeightMaxPercentageUpDownHandler Range10-90, %WindowHeightMaxPercentage%
    AddTooltip(hSDWindowHeightMaxPercentageText,   SDWindowHeightMaxPercentageTooltip)
    AddTooltip(hSDWindowHeightMaxPercentageEdit,   SDWindowHeightMaxPercentageTooltip)
    AddTooltip(hSDWindowHeightMaxPercentageUpDown, SDWindowHeightMaxPercentageTooltip)
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDCheckForUpdatesText hwndhSDCheckForUpdatesText gDoNothing, Check for &updates
    Gui, Add, DropDownList, xs+%ColumnOffset% yp-3 w60 vSDCheckForUpdatesDDL hwndhSDCheckForUpdatesDDL gSDCheckForUpdatesDDLHandler Choose%UpdateOptionsIndex%, %UpdateOptionsList%
    AddTooltip(hSDCheckForUpdatesText, SDCheckForUpdatesTooltip)
    AddTooltip(hSDCheckForUpdatesDDL,  SDCheckForUpdatesTooltip)
    ; -----------------------------------------------------------------------------
    
    ; -----------------------------------------------------------------------------
    ; Ok, Cancel Buttons
    ; -----------------------------------------------------------------------------
    Gui, Add, Button, xm  w80 vSDOkBtn gOkBtnHandler hwndhSDOkBtn +Default, &OK
    AddTooltip(hSDOkBtn, SDOkBtnTooltip)
    Gui, Add, Button, x+3 w80 vSDApplyBtn hwndhSDApplyBtn gSDApplyBtnHandler -Default Disabled, &Apply
    AddTooltip(hSDApplyBtn, SDApplyBtnTooltip)
    Gui, Add, Button, x+3 w80 vSDCancelBtn gSDCancelBtnHandler hwndhSDCancelBtn -Default Disabled, Cance&l
    AddTooltip(hSDCancelBtn, SDCancelBtnTooltip)
    Gui, Add, Button, x+3 w80 vSDResetBtn hwndhSDResetBtn gResetBtnHandler, &Reset...
    AddTooltip(hSDResetBtn, SDResetBtnTooltip)
    Gui, Add, Button, x+3 w80 vSDImportBtn hwndhSDImportBtn gImportBtnHandler, &Import...
    AddTooltip(hSDImportBtn, SDImportBtnTooltip)
    ; -----------------------------------------------------------------------------
    
    Gui, Show, AutoSize Center
    Return
    

; -----------------------------------------------------------------------------
; ToolTip cannot be displayed if the static text control doesn't have a gHandler.
; So, adding DoNothing event handler for static text controls to display tooltip
; information.
; -----------------------------------------------------------------------------
DoNothing:
Return


; -----------------------------------------------------------------------------
; SettingsDialog GuiSize
; -----------------------------------------------------------------------------
SettingsDialogGuiSize:
    PrintSub("SettingsDialogGuiSize")
    PrintKV2("A_GuiWidth", A_GuiWidth, "A_GuiHeight", A_GuiHeight)
    WinGetPos, X, Y, Width, Height, A
    MoveControlsToHorizontalCenter("SDOkBtn|SDApplyBtn|SDCancelBtn|SDResetBtn|SDImportBtn", A_GuiWidth)
    ;~ AutoXYWH("w", "StorageEdit")
    ;~ GuiControl, Move, GeneralGroupBox, w531
    ControlFocus, , ahk_id %hSDOkBtn%
Return


; -----------------------------------------------------------------------------
; SDCancelBtnHandler
; -----------------------------------------------------------------------------
SDCancelBtnHandler:
SettingsDialogGuiEscape:
SettingsDialogGuiClose:
    Gui, SettingsDialog:Hide
    ;~ ExitApp
Return


; -----------------------------------------------------------------------------
; Apply Settings
; Save the modified settings from controls to the variables
; -----------------------------------------------------------------------------
ApplySettings:
    ; Check if the settings are valid
    tSDSimilarProcessGroupsStr := Trim(tSDSimilarProcessGroupsStr, " `t`n")
    errorMessage := ""
    isValid := IsValidSimilarProcessGroupsString(tSDSimilarProcessGroupsStr, errorMessage)
    if (!isValid) {
        Gui, +OwnDialogs    ; To display a modal dialog
        MsgBox, , Invalid Similar Process Groups, Similar Process Groups text contains invalid characters.`nA file name can't contain any of the following characters: \ / : * ? " < > | ``n ``t`n%errorMessage%`, please verify...
        return
    }

    GuiControlGet, SearchStringFontName, , SDSearchStringFontNameDDL
    GuiControlGet, SearchStringFontSize, , SDSearchStringFontSizeUpDown
    SearchStringFontColor := tSDSearchStringFontColor
    GuiControlGet, SearchStringFontStyle, , SDSearchStringFontStyleDDL

    GuiControlGet, ListViewFontName, , SDListViewFontNameDDL
    GuiControlGet, ListViewFontSize, , SDListViewFontSizeUpDown
    ListViewFontColor           := tSDListViewFontColor
    GuiControlGet, ListViewFontStyle, , SDListViewFontStyleDDL
    ListViewBackgroundColor     := tSDListViewBackgroundColor
    ListViewHWFontColor         := tSDListViewHWFontColor
    ListViewHWBackgroundColor   := tSDListViewHWBackgroundColor
    
    GuiControlGet, BacktickFilterWindows, , SDBacktickFilterWindowsCheckBox
    GuiControlGet, SimilarProcessGroupsStr, , SDSimilarProcessGroupsEdit
    SimilarProcessGroupsStr := Trim(SimilarProcessGroupsStr, " `t`n")
    PrintKV("SimilarProcessGroupsStr", SimilarProcessGroupsStr)
    ProcessDictList := GetProcessDictList(SimilarProcessGroupsStr)
    PrintProcessDictList("ProcessDictList", ProcessDictList)
    
    GuiControlGet, PromptTerminateAll, , SDPromptTerminateAllCheckBox
    GuiControlGet, ShowStatusBar, , SDShowStatusBarCheckBox
    GuiControlGet, WindowTransparency, , SDWindowTransparencyUpDown
    GuiControlGet, WindowWidthPercentage, , SDWindowWidthPercentageUpDown
    GuiControlGet, WindowHeightMaxPercentage, , SDWindowHeightMaxPercentageUpDown
    GuiControlGet, CheckForUpdates, , SDCheckForUpdatesDDL
Return


; -----------------------------------------------------------------------------
; On Apply
; -----------------------------------------------------------------------------
SDApplyBtnHandler:
    PrintSub("SDApplyBtnHandler")
    Gosub, ApplySettings
    PrintSettings()
    IniFileData("Write")
    ;~ Gui, SettingsDialog:Hide
    
    ; Reload the settings to temp variables
    StoreSettingsInTempVariables()	
    CheckSettingsModified()
    ApplyCheckForUpdatesChanges()
Return


; -----------------------------------------------------------------------------
; ResetBtnHandler
; -----------------------------------------------------------------------------
ResetBtnHandler:
    Gui, +OwnDialogs    ; To display a modal dialog
    MsgBox, 292, Reset Settings, Are you sure you want to reset settings?
    IfMsgBox, No
    {
        return
    }

    CreateDefaultINIFile(SettingsINIFilePath)
    IniFileData("Read")	
    ; TODO: Need to reload the window with default settings
    Gui, SettingsDialog:Destroy
    ShowSettingsDialog()
    ApplyCheckForUpdatesChanges()
Return


; -----------------------------------------------------------------------------
; Import Btn Handler
; -----------------------------------------------------------------------------
ImportBtnHandler:
    Gui, +OwnDialogs
    FileSelectFile, importINIPath, S, %A_ScriptDir%\AltTabAlternativeSettings.ini, Import Settings, INI files (*.ini)
    if (importINIPath != "") {
        PrintKV("importINIPath", importINIPath)
        IniFileDataNew(importINIPath, "Read")
        ; TODO: Need to reload the window with default settings
        Gui, SettingsDialog:Destroy
        ShowSettingsDialog()
        ApplyCheckForUpdatesChanges()
    }
Return


; -----------------------------------------------------------------------------
; Ok Btn Handler
; -----------------------------------------------------------------------------
OkBtnHandler:
    PrintSub("OkBtnHandler")
    if (IsSettingsModified()) {
        Print("IsSettingsModified = true")
        Gosub, ApplySettings
        PrintSettings()
        IniFileData("Write")
        ApplyCheckForUpdatesChanges()
    }
    Gui, SettingsDialog:Destroy
Return


; -----------------------------------------------------------------------------
; Export Btn Handler
; -----------------------------------------------------------------------------
SDExportBtnHandler:
    Gui, +OwnDialogs
    FormatTime, dtStr, , yyyyMMddHHmm
    FileSelectFile, exportINIPath, S, %A_ScriptDir%\AltTabAlternativeSettings_%dtStr%.ini, Export Settings, INI files (*.ini)
    if (exportINIPath != "") {
        PrintKV("SettingsINIFilePath", SettingsINIFilePath)
        PrintKV("exportINIPath", exportINIPath)
        Run, %ComSpec% /C "COPY /Y ""%SettingsINIFilePath%"" ""%exportINIPath%""", , Hide
        if (ErrorLevel != 0) {
            MsgBox, Failed to export settings to "%exportINIPath%".
        }
    }
Return


; -----------------------------------------------------------------------------
; SDSearchString FontName Change
; -----------------------------------------------------------------------------
SDSearchStringFontNameDDLHandler:
    GuiControlGet, tSDSearchStringFontName, , SDSearchStringFontNameDDL
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; SDSearchString FontSize Change
; -----------------------------------------------------------------------------
SDSearchStringFontSizeUpDownHandler:
    GuiControlGet, tSDSearchStringFontSize, , SDSearchStringFontSizeUpDown
    CheckSettingsModified()
return


; -----------------------------------------------------------------------------
; SDSearchString FontColor Change
; -----------------------------------------------------------------------------
SDSearchStringFontColorChangeBtnHandler:
    PrintKV("tSDSearchStringFontColor", tSDSearchStringFontColor)
    Color := tSDSearchStringFontColor
    PrintKV("Before Color", Color)
    if (ChooseColor(Color, hSettingsDialog) and Color != tSDSearchStringFontColor) {
        PrintKV("After Color", Color)
        tSDSearchStringFontColor := Color
        GuiControl, +c%tSDSearchStringFontColor%, SDSearchStringFontColorProgress
        CheckSettingsModified()
    }
Return


; -----------------------------------------------------------------------------
; SDSearchString FontStyle Change
; -----------------------------------------------------------------------------
SDSearchStringFontStyleDDLHandler:
    GuiControlGet, tSDSearchStringFontStyle, , SDSearchStringFontStyleDDL
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; SDListView FontName Change
; -----------------------------------------------------------------------------
SDListViewFontNameDDLHandler:
    GuiControlGet, tSDListViewFontName, , SDListViewFontNameDDL
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; SDListView FontSize Change
; -----------------------------------------------------------------------------
SDListViewFontSizeUpDownHandler:
    GuiControlGet, tSDListViewFontSize, , SDListViewFontSizeUpDown
    CheckSettingsModified()
return


; -----------------------------------------------------------------------------
; SDListView FontColor Change
; -----------------------------------------------------------------------------
SDListViewFontColorChangeBtnHandler:
    PrintKV("tSDListViewFontColor", tSDListViewFontColor)
    Color := tSDListViewFontColor
    PrintKV("Before Color", Color)
    if (ChooseColor(Color, hSettingsDialog) and Color != tSDListViewFontColor) {
        PrintKV("After Color", Color)
        tSDListViewFontColor := Color
        GuiControl, +c%tSDListViewFontColor%, SDListViewFontColorProgress
        CheckSettingsModified()
    }
Return


; -----------------------------------------------------------------------------
; SDListView BackgroundColor Change
; -----------------------------------------------------------------------------
SDListViewBkColorChangeBtnHandler:
    PrintKV("tSDListViewBackgroundColor", tSDListViewBackgroundColor)
    Color := tSDListViewBackgroundColor
    PrintKV("Before Color", Color)
    if (ChooseColor(Color, hSettingsDialog) and Color != tSDListViewBackgroundColor) {
        PrintKV("After Color", Color)
        tSDListViewBackgroundColor := Color
        GuiControl, Text, SDListViewBkColorEdit, %ListViewBkColor%
        GuiControl, +c%tSDListViewBackgroundColor%, SDListViewBkColorProgress
        CheckSettingsModified()
    }
Return


; -----------------------------------------------------------------------------
; SDListViewHW FontColor Change
; -----------------------------------------------------------------------------
SDListViewHWFontColorChangeBtnHandler:
    PrintKV("tSDListViewHWFontColor", tSDListViewHWFontColor)
    Color := tSDListViewHWFontColor
    PrintKV("Before Color", Color)
    if (ChooseColor(Color, hSettingsDialog) and Color != tSDListViewHWFontColor) {
        PrintKV("After Color", Color)
        tSDListViewHWFontColor := Color
        GuiControl, +c%tSDListViewHWFontColor%, SDListViewHWFontColorProgress
        CheckSettingsModified()
    }
Return


; -----------------------------------------------------------------------------
; SDListViewHW BackgroundColor Change
; -----------------------------------------------------------------------------
SDListViewHWBkColorChangeBtnHandler:
    PrintKV("tSDListViewHWBackgroundColor", tSDListViewHWBackgroundColor)
    Color := tSDListViewHWBackgroundColor
    PrintKV("Before Color", Color)
    if (ChooseColor(Color, hSettingsDialog) and Color != tSDListViewHWBackgroundColor) {
        PrintKV("After Color", Color)
        tSDListViewHWBackgroundColor := Color
        GuiControl, Text, SDListViewHWBkColorEdit, %ListViewBkColor%
        GuiControl, +c%tSDListViewHWBackgroundColor%, SDListViewHWBkColorProgress
        CheckSettingsModified()
    }
Return


; -----------------------------------------------------------------------------
; SDListView FontStyle Change
; -----------------------------------------------------------------------------
SDListViewFontStyleDDLHandler:
    GuiControlGet, tSDListViewFontStyle, , SDListViewFontStyleDDL
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; PromptTerminateAll CheckBox Handler
; -----------------------------------------------------------------------------
SDPromptTerminateAllCheckBoxHandler:
    GuiControlGet, tSDPromptTerminateAll, , SDPromptTerminateAllCheckBox
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; BacktickFilterWindows CheckBox Handler
; -----------------------------------------------------------------------------
SDBacktickFilterWindowsCheckBoxHandler:
    GuiControlGet, tSDBacktickFilterWindows, , SDBacktickFilterWindowsCheckBox
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; ShowStatusBar CheckBox Handler
; -----------------------------------------------------------------------------
SDShowStatusBarCheckBoxHandler:
    GuiControlGet, tSDShowStatusBar, , SDShowStatusBarCheckBox
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; WindowTransparency UpDown Handler
; -----------------------------------------------------------------------------
SDWindowTransparencyUpDownHandler:
    GuiControlGet, tSDWindowTransparency, , SDWindowTransparencyUpDown
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; WindowWidth Percentage UpDown Handler
; -----------------------------------------------------------------------------
SDWindowWidthPercentageUpDownHandler:
    GuiControlGet, tSDWindowWidthPercentage, , SDWindowWidthPercentageUpDown
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; WindowHeightMax Percentage UpDown Handler
; -----------------------------------------------------------------------------
SDWindowHeightMaxPercentageUpDownHandler:
    GuiControlGet, tSDWindowHeightMaxPercentage, , SDWindowHeightMaxPercentageUpDown
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; Check for updates handler
; -----------------------------------------------------------------------------
SDCheckForUpdatesDDLHandler:
    GuiControlGet, tSDCheckForUpdates, , SDCheckForUpdatesDDL
    CheckSettingsModified()
Return


; -----------------------------------------------------------------------------
; All settings generic handler...
; -----------------------------------------------------------------------------
SDGenericHandler:
    PrintLabel()
    GuiControlGet, tSDSimilarProcessGroupsStr, , SDSimilarProcessGroupsEdit
    ;~ PrintKV("tSDSimilarProcessGroupsStr", tSDSimilarProcessGroupsStr)
    CheckSettingsModified()
Return

} ; ShowSettingsDialog ends here!


CheckSettingsModified() {
    Global
    SettingsModified := IsSettingsModified()
    PrintKV("SettingsModified", SettingsModified)

    if (SettingsModified) {		
        GuiControl, Enable, SDApplyBtn
        GuiControl, Enable, SDCancelBtn
    } else {
        GuiControl, Disable, SDApplyBtn
        GuiControl, Disable, SDCancelBtn
    }
}


IsSettingsModified() {
    Global
    SettingsModified := (tSDSearchStringFontName != SearchStringFontName
        or tSDSearchStringFontSize 	      != SearchStringFontSize
        or tSDSearchStringFontColor       != SearchStringFontColor
        or tSDSearchStringFontStyle       != SearchStringFontStyle
        or tSDListViewFontName            != ListViewFontName
        or tSDListViewFontSize            != ListViewFontSize
        or tSDListViewFontColor           != ListViewFontColor
        or tSDListViewFontStyle           != ListViewFontStyle
        or tSDListViewBackgroundColor     != ListViewBackgroundColor	
        or tSDListViewHWFontColor         != ListViewHWFontColor
        or tSDListViewHWBackgroundColor   != ListViewHWBackgroundColor	
        or tSDBacktickFilterWindows       != BacktickFilterWindows
        or tSDSimilarProcessGroupsStr     != SimilarProcessGroupsStr
        or tSDShowStatusBar               != ShowStatusBar
        or tSDPromptTerminateAll          != PromptTerminateAll
        or tSDWindowTransparency          != WindowTransparency
        or tSDWindowWidthPercentage       != WindowWidthPercentage
        or tSDWindowHeightMaxPercentage   != WindowHeightMaxPercentage
        or tSDCheckForUpdates             != CheckForUpdates)
    ;~ PrintKV("SettingsModified", SettingsModified)
    return SettingsModified
}


; -----------------------------------------------------------------------------
; PrintFontInfo
; -----------------------------------------------------------------------------
PrintFontInfo(ByRef _FontName, ByRef _FontStyle) {
    FontName := "Tahoma" ;Default selected font
    FontStyle := { size: 14, color: 0xFF0000, strikeout: 1, underline: 1, italic: 1, bold: 1 }

    ;~ ShowSettingsDialog(FontName, _FontStyle)
        
    PrintKV("Font Name", 		_FontName)
    PrintKV("Font Size", 		_FontStyle.size)
    PrintKV("Font Color", 		_FontStyle.color)
    PrintKV("Font Color", 		_FontStyle.color)
    PrintKV("Font StrikeOut", 	_FontStyle.strikeout)
    PrintKV("Font Underline", 	_FontStyle.underline)
    PrintKV("Font Italic", 		_FontStyle.italic)
    PrintKV("Font Bold", 		_FontStyle.bold)
}


; -----------------------------------------------------------------------------
; SDSearchStringFontBtnHandler
; To get any of the style return values : value:=style.bold will get you the bold value and so on
; -----------------------------------------------------------------------------
ShowFontDialog(ByRef Name, ByRef Style, hwnd="", effects=1) {
    static logfont
    VarSetCapacity(logfont, 60)
    LogPixels := DllCall("GetDeviceCaps", "uint", DllCall("GetDC", "uint", 0), "uint", 90)
    Effects := 0x041 + (Effects ? 0x100 : 0)
    for a,b in fontval := { 16:style.bold ? 700 : 400, 20:style.italic, 21:style.underline, 22:style.strikeout, 0:style.size ? Floor(style.size * logpixels / 72) : 16 }
    NumPut(b, logfont, a)
    cap := VarSetCapacity(choosefont, A_PtrSize = 8 ? 103 : 60, 0)
    NumPut(hwnd, choosefont, A_PtrSize)
    for index,value in [[cap, 0, "Uint"], [&logfont, A_PtrSize = 8 ? 24 : 12, "Uptr"], [effects, A_PtrSize = 8 ? 36 : 20, "Uint"], [style.color, A_PtrSize = 4 ? 6 * A_PtrSize : 5 * A_PtrSize, "Uint"]]
    NumPut(value.1, choosefont, value.2, value.3)
    
    if (A_PtrSize = 8) {
        strput(name, &logfont + 28)
        r := DllCall("comdlg32\ChooseFont","uptr", &CHOOSEFONT, "cdecl")
        name := strget(&logfont + 28)
    }
    else {
        strput(name, &logfont + 28, 32, "utf-8")
        r := DllCall("comdlg32\ChooseFontA", "uptr", &CHOOSEFONT, "cdecl")
        name := strget(&logfont + 28, 32, "utf-8")
    }
    
    if (!r) {
        return 0
    }
    
    for a, b in { bold:16, italic:20, underline:21, strikeout:22 }
    style[a] := NumGet(logfont, b, "UChar")
    style.bold := style.bold < 188 ? 0 : 1
    style.color := NumGet(choosefont, A_PtrSize = 4 ? 6 * A_PtrSize : 5 * A_PtrSize)
    style.size := NumGet(CHOOSEFONT, A_PtrSize = 8 ? 32 : 16, "UChar") // 10
    ;charset := NumGet(logfont, 23, "UChr")
    return DllCall("CreateFontIndirect", uptr, &logfont, "cdecl")
}


; -----------------------------------------------------------------------------
; This method creates INI file with default settings.
; Deletes the INI file and creates a new one if INI file already exist.
; So, please check the existence of INI file before calling this method.
; -----------------------------------------------------------------------------
CreateDefaultINIFile(SettingsINIFilePath) {
    Global
    Local directoryPath
    PrintSub("CreateDefaultINIFile Begin")
    PrintDefaultSettings()
    PrintKV("SettingsINIFilePath", SettingsINIFilePath)
    If (FileExist(SettingsINIFilePath)) {
        FileDelete, %SettingsINIFilePath%
    }
    else {
        SplitPath, SettingsINIFilePath, , directoryPath
        if (!FileExist(directoryPath)) {
            FileCreateDir, %directoryPath%
            if (ErrorLevel != 0) {
                MsgBox, 48, Error, Failed to create directory "%directoryPath%"
            }
        }
    }

    FileAppend,
    (
; -----------------------------------------------------------------------------
; Configuration/settings file for AltTabAlternative.
; Notes:
;   1. Do NOT edit manually if you are not familiar with settings.
;   2. Color Format is RGB(0xAA, 0xBB, 0xCC) => 0xAABBCC, in hex format.
;      0xAA : Red component
;      0xBB : Green component
;      0xCC : Blue component
;   3. Presently NOT displaying every action in status bar, this is in progress.
; -----------------------------------------------------------------------------
[SearchString]
FontName=%SearchStringFontNameDefault%
FontSize=%SearchStringFontSizeDefault%
FontColor=%SearchStringFontColorDefault%
FontStyle=%SearchStringFontStyleDefault%
[ListView]
FontName=%ListViewFontNameDefault%
FontSize=%ListViewFontSizeDefault%
FontColor=%ListViewFontColorDefault%
FontStyle=%ListViewFontStyleDefault%
BackgroundColor=%ListViewBackgroundColorDefault%
HWFontColor=%ListViewHWFontColorDefault%
HWBackgroundColor=%ListViewHWBackgroundColorDefault%
[Backtick]
FilterWindows=%BacktickFilterWindowsDefault%
SimilarProcessGroups=%SimilarProcessGroupsStrDefault%
[General]
ShowStatusBar=%ShowStatusBarDefault%
PromptTerminateAll=%PromptTerminateAllDefault%
WindowTransparency=%WindowTransparencyDefault%
WindowWidthPercentage=%WindowWidthPercentageDefault%
WindowHeightMaxPercentage=%WindowHeightMaxPercentageDefault%
CheckForUpdates=%CheckForUpdatesDefault%
    ), %SettingsINIFilePath%

    if (ErrorLevel != 0) {
        MsgBox, 48, Error, Failed to create INI file %SettingsINIFilePath%
    }
    
    PrintSub("CreateDefaultINIFile End")
    
    Return
}


; -----------------------------------------------------------------------------
; Read/write settings from/to the settings INI file.
; -----------------------------------------------------------------------------
IniFileData(ReadOrWrite)
{
    Global
    PrintSub("IniFileData")
    PrintKV("SettingsINIFilePath", SettingsINIFilePath)
    DefineDefaultSettings()

    If (!FileExist(SettingsINIFilePath)) {
        CreateDefaultINIFile(SettingsINIFilePath)
    }
    
    IniFileDataNew(SettingsINIFilePath, ReadOrWrite)
}


; -----------------------------------------------------------------------------
; Read/write settings from/to the settings INI file.
; -----------------------------------------------------------------------------
IniFileDataNew(SettingsINIFilePathIn, ReadOrWrite)
{
    Global
    PrintSub("IniFileDataNew")
    PrintKV("SettingsINIFilePathIn", SettingsINIFilePathIn)
    
    if ReadOrWrite = Read
    {
        ReadVariable("SearchStringFontName",    	SettingsINIFilePathIn, "SearchString", "FontName",                  SearchStringFontNameDefault)
        ReadVariable("SearchStringFontSize",    	SettingsINIFilePathIn, "SearchString", "FontSize",                  SearchStringFontSizeDefault)
        ReadVariable("SearchStringFontColor",   	SettingsINIFilePathIn, "SearchString", "FontColor",                 SearchStringFontColorDefault)
        ReadVariable("SearchStringFontStyle",   	SettingsINIFilePathIn, "SearchString", "FontStyle",                 SearchStringFontStyleDefault)
        ReadVariable("ListViewFontName",        	SettingsINIFilePathIn, "ListView",     "FontName",                  ListViewFontNameDefault)
        ReadVariable("ListViewFontSize",        	SettingsINIFilePathIn, "ListView",     "FontSize",                  ListViewFontSizeDefault)
        ReadVariable("ListViewFontColor",       	SettingsINIFilePathIn, "ListView",     "FontColor",                 ListViewFontColorDefault)
        ReadVariable("ListViewFontStyle",       	SettingsINIFilePathIn, "ListView",     "FontStyle",                 ListViewFontStyleDefault)
        ReadVariable("ListViewBackgroundColor", 	SettingsINIFilePathIn, "ListView",     "BackgroundColor",           ListViewBackgroundColorDefault)
        ReadVariable("ListViewHWFontColor",       	SettingsINIFilePathIn, "ListView",     "HWFontColor",               ListViewHWFontColorDefault)
        ReadVariable("ListViewHWBackgroundColor", 	SettingsINIFilePathIn, "ListView",     "HWBackgroundColor",         ListViewHWBackgroundColorDefault)
        ReadVariable("BacktickFilterWindows",      	SettingsINIFilePathIn, "Backtick",     "FilterWindows",             BacktickFilterWindowsDefault)
        ReadVariable("SimilarProcessGroupsStr",     SettingsINIFilePathIn, "Backtick",     "SimilarProcessGroups",      SimilarProcessGroupsStrDefault)
        ReadVariable("ShowStatusBar",      	        SettingsINIFilePathIn, "General",      "ShowStatusBar",             ShowStatusBarDefault)
        ReadVariable("PromptTerminateAll",      	SettingsINIFilePathIn, "General",      "PromptTerminateAll",        PromptTerminateAllDefault)
        ReadVariable("WindowTransparency",      	SettingsINIFilePathIn, "General",      "WindowTransparency",        WindowTransparencyDefault)
        ReadVariable("WindowWidthPercentage",   	SettingsINIFilePathIn, "General",      "WindowWidthPercentage",     WindowWidthPercentageDefault)
        ReadVariable("WindowHeightMaxPercentage",   SettingsINIFilePathIn, "General",      "WindowHeightMaxPercentage", WindowHeightMaxPercentageDefault)
        ReadVariable("CheckForUpdates",             SettingsINIFilePathIn, "General",      "CheckForUpdates",           CheckForUpdatesDefault)
        
        ListViewFontColorBGR            := RGBtoBGR(ListViewFontColor)
        ListViewBackgroundColorBGR      := RGBtoBGR(ListViewBackgroundColor)
        ListViewHWFontColorBGR          := RGBtoBGR(ListViewHWFontColor)
        ListViewHWBackgroundColorBGR    := RGBtoBGR(ListViewHWBackgroundColor)
        
        ProcessDictList := GetProcessDictList(SimilarProcessGroupsStr)
        ProcessDictListIndex := -1
    }
    else
    {
        WriteVariable(SearchStringFontName,         SettingsINIFilePathIn, "SearchString", "FontName",                  SearchStringFontNameDefault)
        WriteVariable(SearchStringFontSize,         SettingsINIFilePathIn, "SearchString", "FontSize",                  SearchStringFontSizeDefault)
        WriteVariable(SearchStringFontColor,        SettingsINIFilePathIn, "SearchString", "FontColor",                 SearchStringFontColorDefault)
        WriteVariable(SearchStringFontStyle,        SettingsINIFilePathIn, "SearchString", "FontStyle",                 SearchStringFontStyleDefault)
        WriteVariable(ListViewFontName,             SettingsINIFilePathIn, "ListView",     "FontName",                  ListViewFontNameDefault)
        WriteVariable(ListViewFontSize,             SettingsINIFilePathIn, "ListView",     "FontSize",                  ListViewFontSizeDefault)
        WriteVariable(ListViewFontColor,            SettingsINIFilePathIn, "ListView",     "FontColor",                 ListViewFontColorDefault)
        WriteVariable(ListViewFontStyle,            SettingsINIFilePathIn, "ListView",     "FontStyle",                 ListViewFontStyleDefault)
        WriteVariable(ListViewBackgroundColor,      SettingsINIFilePathIn, "ListView",     "BackgroundColor",           ListViewBackgroundColorDefault)
        WriteVariable(ListViewHWFontColor,          SettingsINIFilePathIn, "ListView",     "HWFontColor",               ListViewHWFontColorDefault)
        WriteVariable(ListViewHWBackgroundColor,    SettingsINIFilePathIn, "ListView",     "HWBackgroundColor",         ListViewHWBackgroundColorDefault)
        WriteVariable(BacktickFilterWindows,        SettingsINIFilePathIn, "Backtick",     "FilterWindows",             BacktickFilterWindowsDefault)
        WriteVariable(SimilarProcessGroupsStr,      SettingsINIFilePathIn, "Backtick",     "SimilarProcessGroups",      SimilarProcessGroupsStrDefault)
        WriteVariable(ShowStatusBar,                SettingsINIFilePathIn, "General",      "ShowStatusBar",             ShowStatusBarDefault)
        WriteVariable(PromptTerminateAll,           SettingsINIFilePathIn, "General",      "PromptTerminateAll",        PromptTerminateAllDefault)
        WriteVariable(WindowTransparency,           SettingsINIFilePathIn, "General",      "WindowTransparency",        WindowTransparencyDefault)
        WriteVariable(WindowWidthPercentage,        SettingsINIFilePathIn, "General",      "WindowWidthPercentage",     WindowWidthPercentageDefault)
        WriteVariable(WindowHeightMaxPercentage,    SettingsINIFilePathIn, "General",      "WindowHeightMaxPercentage", WindowHeightMaxPercentageDefault)
        WriteVariable(CheckForUpdates,              SettingsINIFilePathIn, "General",      "CheckForUpdates",           CheckForUpdatesDefault)
    }
}


; -----------------------------------------------------------------------------
; Read the setting from INI file
; -----------------------------------------------------------------------------
ReadVariable(VarName, SettingsINIFilePath, Section, Key, Default="")
{
    INIFile(VarName, SettingsINIFilePath, Section, Key, Default, "Read")
}


; -----------------------------------------------------------------------------
; Write the setting to INI file
; -----------------------------------------------------------------------------
WriteVariable(Value, SettingsINIFilePath, Section, Key, WriteEmpty=true)
{
    INIFile(Value, SettingsINIFilePath, Section, Key, "", "Write", WriteEmpty)
}


; -----------------------------------------------------------------------------
; Read/Write the setting from/to INI file
; -----------------------------------------------------------------------------
INIFile(VarName, SettingsINIFilePath, Section, Key, Default, ReadOrWrite="Read", WriteEmpty=true)
{
    ;~ PrintKV("VarName", VarName)
    ;~ PrintKV("ReadOrWrite", ReadOrWrite)
    ;~ PrintKV2("Section", Section, "Key", Key)
    
    If ReadOrWrite = Read
    {
        IniRead, %VarName%, %SettingsINIFilePath%, %Section%, %Key%, %Default%
        If %VarName% = ERROR
            %VarName% = ; set to blank value instead of "error"
    }
    Else If ReadOrWrite = Write
    {
        If not WriteEmpty
        {
            If %VarName% =  ;Test if Var is empty
            {
                ; Test if the field in INI is existed
                IniRead, temp_var, %SettingsINIFilePath%, %Section%, %Var%
                If temp_var = ERROR
                    return
            }
        }

        IniWrite, %VarName%, %SettingsINIFilePath%, %Section%, %Key%
    }
}


; -----------------------------------------------------------------------------
; Move the list of buttons to the center of a window
; -----------------------------------------------------------------------------
MoveControlsToHorizontalCenter(Piped_CtrlvNames, Width)
{
    ;~ Local minX, minY, maxX, maxY
    Local minX := 10000, minY := 10000, maxX := 0, maxY := 0
    ;~ PrintKV("Width", Width)
    Loop, Parse, Piped_CtrlvNames, |, %A_Space%
    {
        ; Get position and size of each control in list.
        GuiControlGet, Pos, Pos, %A_LoopField%
        ;~ Print4(PosX, PosY, PosW, PosH)
        
        ; Creates PosX, PosY, PosW, PosH
        if (PosX < minX) { ; Check for minimum X
            minX := PosX
        }
        if (PosY < minY) { ; Check for minimum Y
            minY := PosY
        }
        if (PosX + PosW > maxX) { ;Check for maximum X
            maxX := PosX + PosW
        }
        if (PosY + PosH > maxY) { ;Check for maximum Y
            maxY := PosY + PosH
        }
    }
    ;~ Print4(minX, minY, maxX, maxY)

    offsetX := (Width - (maxX - minX + 1)) / 2 - minX
    ;~ PrintKV("offsetX", offsetX)
    Loop, Parse, Piped_CtrlvNames, |, %A_Space%
    {
        ; Get position and size of each control in list.
        GuiControlGet, Pos, Pos, %A_LoopField%
        newX := PosX + offsetX
        ;~ PrintKV2("PosX", PosX, "newX", newX)
        GuiControl, MoveDraw, %A_LoopField%, x%newX%
    }	
}

; -----------------------------------------------------------------------------
; Show the color dialog box to choose the color
;
; Color  : specifies the color initially selected when the dialog box is created.
; hOwner : Optional handle to the window that owns the dialog. Affects dialog position.
; Returns: Nonzero if the user clicks the OK button.
; -----------------------------------------------------------------------------
ChooseColor(ByRef Color, hOwner := 0) {
    rgbResult := RGBtoBGR(Color)

    VarSetCapacity(CUSTOM, 16 * A_PtrSize, 0)
    size := VarSetCapacity(CHOOSECOLOR, 9 * A_PtrSize, 0)
    NumPut(size, CHOOSECOLOR, 0, "UInt")
    NumPut(hOwner, CHOOSECOLOR, A_PtrSize, "UPtr")
    NumPut(rgbResult, CHOOSECOLOR, 3 * A_PtrSize, "UInt")
    NumPut(3, CHOOSECOLOR, 5 * A_PtrSize, "UInt")
    NumPut(&CUSTOM, CHOOSECOLOR, 4 * A_PtrSize, "UPtr")

    RetVal := DllCall("comdlg32\ChooseColor", "UPtr", &CHOOSECOLOR, "UInt")
    If (ErrorLevel != 0) || (RetVal = 0) {
        Return False
    }

    rgbResult := NumGet(CHOOSECOLOR, 3 * A_PtrSize, "UInt")
    Color := RGBtoBGR(rgbResult)
    
    Return True
}


; -----------------------------------------------------------------------------
; Convert the color RGB to BGR, i.e. 0xRRGGBB => 0xBBGGRR
; -----------------------------------------------------------------------------
RGBtoBGR(rgb) {
    setformat, IntegerFast, H    
    bgr := (rgb & 0x00ff00) + ((rgb & 0xff0000) >> 16) + ((rgb & 0x0000ff) << 16)
    
    ; Format returns 00000000 if value is 0
    if (bgr = 0) {
        bgr := 0x000000
    } else {
        bgr := Format("{:#08x}", bgr)
    }
    SetFormat, IntegerFast, D
    return bgr
}


; -----------------------------------------------------------------------------
; Print settings that are used by the origional application
; -----------------------------------------------------------------------------
PrintSettings() {
    Global
    PrintKV("SearchStringFontName",  SearchStringFontName)
    PrintKV("SearchStringFontSize",  SearchStringFontSize)
    PrintKV("SearchStringFontColor", SearchStringFontColor)
    PrintKV("SearchStringFontStyle", SearchStringFontStyle)
    PrintKV("ListViewFontName",  ListViewFontName)
    PrintKV("ListViewFontSize",  ListViewFontSize)
    PrintKV("ListViewFontColor", ListViewFontColor)
    PrintKV("ListViewFontStyle", ListViewFontStyle)
    PrintKV("ListViewBackgroundColor", ListViewBackgroundColor)
    PrintKV("ListViewHWFontColor", ListViewHWFontColor)
    PrintKV("ListViewHWBackgroundColor", ListViewHWBackgroundColor)
    PrintKV("BacktickFilterWindows", BacktickFilterWindows)
    PrintKV("SimilarProcessGroupsStr", SimilarProcessGroupsStr)
    PrintProcessDictList("ProcessDictList", ProcessDictList)    
    PrintKV("ShowStatusBar", ShowStatusBar)
    PrintKV("PromptTerminateAll", PromptTerminateAll)
    PrintKV("WindowTransparency", WindowTransparency)
    PrintKV("WindowWidthPercentage", WindowWidthPercentage)
    PrintKV("WindowHeightMaxPercentage", WindowHeightMaxPercentage)
    PrintKV("CheckForUpdates", CheckForUpdates)
}


; -----------------------------------------------------------------------------
; Print default settings
; -----------------------------------------------------------------------------
PrintDefaultSettings() {
    Global
    PrintKV("SearchStringFontNameDefault",  SearchStringFontNameDefault)
    PrintKV("SearchStringFontSizeDefault",  SearchStringFontSizeDefault)
    PrintKV("SearchStringFontColorDefault", SearchStringFontColorDefault)
    PrintKV("SearchStringFontStyleDefault", SearchStringFontStyleDefault)
    PrintKV("ListViewFontNameDefault",  ListViewFontNameDefault)
    PrintKV("ListViewFontSizeDefault",  ListViewFontSizeDefault)
    PrintKV("ListViewFontColorDefault", ListViewFontColorDefault)
    PrintKV("ListViewFontStyleDefault", ListViewFontStyleDefault)
    PrintKV("ListViewBackgroundColorDefault", ListViewBackgroundColorDefault)
    PrintKV("ListViewHWFontColorDefault", ListViewHWFontColorDefault)
    PrintKV("ListViewHWBackgroundColorDefault", ListViewHWBackgroundColorDefault)
    PrintKV("BacktickFilterWindowsDefault", BacktickFilterWindowsDefault)
    PrintKV("SimilarProcessGroupsStrDefault", SimilarProcessGroupsStrDefault)
    PrintKV("ShowStatusBarDefault", ShowStatusBarDefault)
    PrintKV("PromptTerminateAllDefault", PromptTerminateAllDefault)
    PrintKV("WindowTransparencyDefault", WindowTransparencyDefault)
    PrintKV("WindowWidthPercentageDefault", WindowWidthPercentageDefault)
    PrintKV("WindowHeightMaxPercentageDefault", WindowHeightMaxPercentageDefault)
    PrintKV("CheckForUpdatesDefault", CheckForUpdatesDefault)
}


; -----------------------------------------------------------------------------
; Please use the prefix SD for all the variables inside Settings Dialog
; -----------------------------------------------------------------------------
GetFontStyleIndex(fontStyleIn) {
    FontStyleList = norm|italic|bold|bold italic
    fontStyleIndex := 0
    loopIndex := 0
    Loop Parse, FontStyleList, |
    {
        ++loopIndex
        ;~ PrintKV("A_LoopField", A_LoopField)
        if (fontStyleIndex = 0 and fontStyleIn = A_LoopField) {
            fontStyleIndex := loopIndex
            ;~ Print("MatchFound")
        }
    }
    Return fontStyleIndex
}

GetCheckForUpdatesIndex(UpdateOptionsList, updateIn) {
    updateIndex := 0
    loopIndex := 0
    Loop Parse, UpdateOptionsList, |
    {
        ++loopIndex
        if (updateIndex = 0 and updateIn = A_LoopField) {
            updateIndex := loopIndex
            ;~ Print("MatchFound")
        }
    }
    Return updateIndex
}


; -----------------------------------------------------------------------------
; Store the present settings into temporary variables, we use these temporary
; variables to get the modified settings from controls to it. If any settings
; is modified then do the necessary actions.
; Ex: Enable/Disable "Apply" button or write the INI file only when the
;     settings are modified and so on...
; -----------------------------------------------------------------------------
StoreSettingsInTempVariables() {
    Global
    PrintSub("StoreSettingsInTempVariables")
    tSDSearchStringFontName         := SearchStringFontName
    tSDSearchStringFontSize         := SearchStringFontSize
    tSDSearchStringFontColor        := SearchStringFontColor
    tSDSearchStringFontStyle        := SearchStringFontStyle
    tSDListViewFontName             := ListViewFontName
    tSDListViewFontSize             := ListViewFontSize
    tSDListViewFontColor            := ListViewFontColor
    tSDListViewFontStyle            := ListViewFontStyle
    tSDListViewBackgroundColor      := ListViewBackgroundColor	
    tSDListViewHWFontColor          := ListViewHWFontColor
    tSDListViewHWBackgroundColor    := ListViewHWBackgroundColor
    tSDBacktickFilterWindows        := BacktickFilterWindows
    tSDSimilarProcessGroupsStr      := SimilarProcessGroupsStr
    tSDShowStatusBar                := ShowStatusBar
    tSDPromptTerminateAll           := PromptTerminateAll
    tSDWindowTransparency           := WindowTransparency
    tSDWindowWidthPercentage        := WindowWidthPercentage
    tSDWindowHeightMaxPercentage    := WindowHeightMaxPercentage
    tSDCheckForUpdates              := CheckForUpdates
}


; -----------------------------------------------------------------------------
; These are the default settings of AltTabAlternative
; -----------------------------------------------------------------------------
DefineDefaultSettings() {
    Global
    PrintSub("DefineDefaultSettings")
    SearchStringFontNameDefault         := "Lucida Handwriting"
    SearchStringFontSizeDefault         := 11
    SearchStringFontColorDefault        := 0xFF0000
    SearchStringFontStyleDefault        := "norm"
    ListViewFontNameDefault             := "Lucida Handwriting"
    ListViewFontSizeDefault             := 11
    ListViewFontColorDefault            := 0xFFFFFF
    ListViewFontStyleDefault            := "norm"
    ListViewBackgroundColorDefault      := 0x000000
    ListViewHWFontColorDefault          := 0x000000
    ListViewHWBackgroundColorDefault    := 0xFFC90E
    BacktickFilterWindowsDefault        := true
    SimilarProcessGroupsStrDefault      := "notepad.exe/notepad++.exe|iexplore.exe/chrome.exe/firefox.exe|explorer.exe/xplorer2_lite.exe/xplorer2.exe/xplorer2_64.exe"
    ShowStatusBarDefault                := false
    PromptTerminateAllDefault           := true
    WindowTransparencyDefault           := 222
    WindowWidthPercentageDefault        := 45
    WindowHeightMaxPercentageDefault    := 50
    CheckForUpdatesDefault              := "Weekly"
}


; -----------------------------------------------------------------------------
; RunCheckForUpdates
; -----------------------------------------------------------------------------
RunCheckForUpdates() {
    Global
    PrintSub("RunCheckForUpdates")
    StopCheckForUpdates()
    PrintKV("CheckForUpdates", CheckForUpdates)

    if (CheckForUpdates = "Startup") {
        CheckForUpdatesFunction(false)
        Return
    }
    else if (CheckForUpdates = "Never") {
        Return
    }
    else {
        ApplyCheckForUpdatesChanges()
    }
}

; -----------------------------------------------------------------------------
; Apply CheckForUpdates Changes
; -----------------------------------------------------------------------------
ApplyCheckForUpdatesChanges() {
    Global
    PrintSub("ApplyCheckForUpdatesChanges")
    StopCheckForUpdates()
    PrintKV("CheckForUpdates", CheckForUpdates)

    if (CheckForUpdates = "Startup" or CheckForUpdates = "Never") {
        Return
    }
    else {
        ; Daily or Weekly so proceed further.
    }

    SetTimer, CheckForUpdatesLabel, 3600000 ; Check to CheckForUpdates for every hour
    ; Do NOT quit immediately, run CheckForUpdatesLabel once and return.
    ;~ Return

    CheckForUpdatesLabel:
        PrintSub("CheckForUpdatesLabel")
        FileRead, checkForUpdatesLastRun, %CheckForUpdatesFilePath%
        if (!checkForUpdatesLastRun) {
            file := FileOpen(CheckForUpdatesFilePath, "w")
            file.Write(A_Now)
            file.Close()            
            checkForUpdatesLastRun := A_Now
        }
        PrintKV("checkForUpdatesLastRun", checkForUpdatesLastRun)
        daysDiff := A_Now
        EnvSub, daysDiff, %checkForUpdatesLastRun%, Days
        PrintKV("daysDiff", daysDiff)      

        if (CheckForUpdates = "Daily" and daysDiff >= 1) {
            CheckForUpdatesFunction(false)
        }
        else if (CheckForUpdates = "Weekly" and daysDiff >= 7) {
            CheckForUpdatesFunction(false)
        }        
    Return
}

StopCheckForUpdates() {
    Global
    SetTimer, CheckForUpdatesLabel, Off
}

; -----------------------------------------------------------------------------
; Check for updates
; Param ShowNoUpdatesMsgBox: Doesn't display "No updates available" msgbox if
;   updates are not available.
; For example: If user sets Hourly to "Check for updates", it's not good to
;   display "No updates available" msgbox every hour (each time).
; -----------------------------------------------------------------------------
CheckForUpdatesFunction(ShowNoUpdatesMsgBox=false) {
    Global ProgramName, ProductVersion, UpdateFileURL, ProductPage, CheckForUpdatesFilePath
    PrintSub("CheckForUpdatesFunction")
    MouseGetPos, xpos, ypos
    ;~ PrintKV2("xpos", xpos, "ypos", ypos)
    Tooltip, Checking for Updates......`, please wait, xpos, ypos, 1
    
    ATALatestVersionFile := A_Temp . "\ata_latestversion.txt"
    URLDownloadToFile, %UpdateFileURL%, %ATALatestVersionFile%
    Tooltip

    if (!FileExist(ATALatestVersionFile)) {
        MsgBox, 0x0, AltTabAlternative, Failed to download %UpdateFileURL%
        Return
    }

    latestVersionChanges := "`n`nCHANGES`n"
    FileRead, temp, %ATALatestVersionFile%
    Loop, parse, temp, `n, `r
    {
        if (A_index = 1) {
            latestVersion := A_LoopField
        }
        else {
            latestVersionChanges .= "`n" A_LoopField
        }
    }
    FileDelete, %ATALatestVersionFile%

    if (!IsLatestRelease(ProductVersion, latestVersion)) {
		MsgBox, 64, %ProgramName% Update Available, % "Your Version: `t" ProductVersion "`nLatest Version: `t" latestVersion . latestVersionChanges
		IfMsgBox OK
			Run, %ProductPage%
    }
	else {
        if (ShowNoUpdatesMsgBox) {
            MsgBox, 64, %ProgramName%, No updates available
        }
    }
    
    ; Write the lastrun for CheckForUpdates to file
    Print("Updating " . CheckForUpdatesFilePath)
    file := FileOpen(CheckForUpdatesFilePath, "w")
    file.Write(A_Now)
    file.Close()
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
		if (programVersionArray%A_index% < currentVersionArray%A_index%) {
			return false
        }
		else if (programVersionArray%A_index% > currentVersionArray%A_index%) {
            ; in case currentVersion supplied is of old file
			return true
        }
    }
	return true
}


; -----------------------------------------------------------------------------
; This function returns true if processes in the SimilarProcessGroupsStr are
;   seperated by | and processes are seperated by / otherwise false.
; An invalid process name will be set to invalidProcName output variable if found.
; Ex: notepad++.exe/notepad.exe|chrome.exe/iexplore.exe|explorer.exe/xplorer2_64.exe
; -----------------------------------------------------------------------------
IsValidSimilarProcessGroupsString(SimilarProcessGroupsStr, ByRef errorMessage) {
	ProcessNameRegEx := "^[^\\/:*?""<>|`n`t]+.exe$"
	StringSplit, procNames, SimilarProcessGroupsStr, "/|"
	Loop, %procNames0% {
		procName := procNames%A_Index%
		FoundPos := RegExMatch(procName, ProcessNameRegEx)
		if (FoundPos == 0) {
			errorMessage := Format("Found an invalid process name [{}] in group {}", procName, A_Index)
			return false
		}
	}
	
    ; Check whether any process is in multiple process groups
    procDictList := GetProcessDictList(SimilarProcessGroupsStr)
	isValid := IsValidProcessDictList(procDictList, errorMessage)
	if (!isValid) {
		return false
	}
	
	return true
}


; -----------------------------------------------------------------------------
; This methods checks if any process listed in multiple process groups.
; Returns
;    true : if no process is available in other process group
;   false : otherwise
; -----------------------------------------------------------------------------
IsValidProcessDictList(procDictList, ByRef errorMessage) {
    len := procDictList.Length()
    Loop, % len {
		i := A_Index, j := i + 1
		dict := procDictList[i]
		while j <= len {
			for key, val in dict {
				if (procDictList[j].HasKey(key)) {
					errorMessage := Format("Process name [{}] is available in multiple groups {}, {}.", key, i, j)
					return false
				}
			}
			++j
	    }
    }
	return true
}


; -----------------------------------------------------------------------------
; This function returns the list of process name dictionary ([{}])
;	SimilarProcessGroupsStr : ProcessList are seperated by | and processes are seperated by /.
;		Ex: notepad++.exe/notepad.exe|chrome.exe/iexplore.exe|explorer.exe/xplorer2_64.exe
; -----------------------------------------------------------------------------
GetProcessDictList(SimilarProcessGroupsStr) {
	ret := []
	StringSplit, processLists, SimilarProcessGroupsStr, "|"
	processListsLen := processLists0
	
	Loop, %processListsLen% {
		dict := {}
		i := A_Index
		StringSplit, processList, processLists%i%, "/"
		Loop, %processList0% {
			j := A_Index
			dict[processList%j%] := true
		}
		ret.Insert(dict)
	}
	return ret
}


; -----------------------------------------------------------------------------
; This function returns the index of ProcessDictList if procName found
; else returns -1
; -----------------------------------------------------------------------------
GetProcessDictListIndex(ProcessDictList, procName) {
	len := ProcessDictList.Length()
	Loop, %len% {
		if (ProcessDictList[A_Index].HasKey(procName)) {
			return A_Index
		}
	}
	return -1
}


; -----------------------------------------------------------------------------
; Print ProcessDictList
; -----------------------------------------------------------------------------
PrintProcessDictList(str, lst) {
    Local len
    len := lst.Length()
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
    FileAppend, [%CurrentTime%] %str% = (%len%)[, *
    Loop, % len
    {
        ;~ FileAppend, % lst[A_Index] . "`, " , *
		dict := lst[A_Index]
		FileAppend, `n`titem[%A_Index%] = {, *
		for key, val in dict {
			kv := Format("({}, {}), ", key, val)
			FileAppend, % kv, *
	    }
		FileAppend, }, *
    }
    FileAppend, `n]`n, *
}


#Include %A_ScriptDir%\Lib\Fnt.ahk
