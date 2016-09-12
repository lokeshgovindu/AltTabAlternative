/*
 * This is Lokesh Govindu's AutoHotkey script
 */

#SingleInstance Force
SetTitleMatchMode RegEx

; Using #Include to Share Functions Among Multiple

PrintLine() {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] -------------------------------------------------------------------------------`n, *
}

Print(a) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %a%`n, *
}

Print1(a) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %a%`n, *
}

Print2(a, b) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %a%`, %b%`n, *
}

Print3(a, b, c) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %a%`, %b%`, %c%`n, *
}

Print4(a, b, c, d) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %a%`, %b%`, %c%`, %d%`n, *
}

PrintKV(strA, valA) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %strA% = [%valA%]`n, *
}

PrintKV1(strA, valA) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %strA% = [%valA%]`n, *
}

PrintKV2(strA, valA, strB, valB) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %strA% = [%valA%]`, %strB% = [%valB%]`n, *
}

PrintKV3(strA, valA, strB, valB, strC, valC) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %strA% = [%valA%]`, %strB% = [%valB%]`, %strC% = [%valC%]`n, *
}

PrintKV4(strA, valA, strB, valB, strC, valC, strD, valD) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	FileAppend, [%CurrentTime%] %strA% = [%valA%]`, %strB% = [%valB%]`, %strC% = [%valC%]`, %strD% = [%valD%]`n, *
}

PrintListKV(str, lst) {
    Local len
    len := lst.Length()
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
    FileAppend, [%CurrentTime%] %str% = (%len%)[, *
    Loop, % (len - 1)
    {
        FileAppend, % lst[A_Index] . "`, " , *
    }
    FileAppend, % lst[len], *
    FileAppend, ]`n, *
}

GetDictLength(dict) {
    Local ret = 0
    for key, val in dict
        ++ret
    return ret    
}

PrintDictKV(str, dict) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
    FileAppend, [%CurrentTime%] %str% = {, *
    for key, val in dict {
        kv := Format("({}, {}), ", key, val)
        FileAppend, % kv, *
   }
    FileAppend, }`n, *
}

PrintWindowsInfoList(str, dict) {
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
    FileAppend, [%CurrentTime%] %str% = {, *
    for key, val in dict {
        kv := Format("(0x{:x}, {}), ", key, val)
        FileAppend, % kv, *
   }
    FileAppend, }`n, *
}

PrintLabel() {
	PrintSub(A_ThisLabel)
}

PrintSub(name) {
	Print("[Sub] --- " . name . " ---")
}

PrintFunc(name) {
	Print("[Fun] --- " . name . " ---")
}

;------------------------------------------------------------------------------
; This funciton returns the JAVA_HOME directory path.
;------------------------------------------------------------------------------
JavaHomeGet() {
    ; 1. Search in registry
    ; 2. If not found, look for JAVA_HOME Environment Variable
    ; 3. If not defined, search in ProgramFiles
    ; 4. If still not found, use default "C:\Program Files (x86)\Java\jdk1.8.0_45"
    RegRead, JavaHome, HKEY_LOCAL_MACHINE, SOFTWARE\JavaSoft\Java Development Kit\1.8, JavaHome
    if (JavaHome = "") {
        EnvGet JavaHome, JAVA_HOME
        if (JavaHome = "") {
            jdkPattern = %A_ProgramFiles%\Java\jdk1.8.*
            Loop, Files, %jdkPattern%, D
                JavaHome = %A_LoopFileFullPath%

            if (JavaHome = "" and A_Is64bitOS = 1) {
                EnvGet, PF_x86, ProgramFiles(x86)
                jdkPattern = %PF_x86%\Java\jdk1.8.*
                Loop, Files, %jdkPattern%, D
                    JavaHome = %A_LoopFileFullPath%
            }
            
            if (JavaHome = "") {
                JavaHome = C:\Program Files (x86)\Java\jdk1.8.0_45
            }
        }
    }
    return JavaHome
}



MouseIsOver(WinTitle) {
 MouseGetPos,,, Win
 return WinExist(WinTitle . " ahk_id " . Win)
}


;------------------------------------------------------------------------------
; Disables or enables the user's ability to interact with the computer via
;   keyboard and mouse.
; However, pressing Ctrl + Alt + Del will re-enable input due to a Windows
;   API feature.
;------------------------------------------------------------------------------
class CBlockInput {
	__New() {
		BlockInput, On
	}

	__Delete() {
		BlockInput, Off
	}
}


;------------------------------------------------------------------------------
; Returns true if the filePath is a directory otherwise false
;------------------------------------------------------------------------------
IsDirectory(filePath) {
	FileGetAttrib, fileAttrib, %filePath%
	if (InStr(fileAttrib, "D") <> 0) {
		return true
	}
	return false
}

;------------------------------------------------------------------------------
; Returns true if the filePath is a file otherwise false
;------------------------------------------------------------------------------
IsFile(filePath) {
	FileGetAttrib, fileAttrib, %filePath%
	if (InStr(fileAttrib, "D") = 0) {
		return true
	}
	return false
}

; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable 
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Version: 2015-5-29 / Added 'reset' option (by tmplinshi)
;          2014-7-03 / toralf
;          2014-1-2  / tmplinshi
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH(DimSize, cList*)       ; http://ahkscript.org/boards/viewtopic.php?t=1079
{
    static cInfo := {}

    If (DimSize = "reset")
        Return cInfo := { }

    For i, ctrl in cList {
        ctrlID := A_Gui ":" ctrl
        If ( cInfo[ctrlID].x = "" ) {
            GuiControlGet, i, %A_Gui%:Pos, %ctrl%
            MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
            fx := fy := fw := fh := 0
            For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
                If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
                    f%dim% := 1
            cInfo[ctrlID] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a, m:MMD }
        }Else If ( cInfo[ctrlID].a.1) {
            dgx := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
            For i, dim in cInfo[ctrlID]["a"]
            Options .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
            GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % Options
        }
    }
}
