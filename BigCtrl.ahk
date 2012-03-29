; Allows the spacebar key to mimic the Ctrl key while retaining most
; of its normal functionality. Holding down the spacebar key down acts
; like holding down the ctrl key. This allows for easier use of
; keyboard shortcuts (such as Ctrl+C for copy). If the spacebar key is
; pressed and released quickly (less than the specified timeout) and
; no other key was pressed then a normal space is sent.
;
; Author:         Ben Hansen <benhansenslc@gmail.com> 


#SingleInstance force
#NoEnv
SendMode Input
SetStoreCapslockMode, Off
Process, priority, , High

; The amount of milliseconds of holding the spacebar after which a
; space key is no longer returned.
g_TimeOut := 300

; The amount of milliseconds to delay returning a Ctrl key sequence
; that are potentially accidentally hit with the space bar. If the
; space bar comes up during this delay the regular keys will be
; returned instead. Probably rounds to the nearest 10 milliseconds by
; the OS.
g_Delay := 70

g_SpacePressDownTime := false
g_OtherKeyPressed := false
g_SkipNextSpace := false

allKeysStr := "LButton*RButton*MButton*WheelDown*WheelUp*WheelLeft*WheelRight*XButton1*XButton2*Tab*Enter*Escape*Backspace*Delete*Insert*Home*End*PgUp*PgDn*Up*Down*Left*Right*ScrollLock*CapsLock*NumLock*Numpad0*Numpad1*Numpad2*Numpad3*Numpad4*Numpad5*Numpad6*Numpad7*Numpad8*Numpad9*NumpadDot*NumpadDiv*NumpadMult*NumpadAdd*NumpadSub*NumpadEnter*F1*F2*F3*F4*F5*F6*F7*F8*F9*F10*F11*F12*F13*F14*F15*F16*F17*F18*F19*F20*F21*F22*F23*F24*AppsKey*Browser_Back*Browser_Forward*Browser_Refresh*Browser_Stop*Browser_Search*Browser_Favorites*Browser_Home*Volume_Mute*Volume_Down*Volume_Up*Media_Next*Media_Prev*Media_Stop*Media_Play_Pause*Launch_Mail*Launch_Media*Launch_App1*Launch_App2*Help*Sleep*PrintScreen*CtrlBreak*Pause*Break"
StringSplit, allKeysArray, allKeysStr, *
Loop %allKeysArray0%
{
  key := allKeysArray%A_Index%
  Hotkey, % "~*"key, ListenForKey
}

; Keys that are possible to accidentally press with the space key
; while typing fast.
keysToDelayStr := "1*2*3*4*5*6*7*8*9*0*q*w*e*r*t*y*u*i*o*p*[*]*\*a*s*d*f*g*h*j*k*l*;*'*z*x*c*v*b*n*m*,*.*/"
StringSplit, keysToDelayArray, keysToDelayStr, *
Loop %keysToDelayArray0%
{
  key := keysToDelayArray%A_Index% 
  Hotkey, % "*"key, DelayKeyOutput
}

; This is necessary to prevent wierd bugs from occuring with the other
; modifier keys.
modifiersStr := "LWin*RWin*LAlt*RAlt*LShift*RShift"
StringSplit, modifiersArray, ModifiersStr, *
Loop %modifiersArray0%
{
  key := modifiersArray%A_Index% 
  Hotkey, % "*"key, ModifierDown
  Hotkey, % "*"key " up", ModifierUp
}

ListenForKey:
  g_OtherKeyPressed := true
  Return
  
DelayKeyOutput:
  Critical
  pressedKey := SubStr(A_ThisHotkey,0)
  modifiers := GetModifiers()
  ; Only wait to see if the space comes up if 1) the space bar key is
  ; down in the first place and 2) it has been held down for less than
  ; the timeout and 3) another Ctrl key combo hasn't already been
  ; pressed.
  if((g_SpacePressDownTime != false) 
    && (GetSpaceBarHoldTime() < g_TimeOut) && !g_OtherKeyPressed)
  {
    ; Do the sleeping of timeout in small increments, that way if the
    ; the space key is released in the middle we can quit early.
    wait_start_time := A_TickCount
    while A_TickCount - wait_start_time + 10 < g_Delay
    {
      Sleep, 10
      if(!getKeyState("Space", "P"))
      {
	; Since space bar was released, remove the Ctrl modifier.
	StringReplace, modifiers, modifiers, ^,
        ; Force space to fire, because its being released could not
        ; fire during this routine because this thread is critical.
	Gosub *Space up
        ; Stop the space in the event queue from firing since we
        ; have already fired it manually.
	g_SkipNextSpace := True 
        Break
      }
    }
  }
  SendInput % modifiers pressedKey
  g_OtherKeyPressed := true
  Return
  
  
ModifierDown:
  pressedKey := SubStr(A_ThisHotkey,2) ; Get all put starting '*'
  SendInput {%pressedKey% down}
  Return
  
ModifierUp:
  pressedKey := SubStr(A_ThisHotkey,2) ; Get all put starting '*'
  SendInput {%pressedKey%}
  Return

*Space::
  Critical
  ; Don't update on OS simulated repeats but only when the user
  ; actually pressed the key down for the first time
  if(g_SpacePressDownTime == false)
  {
    g_SpacePressDownTime := A_TickCount
    g_OtherKeyPressed := false
  }
  SendInput {RCtrl down}
  Return
  
*Space up::
  Critical
  if(g_SkipNextSpace)
  {
    g_SkipNextSpace := false
  }
  SendInput {RCtrl up}
  if(g_OtherKeyPressed == true)
  {
    g_SpacePressDownTime := false
    Return
  }
  if (GetSpaceBarHoldTime() <= g_TimeOut)
  {
    modifiers := GetModifiers()
    SendInput % modifiers "{Space}"
  }
  g_SpacePressDownTime := false
  Return
  
GetSpaceBarHoldTime()
{
  global g_SpacePressDownTime
  time_elapsed := A_TickCount - g_SpacePressDownTime
  Return time_elapsed
}
  
; Return the hotkey symbols (ie !, #, ^ and +) for the modifiers that
; are currently activated
GetModifiers()
{
  Modifiers =
  GetKeyState, state1, LWin
  GetKeyState, state2, RWin
  state = %state1%%state2%
  if state <> UU  ; At least one Windows key is down.
    Modifiers = %Modifiers%# 
  GetKeyState, state1, Alt
  if state1 = D
    Modifiers = %Modifiers%!
  GetKeyState, state1, Control
  if state1 = D
    Modifiers = %Modifiers%^
  GetKeyState, state1, Alt
  GetKeyState, state1, Shift
  if state1 = D
    Modifiers = %Modifiers%+
  Return Modifiers
}
