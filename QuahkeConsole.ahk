;;; QuahkeConsole.ahk --- Open a Quake-like terminal (tilda, guake or yakuake)
;;;                       but in MS Windows

;; Copyright (c) 2011-2012 Claude Tete
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;

;; Author: Claude Tete  <claude.tete@gmail.com>
;; Version: 0.8
;; Created: February 2011
;; Last-Updated: November 2012

;;; Commentary:
;; Based on:
;;  Opens Console in a Quake style (at the top of the screen using F1)
;;  http://code.google.com/p/kosciak-autohotkey/source/browse/trunk/TildaConsole
;;  /TildaConsole.ahk?r=18

;;; Change Log:
;; 2012-11-14 (0.8)
;;     add smooth open/close + options in ini file
;; 2012-11-14 (0.7)
;;     add cmd.exe with cyygwin/rxvt
;; 2012-11-14 (0.6)
;;     change console2 by cygwin/rxvt to have full key compatibility
;; 2012-11-14 (0.5)
;;     change shortcut
;;     adapt escape function to return the focus on the right window
;; 20xx-xx-xx (0.4)
;;     Option for creating new tab in Console Here
;; 20xx-xx-xx (0.3)
;;     Enabled Ctrl-V por pasting
;;     Added closing #IfWinActive directives
;;     Simplified Path pasting in Ctrl-Tilda
;; 20xx-xx-xx (0.2)
;;     Ctrl+Tilda for Explorer window acts as Console Here
;; 20xx-xx-xx (0.1)
;;     Initial Release, same as http://www.instructables.com/id/%22Drop-
;;                              Down%22%2c-Quake-style-command-prompt-
;;                              for-Window/


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ENVIRONMENT
;; {
;;   Recommended for performance and compatibility with future AutoHotkey.
#NoEnv

;;   Recommended for new scripts due to its superior speed and reliability.
SendMode Input

;;   Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

;;   only on instance of this script
#SingleInstance force

;;  start enable
Disabled = 0

;;  Title of the window
TerminalTitle = QuahkeConsole

;; } /* ENVIRONMENT */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
;;
;;; SETTING
;; position in X to hide window decoration (screen left = 0)
IniRead, PosX, QuahkeConsole.ini, Position, PosX, -4
;; position in Y to hide window decoration (screen top = 0)
IniRead, PosY, QuahkeConsole.ini, Position, PosY, -23
;; offset to remove window decoration in X
IniRead, OffsetX, QuahkeConsole.ini, Position, OffsetX, 2
;; offset to remove window decoration in Y
IniRead, OffsetY, QuahkeConsole.ini, Position, OffsetY, 4
;; percent size in X for the terminal window (%)
IniRead, SizeX, QuahkeConsole.ini, Size, SizeX, 100
;; percent size in Y for the terminal window (%)
IniRead, SizeY, QuahkeConsole.ini, Size, SizeY, 20
;;
;; Transparence of terminal in percent (invisible (0) to full opaque (100))
IniRead, TerminalAlpha, QuahkeConsole.ini, Misc, TerminalAlpha, 80

;;     Character Size in X for the terminal window  in percent
IniRead, CharacterSizeX, QuahkeConsole.ini, Font, CharacterSizeX, 6
;;     Character Size in Y for the terminal window  in percent
IniRead, CharacterSizeY, QuahkeConsole.ini, Font, CharacterSizeY, 8

;;     type of terminal MS/cmd or Cygwin/rxvt
IniRead, TerminalType, QuahkeConsole.ini, Terminal, TerminalType, cmd


