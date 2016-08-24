; ======================================================================================================================
; AHK 1.1 +
; ======================================================================================================================
; Function:         Helper object for subclassing controls
; AHK version:      1.1.02.03 (U32)
; Language:         English
; Tested on:        Win XPSP3, Win VistaSP2 (32 Bit)
; Version:          0.0.01.00/2011-08-22/just me
; Remarks:          To subclass a control and set a function to be called on certain messages call
;                      Subclass.SetFunction()
;                   passing three parameters:
;                      Hwnd      - HWND of the GUI control                                   (Integer)
;                      Message   - Message number                                            (Integer)
;                                  Pass an asterisk (*) for all messages                     (String)
;                      Function  - Name of the function that handles the message             (String)
;
;                   To reset subclass calls for a certain function call
;                      Subclass.RemoveFunction()
;                   passing two parameters:
;                      Hwnd      - see above
;                      Message   - see above
;
;                   To get a control's HWND use either the option "HwndOutputVar" with "Gui, Add" or the command 
;                   "GuiControlGet" with sub-command "Hwnd".
;
;                   There are several ways to get the message numbers. One suitable is to install "AutoIt3" from
;                   www.autoitscript.com. In the installation folder you'll find a subfolder "Include" 
;                   containing a couple of scripts which names are ending with "Constants". These contain definitions
;                   for a lot of windwows constants including the messages.
;
;                   The function to be called for the incoming message has to accept exactly four parameters:
;                      Hwnd      - Hwnd passed to _Subclass_Callback
;                      Message   - message number passed to _Subclass_Callback
;                      wParam    - wParam passed to _Subclass_Callback
;                      lParam    - lParam passed to _Subclass_Callback
;                   If the function does not use Return or returns an empty string, the message default processing
;                   will be done. Otherwise the return value will be passed to the system.
;
;                   Names of "private" properties/methods/functions are prefixed with underscores, they must not be
;                   set/called by the script!
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================

Class Subclass {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE Properties and Methods ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   Static _Subclassed := {}
   Static _SubclassProc := ""
   
   ; ===================================================================================================================
   ; This class is only a helper object, you must not instantiate it.
   ; ===================================================================================================================   
   __New() {
      Return False
   }
   
   ; ===================================================================================================================
   ; PRIVATE METHOD _GetFunction
   ; ===================================================================================================================   
   _GetFunction(Hwnd, Message) {
      Hwnd += 0
      If This._Subclassed.HasKey(Hwnd) {
         For I, O In This._Subclassed[Hwnd] {
            If (O.Message = Message) || (O.Message = "*")
               Return O.Function
      }  }
      Return False
   }
   
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC Interface ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; METHOD SetFunction    Start subclassing
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       Message     - message number                                            (Integer/String)
   ;                       Function    - name of the function to be called                         (String)
   ; Return values:        On success  - True
   ;                       On failure  - False
   ; ===================================================================================================================
   SetFunction(Hwnd, Message, Function) {
      If (This._SubclassProc = "") {
         If !(This._SubclassProc := RegisterCallback("_Subclass_Callback"))
            Return False
      }
      If !IsFunc(Function)
      Or (Func(Function).MaxParams <> 4)
      Or !DllCall("User32.dll\IsWindow", "UPtr", Hwnd)
         Return False
      K := Hwnd + 0
      If !This._Subclassed.HasKey(K) {
         This._Subclassed[K] := []
      } Else {
         For I, O In This._Subclassed[K] {
            If (O.Message = Message) {
               O.Function := Func(Function)
               Return True
      }  }  }
      If !This._Subclassed[K].MaxIndex() {
         If !DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", Hwnd, "Ptr", This._SubclassProc, "Ptr", Hwnd, "Ptr", 0)
            Return False
      }
      O := {Message: Message, Function: Func(Function)}
      This._Subclassed[K].Insert(O)
      Return True
   }
   
   ; ===================================================================================================================
   ; METHOD RemoveFunction Remove subclass calls for a certain function
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       Message     - message number                                            (Integer/String)
   ; Return values:        On success  - True
   ;                       On failure  - False
   ; ===================================================================================================================
   RemoveFunction(Hwnd, Message) {
      K := Hwnd + 0
      M := False
      If This._Subclassed.HasKey(K) {
         For I, O In This._Subclassed[K] {
            If (O.Message = Message) {
               M := I
               Break
         }  }
         If !(M)
            Return False
         This._Subclassed[K].Remove(M)
         If !This._Subclassed[K].MaxIndex() {
            This._Subclassed.Remove(K, "")
            DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", Hwnd, "Ptr", This._SubclassProc, "Ptr", Hwnd)
         }
         Return True   
      }
      Return False
   }
}

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; PRIVATE Functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_Subclass_Callback(Hwnd, Message, wParam, lParam, IdSubclass, RefData) {
   Global Subclass
   Critical
   Function := Subclass._GetFunction(Hwnd, Message)
   If IsObject(Function)
      If (!(RetVal := Function.(Hwnd, Message, wParam, lParam)))
         Return RetVal
   Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", Hwnd, "UInt", Message, "Ptr", wParam, "Ptr", lParam)
}

