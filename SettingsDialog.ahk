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

;~ ; This is for my testing
;~ If (true) {
    ;~ ProductName             := "AltTabAlternative"
    ;~ SettingsINIFileName         := "AltTabAlternativeSettings.ini"
    ;~ SettingsDirPath             := A_AppData . "\" . ProductName
    ;~ SettingsINIFilePath     := SettingsDirPath . "\" . SettingsINIFileName
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

    SDGroupWidth 		:= 264
    SDGroupHeight 		:= 144
    SDTextCtrlFontSize 	:= 10
    SecondColumnOffset  := 57
    
    Gui, SettingsDialog: New, +hwndhSettingsDialog, %ProductName% Settings
    Gui, Margin, 5, 5

    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm ym+5 vSDStorageText hwndhSDStorageText, Storage:
    Gui, Add, Edit, x+3 yp-3 w426 vSDStorageEdit hwndhSDStorageEdit ReadOnly -Multi, %SettingsINIFilePath%
    Gui, Add, Button, x+3 yp-1 w60 vSDExportBtn hwndhSDExportBtn gSDExportBtnHandler, &Export...
    ; -----------------------------------------------------------------------------
    Gui, Add, GroupBox, xm y33 Section vSearchStringGroupBox W%SDGroupWidth% H%SDGroupHeight% cBlue, SearchString Font
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 yp+21 vSDSearchStringFontNameText, &Name:
    Gui, Add, DropDownList, xm+%SecondColumnOffset% yp-3 w200 R15 vSDSearchStringFontNameDDL Choose%SearchStringFontIndex% gSDSearchStringFontNameDDLHandler, %fontDropDownList%
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 y+6 vSDSearchStringFontSizeText, &Size:
    Gui, Add, Edit, xm+%SecondColumnOffset% yp-3 w200
    Gui, Add, UpDown, vSDSearchStringFontSizeUpDown gSDSearchStringFontSizeUpDownHandler Range8-25, %SearchStringFontSize%
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 y+6 vSDSearchStringFontColorText, &Color:
    Gui, Add, Progress, xm+%SecondColumnOffset% yp-3 w200 h21 vSDSearchStringFontColorProgress c%SearchStringFontColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xp yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDSearchStringFontColorProgressText gSDSearchStringFontColorChangeBtnHandler
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xm+5 y+6 vSDSearchStringFontStyleText, St&yle:
    Gui, Add, DropDownList, xm+%SecondColumnOffset% yp-3 w200 vSDSearchStringFontStyleDDL gSDSearchStringFontStyleDDLHandler Choose%SearchStringFontStyleIndex%, norm|italic|bold|bold italic
    ; -----------------------------------------------------------------------------

    ; -----------------------------------------------------------------------------
    SDControlPosX := SDGroupWidth + 3
    Gui, Add, GroupBox, xm+%SDControlPosX% y33 Section vListViewGroupBox W%SDGroupWidth% H144 cBlue, ListView Font
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 yp+21 vSDListViewFontNameText, &Name:
    Gui, Add, DropDownList, xs+%SecondColumnOffset% yp-3 w200 R15 vSDListViewFontNameDDL gSDListViewFontNameDDLHandler Choose%ListViewFontIndex%, %fontDropDownList%
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewFontSizeText, &Size:
    Gui, Add, Edit, xs+%SecondColumnOffset% yp-3 w200
    Gui, Add, UpDown, vSDListViewFontSizeUpDown gSDListViewFontSizeUpDownHandler Range8-25, %ListViewFontSize%
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewFontColorText, &Color:
    Gui, Add, Progress, xs+%SecondColumnOffset% yp-3 w200 h21 vSDListViewFontColorProgress c%ListViewFontColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xs yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDListViewFontColorProgressText gSDListViewFontColorChangeBtnHandler
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewFontStyleText, St&yle:
    Gui, Add, DropDownList, xs+%SecondColumnOffset% yp-3 w200 vSDListViewFontStyleDDL gSDListViewFontStyleDDLHandler Choose%ListViewFontStyleIndex%, norm|italic|bold|bold italic
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 vSDListViewBkColorText, &Bk Color:
    Gui, Add, Progress, xs+%SecondColumnOffset% yp-3 w200 h21 vSDListViewBkColorProgress c%ListViewBackgroundColor% BackgroundBlack Disabled, 100
    Gui, Add, Text, xs yp wp hp cYellow BackgroundTrans +TabStop Center 0x200 vSDListViewBkColorProgressText gSDListViewBkColorChangeBtnHandler
    ; -----------------------------------------------------------------------------

    ColumnOffset := 123
    ; -----------------------------------------------------------------------------
    Gui, Add, GroupBox, xm Section vGeneralGroupBox W%SDGroupWidth% H108 cBlue, General
    ; -----------------------------------------------------------------------------
    Gui, Add, Checkbox, xs+5 ys+20 vSDPromptTerminateAllCheckBox gSDPromptTerminateAllCheckBoxHandler Checked%PromptTerminateAll%, &PromptTerminateAll
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 , Window &Transparency
    Gui, Add, Edit, xs+%ColumnOffset% yp-4 w48
    Gui, Add, UpDown, vSDWindowTransparencyUpDown gSDWindowTransparencyUpDownHandler Range100-255, %WindowTransparency%
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 , Window &Width (`%)
    Gui, Add, Edit, xs+%ColumnOffset% yp-4 w48
    Gui, Add, UpDown, vSDWindowWidthPercentageUpDown gSDWindowWidthPercentageUpDownHandler Range40-90, %WindowWidthPercentage%
    ; -----------------------------------------------------------------------------
    Gui, Add, Text, xs+5 y+6 , Window &Height Max (`%)
    Gui, Add, Edit, xs+%ColumnOffset% yp-4 w48
    Gui, Add, UpDown, vSDWindowHeightMaxPercentageUpDown gSDWindowHeightMaxPercentageUpDownHandler Range10-90, %WindowHeightMaxPercentage%
    ; -----------------------------------------------------------------------------
    
    Gui, Add, Button, xm  w60 vSDOkBtn gOkBtnHandler hwndhSDOkBtn +Default, &OK
    Gui, Add, Button, x+3 w60 vSDApplyBtn gSDApplyBtnHandler -Default Disabled, &Apply
    Gui, Add, Button, x+3 w60 vSDCancelBtn gSDCancelBtnHandler hwndhSDCancelBtn -Default Disabled, Cance&l
    Gui, Add, Button, x+3 w60 vSDResetBtn gResetBtnHandler, &Reset...
    
    Gui, Show, AutoSize Center
    Return
    

; -----------------------------------------------------------------------------
; SettingsDialog GuiSize
; -----------------------------------------------------------------------------
SettingsDialogGuiSize:
    PrintSub("SettingsDialogGuiSize")
    PrintKV2("A_GuiWidth", A_GuiWidth, "A_GuiHeight", A_GuiHeight)
    WinGetPos, X, Y, Width, Height, A
    MoveControlsToHorizontalCenter("SDOkBtn|SDApplyBtn|SDCancelBtn|SDResetBtn", A_GuiWidth)
    ;~ AutoXYWH("w", "StorageEdit")
    GuiControl, Move, GeneralGroupBox, w531
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
    ;~ Gui, Submit, NoHide
    ;~ PrintKV("SDSearchStringFontNameDDL", SDSearchStringFontNameDDL)
    ;~ PrintKV("SDSearchStringFontSizeUpDown", SDSearchStringFontSizeUpDown)
    ;~ PrintKV("SDSearchStringFontStyleDDL", SDSearchStringFontStyleDDL)
    
    ;~ PrintKV("SDListViewFontNameDDL", SDListViewFontNameDDL)
    ;~ PrintKV("SDListViewFontSizeUpDown", SDListViewFontSizeUpDown)
    ;~ PrintKV("SDListViewFontStyleDDL", SDListViewFontStyleDDL)
    
    ;~ PrintKV("SDPromptTerminateAllCheckBox", SDPromptTerminateAllCheckBox)
    ;~ PrintKV("SDWindowTransparencyUpDown", SDWindowTransparencyUpDown)
    ;~ PrintKV("SDWindowWidthPercentageUpDown", SDWindowWidthPercentageUpDown)
    ;~ PrintKV("SDWindowHeightMaxPercentageUpDown", SDWindowHeightMaxPercentageUpDown)
    
    GuiControlGet, SearchStringFontName, , SDSearchStringFontNameDDL
    GuiControlGet, SearchStringFontSize, , SDSearchStringFontSizeUpDown
    SearchStringFontColor := tSDSearchStringFontColor
    GuiControlGet, SearchStringFontStyle, , SDSearchStringFontStyleDDL

    GuiControlGet, ListViewFontName, , SDListViewFontNameDDL
    GuiControlGet, ListViewFontSize, , SDListViewFontSizeUpDown
    ListViewFontColor := tSDListViewFontColor
    GuiControlGet, ListViewFontStyle, , SDListViewFontStyleDDL
    ListViewBackgroundColor := tSDListViewBackgroundColor
    
    GuiControlGet, PromptTerminateAll, , SDPromptTerminateAllCheckBox
    GuiControlGet, WindowTransparency, , SDWindowTransparencyUpDown
    GuiControlGet, WindowWidthPercentage, , SDWindowWidthPercentageUpDown
    GuiControlGet, WindowHeightMaxPercentage, , SDWindowHeightMaxPercentageUpDown
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

} ; ShowSettingsDialog ends here!


