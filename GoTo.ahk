/*
#####################
GoTo v1.0
Avi Aryan
#####################

Go To functions, labels, hotkeys and hotstrings in any editor.
The only requirement is that the Editor shows file full path in Title Bar and has a Goto (Ctrl+G) option.
Examples of such editors - Notepad++, Sublime Text, PSPad, ConTEXT

Any script which shows the full path and has a goto option is vaild !!

*/

#Include CommonUtils.ahk

; Include Class_Subclass.ahk to subclass edit
#Include Class_Subclass.ahk

WM_KEYDOWN := 0x100
global GOTOS := {}

;------- CONFIGURE -------------------
GoTo_AutoExecute(1)		;1 = Gui is movable
return
#if GetActiveFile()		;If ahk window is active
	!M::Goto_Main_Gui()
#if
;-------------------------------------



GoTo_AutoExecute(resizable=true){
global

	GOTOS := {}
	GOTOS.filelist := {}
	SetBatchLines, -1
	SetTimer, filecheck, 200
	goto_cache := {}
	if resizable
		OnMessage(0x201, "DragGotoGui") ; WM_LBUTTONDOWN
}

GoTo_Readfile(File) {
	Critical, On

	static filecount , commentneedle := A_space ";|" A_tab	";"
	
	if ( filecount_N := fileiscached(File) )
		Filename := filecount_N
	else
	{
		Filename := filecount := filecount ? filecount+1 : 1
		GOTOS.filelist.Insert(file)
	}
	GOTOS[Filename] := {}

	loop, read, %file%
	{
		readline := Trim( A_LoopReadLine )
		if block_comments
			if Instr(readline, "*/") = 1
			{
				block_comments := 0
				continue
			}
			else continue

		if Instr(readline, ";") = 1
			continue

		if Instr(readline, "/*") = 1
		{
			block_comments := 1
			continue
		}
		
		readline := Trim( Substr(readline, 1, SuperInstr(readline, commentneedle, 1) ? SuperInstr(readline, commentneedle, 1)-1 : Strlen(readline)) )

		if ( readline_temp := Check4Hotkey(readline) )
			CreateCache(filename, "hotkey", readline_temp, A_index)
		else if ( Instr(readline, ":") = 1 ) and ( Instr(readline, "::", 0, 0) > 1 )
			CreateCache(filename, "hotstr", Substr(readline, 1, Instr(readline, "::", 0, 0)-1), A_index )
		else if !SuperInstr(readline, "``|`t| |,", 0) and Substr(readline,0) == ":"
			CreateCache(filename, "label", readline, A_index)
		else if Check4func(readline, A_index, file)
			CreateCache(filename, "func", Substr(readline, 1, Instr(readline, "(")) ")", A_index)
	}
}

CreateCache(hostfile, type, data, linenum){
	if type = func
		if ( Substr( data, 1, SuperInstr(data, " |`t|,|(", 1)-1 ) == "while" )
			return
	;Exceptions are listed above
	if !IsObject( GOTOS[hostfile][type] )
		GOTOS[hostfile][type] := {}
	GOTOS[hostfile][type][linenum] := data 		; obj[53] := "mylabel_at53:"
}

Check4Hotkey(line) {
;The function assumes line is trimmed using Trim() and then checked for ; comment

	if ( Instr(line, "::") = 1 ) and ( Instr(line, ":", false, 0) = 3 )		;hotstring
		return ""
	hK := Substr( line, 1, ( Instr(line, ":::") ? Instr(line, ":::")+2 : ( Instr(line, "::") ? Instr(line, "::")+1 : Strlen(line)+2 ) ) - Strlen(line) - 2)
	if hK = 
		return

	if !SuperInstr(hK, " |	", 0)
		if !SuperInstr(hK, "^|!|+|#", 0) And RegExMatch(hK, "[a-z]+[,(]")
			return
		else
			return hK
	else
		if Instr(hK, " & ") or ( Substr(hK, -1) == "UP" )
			return hK
}


Check4func(readline, linenum, file){

	if RegExmatch(readline, "i)[A-Z0-9#_@\$\?\[\]]+\(.*\)") != 1
		return
	if ( Substr(readline, 0) == "{" )
		return 1

	loop,
	{
		FileReadLine, cl, %file%,% linenum+A_index
		if Errorlevel = 1
			return
		cl := Trim( Substr(cl, 1, Instr(cl, ";") ? Instr(cl, ";")-1 : Strlen(cl)) )
		if cl = 
			continue

		if block_comments
			if Instr(readline, "*/") = 1
			{
				block_comments := 0
				continue
			}
			else continue
		
		if Instr(readline, "/*") = 1
		{
			block_comments := 1
			continue
		}

		return Instr(cl, "{") = 1 ? 1 : 0
	}
}

