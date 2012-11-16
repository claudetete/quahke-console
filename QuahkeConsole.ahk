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
;; Version: 0.9
;; Created: February 2011
;; Last-Updated: November 2012

;;; Commentary:
;; Based on (htanks to Wojciech 'KosciaK' Pietrzok <kosciak1@gmail.com>):
;;  Opens Console in a Quake style (at the top of the screen using F1)
;;  http://code.google.com/p/kosciak-autohotkey/source/browse/trunk/TildaConsole
;;  /TildaConsole.ahk?r=18
;;
;;  Default settings are for cmd with default font (8x12) on Windows XP

;;; Change Log:
;; 2012-11-16 (0.9)
;;     fix behaviour in Win7 with cmd + add robustness + some fix for rxvt
;; 2012-11-15 (0.8)
;;     clean up + add smooth open/close + options in ini file
;; 2011-07-14 (0.7)
;;     add cmd.exe with cyygwin/rxvt
;; 2011-03-12 (0.6)
;;     change console2 by cygwin/rxvt to have full key compatibility
;; 2011-02-24 (0.5)
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

;
;;
;;; ENVIRONMENT
;; Recommended for performance and compatibility with future AutoHotkey.
#NoEnv
;; Recommended for new scripts due to its superior speed and reliability.
SendMode Input
;; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%
;; only on instance of this script
#SingleInstance force

;
;;
;;; SETTING
;; position in X to hide window decoration (screen left = 0)
IniRead, PosX,    QuahkeConsole.ini, Position, PosX, -5
;; position in Y to hide window decoration (screen top = 0)
IniRead, PosY,    QuahkeConsole.ini, Position, PosY, -25
;; offset to remove window decoration in X
IniRead, OffsetX, QuahkeConsole.ini, Position, OffsetX, 2
;; offset to remove window decoration in Y
IniRead, OffsetY, QuahkeConsole.ini, Position, OffsetY, 6
;;
;; percent size in X for the terminal window (%)
IniRead, SizePercentX, QuahkeConsole.ini, Size, SizePercentX, 100
;; percent size in Y for the terminal window (%)
IniRead, SizePercentY, QuahkeConsole.ini, Size, SizePercentY, 30
;;
;; font in terminal Cygwin/rxvt
IniRead, TerminalFont,   QuahkeConsole.ini, Font, TerminalFont, Terminal-8
;; Character Size in X
IniRead, CharacterSizeX, QuahkeConsole.ini, Font, CharacterSizeX, 8
;; Character Size in Y
IniRead, CharacterSizeY, QuahkeConsole.ini, Font, CharacterSizeY, 12
;;
;; type of terminal MS/cmd or Cygwin/rxvt
IniRead, TerminalType,  QuahkeConsole.ini, Terminal, TerminalType, cmd
;; title in terminal MS/cmd Cygwin/rxvt
IniRead, TerminalTitle, QuahkeConsole.ini, Terminal, TerminalTitle, QuahkeConsole
;;
;; Transparence of terminal in percent (invisible (0) to full opaque (100))
IniRead, TerminalAlpha,      QuahkeConsole.ini, Display, TerminalAlpha, 80
;; foreground color in terminal Cygwin/rxvt
IniRead, TerminalForeground, QuahkeConsole.ini, Display, TerminalForeground, white
;; background color in terminal Cygwin/rxvt
IniRead, TerminalBackground, QuahkeConsole.ini, Display, TerminalBackground, black
;; time in ms of animation of hide/show console window
IniRead, TerminalSlideTime,  QuahkeConsole.ini, Display, TerminalSlideTime, 250
;; time in ms of going to position in animation (Tau~63%, 3Tau~95%, 5Tau~99%)
IniRead, TerminalSlideTau,   QuahkeConsole.ini, Display, TerminalSlideTau, 70
;;
;; shell in terminal Cygwin/rxvt
IniRead, TerminalShell,   QuahkeConsole.ini, Misc, TerminalShell, bash
;; history size in terminal Cygwin/rxvt
IniRead, TerminalHistory, QuahkeConsole.ini, Misc, TerminalHistory, 5000
;; path of Cygwin (to run rxvt)
IniRead, ExecPath,        QuahkeConsole.ini, Misc, ExecPath, C:\cygwin\bin
;;
;; version number
SoftwareVersion := "0.9"
;;
;; Precision of pixel move for animation of the window
TimerMovePrecision := 20
;;
;; Unique ID of the console window
TerminalHWND := -1