;;   VERSION
;;   {
       SoftwareVersion := "0.8"
;;   } /* VERSION */
;; } /* SETTING */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ICON
;; {
;;   get icon file into the exe
FileInstall, QuahkeConsole.ico, QuahkeConsole.ico, 1
;;   display icon in tray zone
Menu, TRAY, Icon, QuahkeConsole.ico
;; } /* ICON */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MENU
;; {
;;   Delete the current menu
Menu, tray, NoStandard

;;   Add the item About in the menu
Menu, tray, add, About, MenuAbout

;;   Creates a separator line.
Menu, tray, add

;;   Add the item Reload in the menu
Menu, tray, add, Reload .ini file, MenuReload

;;   Add the item Edit ini in the menu
Menu, tray, add, Edit .ini file, MenuEditIni

;;   Add the item Create/Save ini in the menu
Menu, tray, add, Create/Save .ini file, MenuCreateSaveIni

;;   Creates a separator line.
Menu, tray, add

;;   add the standard menu
Menu, tray, Standard
return

;;   handler of the item about
MenuAbout:
  Gui, 2:Add, Text, 0x1, % "QuahkeConsole`nVersion " . SoftwareVersion
  Gui, 2:Show, AutoSize, About QuahkeConsole
Return
;;   handler for the about window
2GuiClose:
2GuiEscape:
  ;; destroy the window without saving anything
  Gui, Destroy
Return

;;   handler of the item Reload .ini
MenuReload:
  Reload
Return
;; } /* MENU */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SHORTCUT
;; {
;;   Launch console if necessary; hide/show on Win+` or F1
;#`::GoSub, ShowHide
F1::GoSub, ShowHide
;#c::GoSub, ShowHide

;; deprecated
;Del::
;  IfWinExist ahk_class %TerminalTitle%
;  {
;    IfWinActive ahk_class %TerminalTitle%
;    {
;      Send ^d
;    }
;    else
;    {
;      Send {Del}
;    }
;  }
;  else
;  {
;    Send {Del}
;  }
;return
;
;;; deprecated
;Home::
;  IfWinExist ahk_class %TerminalTitle%
;  {
;    IfWinActive ahk_class %TerminalTitle%
;    {
;      Send ^a
;    }
;    else
;    {
;      Send {Home}
;    }
;  }
;  else
;  {
;    Send {Home}
;  }
;return
;
;;; deprecated
;End::
;  IfWinExist ahk_class %TerminalTitle%
;  {
;    IfWinActive ahk_class %TerminalTitle%
;    {
;      Send ^e
;    }
;    else
;    {
;      Send {End}
;    }
;  }
;  else
;  {
;    Send {End}
;  }
;return

;; move by word (right)
#IfWinActive QuahkeConsole
^Right::
  Send {Escape}f
Return

;; move by word (left)
#IfWinActive QuahkeConsole
^Left::
  Send {Escape}b
Return

;;; button backward
;XButton1::
;  IfWinExist ahk_class %TerminalTitle%
;  {
;    IfWinActive ahk_class %TerminalTitle%
;    {
;      Send cd ..{Enter}
;    }
;    else
;    {
;      Send {XButton1}
;    }
;  }
;  else
;  {
;    Send {XButton1}
;  }
;return
;; } /* SHORTCUT */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROCESSING
;; {
ShowHide:
  ;; get the title of the current window
  WinGetActiveTitle, CurrentWindowTitle

  ;; the window is not the console
  if CurrentWindowTitle != %TerminalTitle%
  {
    ;; keep the title of the previous window
    PrevActive = %CurrentWindowTitle%
  }

  ;; enable detection of hidden window
  DetectHiddenWindows, on

  ;; get the size of the current monitor (without taskbar)
  SysGet, ScreenSizeX, 61
  SysGet, ScreenSizeY, 62

  ;; if console2 has been launched
  IfWinExist %TerminalTitle%
  {
    ;; if the console2 window is active
    IfWinActive %TerminalTitle%
    {
      ;; hide the window of console2
      WinHide %TerminalTitle%

      ;; if there was a previous window
      IfWinExist %PrevActive%
      {
        ;; focus on the previous window
        WinActivate %PrevActive%
      }
      else
      {
        ;; focus is not on console
        WinActivate ahk_class Shell_TrayWnd
      }
    }
    else
    {
      ;; Display the hidden console2 window
      WinShow %TerminalTitle%
      WinMove, %TerminalTitle%, , PosX, PosY
      ;; place the window
      WinSet, Region, 0-0 w%MaskX% h%MaskY%

      ;; make active the console2 window
      WinActivate %TerminalTitle%
    }
  }
  else
  {
    ;; 1 character in "Terminal" font = 6x15
    NbCharacterX := Round((SizeX * ScreenSizeX) / (100 * CharacterSizeX), 0) - 2
    NbCharacterY := Round((SizeY * ScreenSizeY) / (100 * CharacterSizeY), 0)

    ;; set size of mask
    MaskX := Round(((SizeX * ScreenSizeX) / 100) - MaskSizeX, 0)
    ;; the window decoration take 32
    MaskY := NbCharacterY * CharacterSizeY + 32 - MaskSizeY

    if TerminalType = cmd
    {
      Run "C:\WINDOWS\system32\cmd.exe" /K title %TerminalTitle% & mode con:cols=%NbCharacterX% lines=%NbCharacterX%
    }
    else
    {
      if TerminalType = rxvt
      {
        ;; launch rxvt                                                            ;;
;;        Run "D:\cygwin\bin\rxvt.exe" -display :0 -sl 10000 -fg white -bg black -fn Terminal-8 -fb Terminal-8 -tn rxvt -title %TerminalTitle% -g %NbCharacterX%x%NbCharacterY% -e /bin/zsh --login -i
        Run "D:\cygwin\bin\rxvt.exe" -display :0 -sl 10000 -fg white -bg black -fn ProggyTinySZ-6 -fb ProggyTinySZ-6 -fm ProggyTinySZ-6 -tn rxvt -title %TerminalTitle% -g %NbCharacterX%x%NbCharacterY% -e /bin/zsh --login -i
      }
      else
      {
        MsgBox, 0x80, QuahkeConsole: error, Error: wrong TerminalType, it must be "cmd" or "rxvt"
      }
    }

    ;; wait that the terminal has been launch
    WinWait %TerminalTitle%

    ;; make the window of the terminal with alpha of 200
    ;; (full transparent = 0, full opaque = 255)
    Alpha := (TerminalAlpha * 255) / 100
    WinSet, Transparent, %Alpha%, %TerminalTitle%

    ;; set the window to be always up
    Winset, AlwaysOnTop, On, %TerminalTitle%

    ;; place the window in the up right corner
    WinMove, %TerminalTitle%, , PosX, PosY
    WinSet, Region, 0-0 w%MaskX% h%MaskY%
  }

  ;; disable detection of hidden window
  DetectHiddenWindows, off

return

; EasyGlide
; Based on Easy Window Dragging
;
;      AutoHotkey Version: 1.0.46+ (uses ?: operator)
;                Platform: XP/2k/NT
;                  Author: Paul Pliska (ManaUser)
; Performance Enhancement: Laszlo
;
; Script Function:
; Make the middle mouse button drag any window, in any internal point.
; Additionally, if you let go while dragging, the window will "glide"
; for short distance, and even bounce off the edges of the screen.
; The distance and "bouncyness" can be adjusted by changing constants.

    INERTIA = 0.97 ; 1 means Glide forever, 0 means not at all.
 BOUNCYNESS = 0.50 ; 1 means no speed is lost, 0 means don't bounce.
SENSITIVITY = 0.33 ; Higher is more responsive, lower smooths out glitchs more.
                   ; Must be greater than 0 and no higher than 1.

#SingleInstance Force
#NoEnv
SetBatchLines -1        ; Run faster
SetWinDelay -1          ; Makes the window moves faster/smoother.
CoordMode Mouse, Screen ; Switch to screen/absolute coordinates.
SpeedA := 1 - SENSITIVITY
SetTimer WorkAreaCheck, 10000   ;Just in case they move the task bar.
GoSub WorkAreaCheck      ;or change resolution.

;~*LButton::             ; Clicking a mouse button stops glide.
;~*RButton::
   ;SetTimer Glide, Off
;Return

;MButton::
 ;  SetTimer Glide, Off
 ;  MouseGetPos LastMouseX, LastMouseY, MouseWin
  ; WinGet WinState, MinMax, ahk_id %MouseWin%
   ;IfNotEqual WinState, 0 ; If the window is maximized, just to normal Middle Click
   ;{
     ;  Click Middle
    ;   Return
   ;}
  ; WinGetPos WinX, WinY, WinWidth, WinHeight, ahk_id %MouseWin%
 ;  SetTimer WatchMouse, 10       ; Track the mouse as the user drags it
;Return

WatchMouse:
   If !GetKeyState("MButton","P") {
      SetTimer WatchMouse, Off   ; MButton has been released, so drag is complete.
      SetTimer Glide, 10         ; Start gliding
      Return
   }
                                 ; Drag: Button is still pressed
   MouseGetPos MouseX, MouseY
   WinX += MouseX - LastMouseX
   WinY += MouseY - LastMouseY

   ;Enforce Boundries
   WinX := WinX < WorkAreaLeft ? WorkAreaLeft : WinX+WinWidth > WorkAreaRight ? WorkAreaRight-WinWidth : WinX
   WinY := WinY < WorkAreaTop ? WorkAreaTop : WinY+WinHeight > WorkAreaBottom ? WorkAreaBottom-WinHeight : WinY

   WinMove ahk_id %MouseWin%,, WinX, WinY
   SpeedX := SpeedX*SpeedA + (MouseX-LastMouseX)*SENSITIVITY
   SpeedY := SpeedY*SpeedA + (MouseY-LastMouseY)*SENSITIVITY
   LastMouseX := MouseX,     LastMouseY := MouseY
Return

Glide:
   SpeedX *= INERTIA
   SpeedY *= INERTIA
   If (Abs(SpeedX) < 0.2 AND Abs(SpeedY) < 0.2) {
      SetTimer Glide, Off        ; It's barely moving, bring it to a complete stop
      Return
   }

   WinX += SpeedX,   WinY += SpeedY

   If (WinX < WorkAreaLeft  OR  WinX + WinWidth > WorkAreaRight)
      SpeedX *= -BOUNCYNESS
   If (WinY < WorkAreaTop  OR  WinY + WinHeight > WorkAreaBottom)
      SpeedY *= -BOUNCYNESS
   WinX := WinX < WorkAreaLeft ? WorkAreaLeft : WinX+WinWidth > WorkAreaRight ? WorkAreaRight-WinWidth : WinX
   WinY := WinY < WorkAreaTop ? WorkAreaTop : WinY+WinHeight > WorkAreaBottom ? WorkAreaBottom-WinHeight : WinY

   WinMove ahk_id %MouseWin%,, WinX, WinY
Return

WorkAreaCheck:
SysGet WorkArea, MonitorWorkArea
Return
;; } /* PROCESSING */                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @NAME:       MenuEditIni                                                   ;;
;; @PARAMETER:  none                                                          ;;
;; @ABOUT:      Edit a ini file                                               ;;
;; {                                                                          ;;
MenuEditIni:
  ;; Launch default editor maximized.                                         ;;
  Run, QuahkeConsole.ini, , Max UseErrorLevel
  ;; when error to launch                                                     ;;
  if ErrorLevel = ERROR
    MsgBox cannot access QuahkeConsole.ini: No such file or directory.
Return
;; } /* MenuEditIni */                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @NAME:       MenuCreateSaveIni                                             ;;
;; @PARAMETER:  none                                                          ;;
;; @ABOUT:      Save all settings in a ini file                               ;;
;; {                                                                          ;;
MenuCreateSaveIni:
  IniWrite, %PosX%, QuahkeConsole.ini, Position, PosX
  IniWrite, %PosY%, QuahkeConsole.ini, Position, PosY

  IniWrite, %MaskSizeX%, QuahkeConsole.ini, Size, MaskSizeX
  IniWrite, %MaskSizeY%, QuahkeConsole.ini, Size, MaskSizeY

  IniWrite, %SizeX%, QuahkeConsole.ini, Size, SizeX
  IniWrite, %SizeY%, QuahkeConsole.ini, Size, SizeY

  IniWrite, %TerminalAlpha%, QuahkeConsole.ini, Misc, TerminalAlpha
  IniWrite, %TerminalTitle%, QuahkeConsole.ini, Misc, TerminalTitle

  IniWrite, %CharacterSizeX%, QuahkeConsole.ini, Font, CharacterSizeX
  IniWrite, %CharacterSizeY%, QuahkeConsole.ini, Font, CharacterSizeY

  IniWrite, %TerminalType%, QuahkeConsole.ini, Terminal, TerminalType

Return
;; } /* MenuCreateSaveIni */                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
