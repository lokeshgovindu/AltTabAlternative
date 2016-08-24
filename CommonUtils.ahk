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

PrintSub(name) {
	Print("[Sub] --- " . name . " ---")
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