;
;;
;;; ICON
;; get icon file into the exe
FileInstall, QuahkeConsole.ico, QuahkeConsole.ico, 1
;; display icon in tray zone
Menu, TRAY, Icon, QuahkeConsole.ico

;
;;
;;; MENU
;; Delete the current menu
Menu, tray, NoStandard
;; Add the item About in the menu
Menu, tray, add, About, MenuAbout
;; Creates a separator line.
Menu, tray, add
;; Add the item Reload in the menu
Menu, tray, add, Reload .ini file, MenuReload
;; Add the item Edit ini in the menu
Menu, tray, add, Edit .ini file, MenuEditIni
;; Add the item Create/Save ini in the menu
Menu, tray, add, Create/Save .ini file, MenuCreateSaveIni
;; Creates a separator line.
Menu, tray, add
;; add the standard menu
Menu, tray, Standard
return
;;
;; handler of the item about
MenuAbout:
  Gui, 2:Add, Text, 0x1, % "QuahkeConsole`nVersion " . SoftwareVersion
  Gui, 2:Show, AutoSize, About QuahkeConsole
Return
;;
;;   handler for the about window
2GuiClose:
2GuiEscape:
  ;; destroy the window without saving anything
  Gui, Destroy
Return
;;
;;   handler of the item Reload .ini
MenuReload:
  Reload
Return