CheckSettingsModified() {
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
        or tSDPromptTerminateAll          != PromptTerminateAll
        or tSDWindowTransparency          != WindowTransparency
        or tSDWindowWidthPercentage       != WindowWidthPercentage
        or tSDWindowHeightMaxPercentage   != WindowHeightMaxPercentage)
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
        or tSDPromptTerminateAll          != PromptTerminateAll
        or tSDWindowTransparency          != WindowTransparency
        or tSDWindowWidthPercentage       != WindowWidthPercentage
        or tSDWindowHeightMaxPercentage   != WindowHeightMaxPercentage)
    PrintKV("SettingsModified", SettingsModified)
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
; Note: Do NOT edit manually if you are not familiar with settings.
; Color Format is RGB(0xAA, 0xBB, 0xCC) => 0xAABBCC, in hex format.
;   0xAA : Red component
;   0xBB : Green component
;   0xCC : Blue component
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
[General]
PromptTerminateAll=%PromptTerminateAllDefault%
WindowTransparency=%WindowTransparencyDefault%
WindowWidthPercentage=%WindowWidthPercentageDefault%
WindowHeightMaxPercentage=%WindowHeightMaxPercentageDefault%
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

    if ReadOrWrite = Read
    {
        ReadVariable("SearchStringFontName",    	SettingsINIFilePath, "SearchString", "FontName",                  SearchStringFontNameDefault)
        ReadVariable("SearchStringFontSize",    	SettingsINIFilePath, "SearchString", "FontSize",                  SearchStringFontSizeDefault)
        ReadVariable("SearchStringFontColor",   	SettingsINIFilePath, "SearchString", "FontColor",                 SearchStringFontColorDefault)
        ReadVariable("SearchStringFontStyle",   	SettingsINIFilePath, "SearchString", "FontStyle",                 SearchStringFontStyleDefault)
        ReadVariable("ListViewFontName",        	SettingsINIFilePath, "ListView",     "FontName",                  ListViewFontNameDefault)
        ReadVariable("ListViewFontSize",        	SettingsINIFilePath, "ListView",     "FontSize",                  ListViewFontSizeDefault)
        ReadVariable("ListViewFontColor",       	SettingsINIFilePath, "ListView",     "FontColor",                 ListViewFontColorDefault)
        ReadVariable("ListViewFontStyle",       	SettingsINIFilePath, "ListView",     "FontStyle",                 ListViewFontStyleDefault)
        ReadVariable("ListViewBackgroundColor", 	SettingsINIFilePath, "ListView",     "BackgroundColor",           ListViewBackgroundColorDefault)
        ReadVariable("PromptTerminateAll",      	SettingsINIFilePath, "General",      "PromptTerminateAll",        PromptTerminateAllDefault)
        ReadVariable("WindowTransparency",      	SettingsINIFilePath, "General",      "WindowTransparency",        WindowTransparencyDefault)
        ReadVariable("WindowWidthPercentage",   	SettingsINIFilePath, "General",      "WindowWidthPercentage",     WindowWidthPercentageDefault)
        ReadVariable("WindowHeightMaxPercentage",   SettingsINIFilePath, "General",      "WindowHeightMaxPercentage", WindowHeightMaxPercentageDefault)
    }
    else
    {
        WriteVariable(SearchStringFontName,         SettingsINIFilePath, "SearchString", "FontName",                  SearchStringFontNameDefault)
        WriteVariable(SearchStringFontSize,         SettingsINIFilePath, "SearchString", "FontSize",                  SearchStringFontSizeDefault)
        WriteVariable(SearchStringFontColor,        SettingsINIFilePath, "SearchString", "FontColor",                 SearchStringFontColorDefault)
        WriteVariable(SearchStringFontStyle,        SettingsINIFilePath, "SearchString", "FontStyle",                 SearchStringFontStyleDefault)
        WriteVariable(ListViewFontName,             SettingsINIFilePath, "ListView",     "FontName",                  ListViewFontNameDefault)
        WriteVariable(ListViewFontSize,             SettingsINIFilePath, "ListView",     "FontSize",                  ListViewFontSizeDefault)
        WriteVariable(ListViewFontColor,            SettingsINIFilePath, "ListView",     "FontColor",                 ListViewFontColorDefault)
        WriteVariable(ListViewFontStyle,            SettingsINIFilePath, "ListView",     "FontStyle",                 ListViewFontStyleDefault)
        WriteVariable(ListViewBackgroundColor,      SettingsINIFilePath, "ListView",     "BackgroundColor",           ListViewBackgroundColorDefault)
        WriteVariable(PromptTerminateAll,           SettingsINIFilePath, "General",      "PromptTerminateAll",        PromptTerminateAllDefault)
        WriteVariable(WindowTransparency,           SettingsINIFilePath, "General",      "WindowTransparency",        WindowTransparencyDefault)
        WriteVariable(WindowWidthPercentage,        SettingsINIFilePath, "General",      "WindowWidthPercentage",     WindowWidthPercentageDefault)
        WriteVariable(WindowHeightMaxPercentage,    SettingsINIFilePath, "General",      "WindowHeightMaxPercentage", WindowHeightMaxPercentageDefault)
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
    PrintKV("PromptTerminateAll", PromptTerminateAll)
    PrintKV("WindowTransparency", WindowTransparency)
    PrintKV("WindowWidthPercentage", WindowWidthPercentage)
    PrintKV("WindowHeightMaxPercentage", WindowHeightMaxPercentage)
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
    PrintKV("PromptTerminateAllDefault", PromptTerminateAllDefault)
    PrintKV("WindowTransparencyDefault", WindowTransparencyDefault)
    PrintKV("WindowWidthPercentageDefault", WindowWidthPercentageDefault)
    PrintKV("WindowHeightMaxPercentageDefault", WindowHeightMaxPercentageDefault)
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
    tSDSearchStringFontName        := SearchStringFontName
    tSDSearchStringFontSize        := SearchStringFontSize
    tSDSearchStringFontColor       := SearchStringFontColor
    tSDSearchStringFontStyle       := SearchStringFontStyle
    tSDListViewFontName            := ListViewFontName
    tSDListViewFontSize            := ListViewFontSize
    tSDListViewFontColor           := ListViewFontColor
    tSDListViewFontStyle           := ListViewFontStyle
    tSDListViewBackgroundColor     := ListViewBackgroundColor	
    tSDPromptTerminateAll          := PromptTerminateAll
    tSDWindowTransparency          := WindowTransparency
    tSDWindowWidthPercentage       := WindowWidthPercentage
    tSDWindowHeightMaxPercentage   := WindowHeightMaxPercentage
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
    PromptTerminateAllDefault           := 1
    WindowTransparencyDefault           := 222
    WindowWidthPercentageDefault        := 45
    WindowHeightMaxPercentageDefault    := 50
}


#Include %A_ScriptDir%\Fnt.ahk