filecheck:
	FileGetTime, Timeforfile,% goto_tempfile := GetActiveFile(), M
	if ( goto_cache[goto_tempfile] != Timeforfile )
		goto_cache[goto_tempfile] := Timeforfile , Goto_Readfile(goto_tempfile)
	return

fileiscached(file){
	for k,v in GOTOS.filelist
		if ( file == v )
			return k
}

;-------------------------------------- GUI --------------------------------------------------------------

Goto_Main_GUI()
{
	global
	static IsGuicreated , Activefile_old
	Activefile_old := ""
	
	
	Activefileindex := fileiscached( GetActiveFile() )
	
	if ( Activefile_old != Activefileindex )
	{
		Guicontrol, Goto:, Mainlist,% "|"
		Guicontrol, Goto:Choose, maintab, 1
		Guicontrol, Goto:, goTosearch
		GuiControl, Goto:Focus, goTosearch 	; important
		Update_GUI(blank, activefileindex)
	}
	
	if !IsGuicreated
	{
		Gui, Goto:New
		Gui, +AlwaysOnTop -Caption +ToolWindow
		Gui, Margin, 0, 0
		Gui, Font, s11, Consolas
		Gui, Add, Tab2, xm w380 h30 vmaintab gtabclick AltSubmit Buttons, &All|&Labels|&Functions|&Hotkeys|&Hotstrings
		Gui, Tab
		Gui, Font, s10, Lucida Console
		Gui, Add, Edit, xm y+-1 vgoTosearch hwndhGoTosearch ggoTosearch w380
		Gui, Add, ListBox, xm r15 vMainList hwndhMyListBox gDDLclick w380
		;~ Gui, Add, ListView, xm wp hp vMyListView gMyListViewEvent HwndhMyListView -HScroll, FuncList
		Update_GUI(blank, activefileindex)
		IsGuicreated := 1
	}
	if !WinExist("GoTo ahk_class AutoHotkeyGUI")
	{
		Gui, Goto:Show, AutoSize, GoTo
		GuiControl, Focus, goTosearch
		
		; HANDLE WM_KEYDOWN EVENT TO SELECT THE ITEMS OF LISTBOX USING UP / DOWN KEYS FROM
		; FILENAME EDIT CONTROL
		OnMessage(WM_KEYDOWN, "OnKeyDown")
		
		; SUBCLASS FILENAME EDIT CONTROL TO DISABLE THE UP/DOWN KEY EVENTS
		Subclass.SetFunction(hGoTosearch, WM_KEYDOWN, "Filename_WM_KEYDOWN")
	}
	else
		Gui, Goto:Hide
	Activefile_old := Activefileindex
	return

DDLclick:
	;~ Gui, Goto:submit, nohide
	;~ GoToMacro(ActivefileIndex, Typefromtab(Maintab), Mainlist)
	return

goTosearch:
tabClick:
	Gui, Goto:submit, nohide
	Update_GUI(Typefromtab(maintab), Activefileindex, Trim(goTosearch))
	return

GotoGUIEscape:
	Gui, Goto:Hide
	return
	
MyListViewEvent:
	Gui, Goto:submit, nohide
	GoToMacro(ActivefileIndex, Typefromtab(Maintab), Mainlist)
Return

}

Update_GUI(mode, fileindex, find="") {
	if !fileindex
		return
	if mode=
		loop 4
			for k,v in GOTOS[fileindex][Typefromtab(A_Index+1)]
			{
				;~ PrintKV2("k", k, "v", v)
				LV_Add("", v)
				MainList .= Instr( v, find ) ? "|" v : ""
			}
	else
		for k,v in GOTOS[fileIndex][mode]
		{
			;~ PrintKV2("k", k, "v", v)
			MainList .= Instr( v, find ) ? "|" v : ""
			LV_Add("", v)
		}
	Guicontrol, Goto:, Mainlist,% !MainList ? "|" : Mainlist
	GuiControl, Goto: Choose, MainList, |1
	;~ LV_Add("", MainList)
}

GoToMacro(Fileindex, type, tojump){
	BlockInput, On
	Gui, Goto:Hide
	loop 4
		for k,v in GOTOS[fileindex][Typefromtab(A_Index+1)]
			if ( v == tojump )
			{
				runline := k
				break
			}
	SendInput, ^g
	sleep, 100
	SendInput,% runline "{Enter}"
	BlockInput, Off
}

;---------------------------------------------------------------------------------------------------------