;
;;
;;; SHORTCUT
;; Launch console if necessary; hide/show on Win+` or F1
F1::GoSub, ShowHide
;;
;; move by word (right)
#IfWinActive QuahkeConsole
^Right::
  Send {Escape}f
Return
;;
;; move by word (left)
#IfWinActive QuahkeConsole
^Left::
  Send {Escape}b
Return

;
;;
;;; PROCESSING
ShowHide:
  ;; enable detection of hidden window
  DetectHiddenWindows, on
  ;;
  ;; set match window title anywhere in the title
  SetTitleMatchMode, 3
  ;;
  ;; get the size of the current monitor (without taskbar)
  SysGet, ScreenSizeX, 61
  SysGet, ScreenSizeY, 62

  ;; get the console window id (-1 if nothing found)
  TerminalHWND := TerminalWindowExist()

  ;; if a console has been launched
  If TerminalHWND != -1
  {
    ;; if the console window is active
    IfWinActive ahk_id %TerminalHWND%
    {
      ;; to switch to the windows just under the console window
      SendInput !{Esc}
      ;; hide the window of console
      WindowSlideUp(TerminalHWND)
    }
    else
    {
      ;; when no window was save before the console window was not launched by
      ;; this instance of script
      If !PrevActive
      {
        ;; get size of terminal window
        WinGetPos, , , W, H, ahk_id %TerminalHWND%
        ;; set size of mask
        MaskX := W - OffsetX
        ;; the window decoration
        MaskY := H - OffsetY
      }
      ;; get the title of the current window
      PrevActive := WinActive()
      ;;
      ;; Display the hidden console window
      WindowSlideDown(TerminalHWND)
    }
  }
  else
  {
    ;; get the id of the current window
    PrevActive := WinActive()
    ;;
    ;; number of line and column in chosen font
    NbCharacterX := Round((SizePercentX * (ScreenSizeX - OffsetX + PosX)) / (100 * CharacterSizeX), 0)
    NbCharacterY := Round((SizePercentY * (ScreenSizeY - OffsetY + PosY)) / (100 * CharacterSizeY), 0)

    if TerminalType = cmd
    {
      ;; launch cmd
      Run "%A_WinDir%\system32\cmd.exe" /K "title %TerminalTitle% & mode con:cols=%NbCharacterX% lines=%NbCharacterY%", , Hide, WinPID
    }
    else if TerminalType = rxvt
    {
      ;; launch rxvt
      Run "%ExecPath%\rxvt.exe" -display :0 -sl %TerminalHistory% -fg %TerminalForeground% -bg %TerminalBackground% -fn %TerminalFont% -fb %TerminalFont% -fm %TerminalFont% -tn rxvt -title %TerminalTitle% -g %NbCharacterX%x%NbCharacterY% -e /bin/%TerminalShell% --login -i, , Hide, WinPID
      ;; rxvt is long to be launched so wait a little
      Sleep, 150
    }
    else
    {
      ;; show an error dialog box
      MsgBox, 0x80, QuahkeConsole: error, Error: wrong TerminalType, it must be "cmd" or "rxvt"
      Exit, -2
    }

    ;; wait instance of console window (FIXME PID for rxvt it is not the same)
    WinWait, ahk_pid %WinPID%
    ;;
    ;; get the unique id of the console window
    TerminalHWND := TerminalWindowExist()
    ;;
    ;; get size of terminal window
    WinGetPos, , , W, H, ahk_id %TerminalHWND%
    ;; set size of mask
    MaskX := W - OffsetX
    ;; the window decoration
    MaskY := H - OffsetY

    ;; make the window of the terminal with alpha of 200
    ;; (full transparent = 0, full opaque = 255)
    Alpha := (TerminalAlpha * 255) / 100
    WinSet, Transparent, %Alpha%, ahk_id %TerminalHWND%
    ;;
    ;; set the window to be always in front of other windows
    Winset, AlwaysOnTop, On, ahk_id %TerminalHWND%

    ;; show the window by the top
    WindowSlideDown(TerminalHWND)
  }

  ;; disable detection of hidden window
  DetectHiddenWindows, off
Return

;
;;
;;; Slide a Windows outside the screen by the top (to hide it)
WindowSlideUp(WindowHWND)
{
  global TerminalSlideTime, PosX, PosY, OffsetY, TimerMovePrecision, TerminalSlideTau

  ;; enable animation only when the timer is not null (or negative)
  if TerminalSlideTime > 0
  {
    ;; to be sure that the console window is at the right place
    WinMove, ahk_id %WindowHWND%, , PosX, PosY
    ;; move windows immediately
    SetWinDelay, -1
    ;; get pos and window size
    WinGetPos, WinPosX, WinPosY, W, H, ahk_id %WindowHWND%
    ;; Position of window out of screen to hide it
    WinHeight := H + PosY - OffsetY
    PosToStop := WinPosY - WinHeight

    ;; compute move precision to set time limit
    MovePrecision := Round((TimerMovePrecision * (H + PosY - OffsetY)) / TerminalSlideTime, 0)
    ;; init time value
    CurrentTime := 0

    ;; loop to move the window
    While, WinPosY > PosToStop
    {
      ;; when Tau is positive do the smooth animation
      if TerminalSlideTau > 0
      {
         ;; when time is not over
         if CurrentTime < TerminalSlideTime
         {
           ;; first order filter the position of window (last - 2 is to pass through 99%)
           WinPosY := PosToStop + Ceil(WinHeight * exp((CurrentTime / TerminalSlideTau) * -1)) - 2
         }
         else
         {
           ;; time is over set full position
           WinPosY := PosToStop
         }
      }
      else
      {
        ;; move up the window with the previcion pixel
        WinPosY := WinPosY - MovePrecision
      }

      ;; do not move to high
      if WinPosY > PosToStop
      {
        WinPosY := PosToStop
      }
      ;; positioning the window
      WinMove, ahk_id %WindowHWND%, , %PosX%, %WinPosY%
      ;; wait TimerMovePrecision ms (to create the animation)
      Sleep, %TimerMovePrecision%
      ;; increment time
      CurrentTime := CurrentTime + TimerMovePrecision
    }
  }
 ;; hide window from users
 WinHide, ahk_id %WindowHWND%
}
Return

;
;;
;;; Slide a Windows inside the screen by the top (to show it)
WindowSlideDown(WindowHWND)
{
  global TerminalSlideTime, PosX, PosY, OffsetY, TimerMovePrecision, MaskX, MaskY, TerminalSlideTau

  ;; move windows immediately
  SetWinDelay, -1

  ;; get window size
  WinGetPos, , , W, H, ahk_id %WindowHWND%

  ;; place the window
  WinMove, ahk_id %WindowHWND%, , PosX, ((H + PosY + OffsetY) * -1)
  WinSet, Region, 0-0 w%MaskX% h%MaskY%, ahk_id %WindowHWND%

  ;; Display the hidden console2 window
  WinShow, ahk_id %WindowHWND%

  ;; make active the console2 window
  WinActivate, ahk_id %WindowHWND%

  ;; enable animation only when the timer is not null (or negative)
  if TerminalSlideTime > 0
  {
    ;; get pos and window size
    WinGetPos, WinPosX, WinPosY, W, H, ahk_id %WindowHWND%
    ;; height of showed window
    WinHeight := H + PosY - OffsetY
    ;; Position of window out of screen to showit
    PosToStop := PosY

    ;; compute move precision to set time limit
    MovePrecision := Round((TimerMovePrecision * (H + PosY - OffsetY)) / TerminalSlideTime, 0)
    ;; init time value
    CurrentTime := 0

    ;; loop to move the window
    While, WinPosY < PosToStop
    {
      ;; when Tau is positive do the smooth animation
      if TerminalSlideTau > 0
      {
         ;; when time is not over
         if CurrentTime < TerminalSlideTime
         {
           ;; first order filter the position of window (last + 2 is to pass through 99%)
           WinPosY := PosToStop - Ceil(WinHeight * exp((CurrentTime / TerminalSlideTau) * -1)) + 2
         }
         else
         {
           ;; time is over set full position
           WinPosY := PosToStop
         }
      }
      else
      {
        ;; move up the window with the previcion pixel
        WinPosY := WinPosY + MovePrecision
      }

      ;; do not move too down
      if WinPosY > PosToStop
      {
        WinPosY := PosToStop
      }
      ;; positioning the window
      WinMove, ahk_id %WindowHWND%, , %PosX%, %WinPosY%
      ;; wait TimerMovePrecision ms (to create the animation)
      Sleep, %TimerMovePrecision%
      ;; increment time
      CurrentTime := CurrentTime + TimerMovePrecision
    }
  }

  ;; to be sure that the console window is at the right place
  WinMove, ahk_id %WindowHWND%, , PosX, PosY
}
Return

;
;;
;;; Return the unique ID of the console windows if it exists
TerminalWindowExist()
{
  global TerminalTitle, TerminalType

  ;; get all windows id
  WinGet, id, list,,, Program Manager
  ;; go through all windows id
  Loop, %id%
  {
    ;; get ahk id
    WinId := id%A_Index%
    ;; get the title
    WinGetTitle, WinTitle, ahk_id %WinId%
    ;; set regex
    tmpMatched = "i).*%TerminalTitle%$"
    ;; match the title
    WinTitleMatched := RegExMatch(WinTitle, tmpMatched)
    ;; when the title match the terminal title
    If WinTitleMatched != 0
    {
      ;; get process name of this window
      WinGet, WinPName, ProcessName, ahk_id %WinId%
      ;; when the process name match the terminal type
      IfInString, WinPName, %TerminalType%
      {
        ;; return id of this window
        Return WinId
      }
    }
  }

  ;; nothing has been found
  Return -1
}
Return

;
;;
;;; Edit a ini file
MenuEditIni:
  ;; Launch default editor maximized.
  Run, QuahkeConsole.ini, , Max UseErrorLevel
  ;; when error to launch
  if ErrorLevel = ERROR
    MsgBox cannot access QuahkeConsole.ini: No such file or directory.
Return

;
;;
;;; Save all settings in a ini file
MenuCreateSaveIni:
  ;; Section Position
  IniWrite, %PosX%,    QuahkeConsole.ini, Position, PosX
  IniWrite, %PosY%,    QuahkeConsole.ini, Position, PosY
  IniWrite, %OffsetX%, QuahkeConsole.ini, Position, OffsetX
  IniWrite, %OffsetY%, QuahkeConsole.ini, Position, OffsetY
  ;; Section Size
  IniWrite, %SizePercentX%, QuahkeConsole.ini, Size, SizePercentX
  IniWrite, %SizePercentY%, QuahkeConsole.ini, Size, SizePercentY
  ;; Section Font
  IniWrite, %TerminalFont%,   QuahkeConsole.ini, Font, TerminalFont
  IniWrite, %CharacterSizeX%, QuahkeConsole.ini, Font, CharacterSizeX
  IniWrite, %CharacterSizeY%, QuahkeConsole.ini, Font, CharacterSizeY
  ;; Section Terminal
  IniWrite, %TerminalType%,  QuahkeConsole.ini, Terminal, TerminalType
  IniWrite, %TerminalTitle%, QuahkeConsole.ini, Terminal, TerminalTitle
  ;; Section Display
  IniWrite, %TerminalAlpha%,      QuahkeConsole.ini, Display, TerminalAlpha
  IniWrite, %TerminalForeground%, QuahkeConsole.ini, Display, TerminalForeground
  IniWrite, %TerminalBackground%, QuahkeConsole.ini, Display, TerminalBackground
  IniWrite, %TerminalSlideTime%,  QuahkeConsole.ini, Display, TerminalSlideTime
  IniWrite, %TerminalSlideTau%,  QuahkeConsole.ini, Display, TerminalSlideTau
  ;; Section Misc
  IniWrite, %TerminalShell%,   QuahkeConsole.ini, Misc, TerminalShell
  IniWrite, %TerminalHistory%, QuahkeConsole.ini, Misc, TerminalHistory
  IniWrite, %ExecPath%,        QuahkeConsole.ini, Misc, ExecPath
Return