GetActiveFile(){
	WinGetActiveTitle, Title
	;~ FileAppend, Title = [%Title%]`n, *
	if ( Instr(title, ".ahk") and !Instr(title, ":\") ) {
		ret := A_ScriptDir . "\" . Trim(SubStr(title, 1, Instr(Title, ".ahk", 0, 0) + 4))
		;~ FileAppend, ret = [%ret%]`n, *
		return ret
	}
	if !( Instr(title, ".ahk") and Instr(title, ":\") )
		return ""
	return Trim( Substr( Title, temp := Instr(Title, ":\")-1, Instr(Title, ".ahk", 0, 0)-temp+4 ) ) 
}

TypefromTab(TabCount){
	if Tabcount = 1
		return ""
	else if Tabcount = 2
		return "label"
	else if Tabcount = 3
		return "func"
	else if Tabcount = 4
		return "hotkey"
	else if Tabcount = 5
		return "hotstr"
}

DragGotoGui(){		;Thanks Pulover
	PostMessage, 0xA1, 2,,, A
}

;Helper Function(s) --------------------------------------------------------------------------------------
/*
SuperInstr()
	Returns min/max position for a | separated values of Needle(s)
	
	return_min = true  ; return minimum position
	return_min = false ; return maximum position

*/

SuperInstr(Hay, Needles, return_min=true, Case=false, Startpoint=1, Occurrence=1) {
	
	pos := return_min*Strlen(Hay)
	if return_min
	{
		loop, parse, Needles,|
			if ( pos > (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) )
				pos := var ? var : pos
		if ( pos == Strlen(Hay) )
			return 0
	}
	else
	{
		loop, parse, Needles,|
			if ( (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) > pos )
				pos := var
	}
	return pos
}

;=== BEGIN OnKeyDown SUBROUTINE =================================

; Handle Up/Down when the are pressed in Filename Edit Control
; Select the ListBox items or move the selection to up/down when
;  Up/Down keys are pressed.
OnKeyDown(wParam, lParam, msg, hwnd) {
	global hGoTosearch, hMyListView, hMyListBox
	Global ActivefileIndex, Maintab, Mainlist
	key := Format("vk{1:x}", wParam)
	keyName := GetKeyName(key)
	FileAppend, [OnKeyDown] wParam = [%wParam% %keyName%] lParam = [%lParam%] msg = [%msg%] hwnd = [%hwnd%]`n, *

	PrintKV("hwnd", Format("{:x}", hwnd))
	PrintKV("hGoTosearch", hGoTosearch)
	PrintKV("hMyListView", hMyListView)
	PrintKV("hMyListBox", hMyListBox)
	if (hwnd = hGoTosearch) {
		;~ FileAppend, [OnKeyDown] hwnd = hGoTosearch`n, *
		if (wParam = GetKeyVK("Down")) {
			ControlSend, ListBox1, {Down}
		}
		else if (wParam = GetKeyVK("Up")) {
			ControlSend, ListBox1, {Up}
		}
		else if (wParam = GetKeyVK("Enter")) {
			Print("Enter pressed!")
			Gui, Goto:submit, nohide
			GoToMacro(ActivefileIndex, Typefromtab(Maintab), Mainlist)
		}
	}
	else if (hwnd = hMyListBox) {
		if (wParam = GetKeyVK("Enter")) {
			Print("Enter pressed!")
			Gui, Goto:submit, nohide
			GoToMacro(ActivefileIndex, Typefromtab(Maintab), Mainlist)
		}
	}
}

;... END OnKeyDown SUBROUTINE ...................................


;=== BEGIN Filename_WM_KEYDOWN SUBROUTINE =================================

; Disable the Up/Down keys on Filename Edit Control. And handle these keys
;  in OnKeyDown callback function to select the ListBox items and move the
;  selection to up/down when Up/Down keys are pressed.
Filename_WM_KEYDOWN(Hwnd, Message, wParam, lParam) {
	key := Format("vk{1:x}", wParam)
	keyName := GetKeyName(key)
	FileAppend, [Filename_WM_KEYDOWN] wParam = [%wParam% %keyName%] lParam = [%lParam%] msg = [%Message%] hwnd = [%hwnd%]`n, *
	if (wParam = GetKeyVK("Down") or wParam = GetKeyVK("Up")) {
		return False	; Prevent default message processing
	}
	else if (wParam = GetKeyVK("Enter")) {
		Print("Enter pressed!")
		Gui, Goto:submit, nohide
		GoToMacro(ActivefileIndex, Typefromtab(Maintab), Mainlist)
	}
	return True
}

;... END Filename_WM_KEYDOWN SUBROUTINE ...................................
