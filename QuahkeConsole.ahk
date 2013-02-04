;;; QuahkeConsole.ahk --- Open a Quake-like terminal like tilda, guake or
;;;                       yakuake but in MS Windows

;; Copyright (c) 2011-2013 Claude Tete
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
;; Version: 1.4
;; Created: February 2011
;; Last-Updated: January 2013

;;; Commentary:
;; Based on (thanks to Wojciech 'KosciaK' Pietrzok <kosciak1@gmail.com>):
;;  Opens Console in a Quake style (at the top of the screen using F1)
;;  http://code.google.com/p/kosciak-autohotkey/source/browse/trunk/TildaConsole
;;  /TildaConsole.ahk?r=18
;;
;;  Default settings are for cmd with default font (8x12) on Windows XP
;;  see http://code.google.com/p/quahke-console/wiki/UserGuide for other setting
;;
;;  may do not function with bash or other shell which modify the terminal title

;;; Change Log:
;; 2013-01-11 (1.4)
;;     options in ini file can be modified by gui + ini file can be give by a
;;     parameter + set default offset + fix bug when no opened window
;; 2013-01-07 (1.3)
;;     shortcut can be specified + update gui + fix position when unfocus
;; 2012-12-11 (1.2)
;;     no animation when the window is visible but not active
;; 2012-12-04 (1.1)
;;     set alpha and always on top in slide down (not only with creation)
;; 2012-11-22 (1.0)
;;     hide decoration with rxvt (not possible with cmd) + fix compute number of
;;     characters + add mintty (with option to use default config)
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

;;; Code:
;
;;
;;; ENVIRONMENT
;; Recommended for performance and compatibility with future AutoHotkey.
#NoEnv
;; Recommended for catching common errors.
#Warn
;; Recommended for new scripts due to its superior speed and reliability.
SendMode Input
;; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%
;; only on instance of this script
#SingleInstance force
;; application name use in msgbox, etc
ApplicationName = QuahkeConsole

;
;;
;;; PARAMETERS
if 0 > 0
{
  ;; get first parameter
  IniFilePath = %1%
  ;; when file exist
  IfExist, IniFilePath
  {
    ;; get long path instead of short path
    Loop %IniFilePath%, 1
      IniFile = %A_LoopFileLongPath%
  }
  else
  {
    ;; file do not exist
    IniFile = %IniFilePath%
  }
}
else
{
  ;; no parameter
  IniFile = %ApplicationName%.ini
}

;
;;
;;; SETTING
GoSub, LoadIniFile
;;
;; version number
SoftwareVersion = 1.4
;;
;; Precision of pixel move for animation of the window
TimerMovePrecision := 20
;;
;; Unique ID of the console window
TerminalHWND := -1
;;
;; screen size
ScreenSizeX := 0
ScreenSizeY := 0
;; Console window position
PosX := 0
PosY := 0

;
;;
;;; SHORTCUT
;; Launch console if necessary and hide/show
;; (need to be before menu and icon)
HotKey, %ShortcutShowHide%, ShowHide

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
;; Add the item Shortcuts in the menu
Menu, tray, add, Options, MenuOptions
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
Return

;
;;
;;; PROCESSING
;;
;;; Show or Hide the Console Window
ShowHide:
  ;; enable detection of hidden window
  DetectHiddenWindows, on
  ;;
  ;; set match window title anywhere in the title
  SetTitleMatchMode, 3

  ;; get the console window id (-1 if nothing found)
  TerminalHWND := TerminalWindowExist()

  ;; if a console has been launched
  if TerminalHWND != -1
  {
    ;; if the console window is active
    IfWinActive ahk_id %TerminalHWND%
    {
      ;; to switch to the windows just under the console window
      SendInput !{Esc}

      ;; when no window has taken focus
      IfWinActive ahk_id %TerminalHWND%
      {
        ;; activate the taskbar
        WinActivate, ahk_class Shell_TrayWnd
      }

      ;; hide the window of console
      WindowSlideUp(TerminalHWND)
    }
    else
    {
      ;; do not detect hidden window
      DetectHiddenWindows, off
      ;; when console window is visible
      IfWinExist, ahk_id %TerminalHWND%
      {
        ;; remove window decoration and apply alpha and always on top
        WindowDesign(TerminalHWND)
        ;; to be sure that the console window is at the right place
        WinMove, ahk_id %TerminalHWND%, , PosX, PosY
        ;; put focus on the console window
        WinActivate, ahk_id %TerminalHWND%
      }
      else
      {
        DetectHiddenWindows, on
        ;; remove window decoration and apply alpha and always on top
        WindowDesign(TerminalHWND)
        ;; Display the hidden console window
        WindowSlideDown(TerminalHWND)
      }
    }
  }
  else
  {
    ;; get the size of the current monitor (without taskbar)
    SysGet, ScreenSizeX, 16 ; not 61
    SysGet, ScreenSizeY, 17 ; not 62
    ;;
    ;; number of line and column in chosen font (CharacterSizeY + 1 pixel to consider the space between line)
    NbCharacterX := Ceil((SizePercentX * ScreenSizeX) / (100 * CharacterSizeX))
    NbCharacterY := Ceil((SizePercentY * ScreenSizeY) / (100 * CharacterSizeY))

    ;;;;;;;;;;;;;;;;;;;;;
    ;; CMD
    ;;;;;;;;;;;;;;;;;;;;;
    if TerminalType = cmd
    {
      NbCharacterY += 1
      ;; launch cmd
      Run "%A_WinDir%\system32\cmd.exe" /K "title %TerminalTitle% & mode con:cols=%NbCharacterX% lines=%NbCharacterY%", , , WinPID
    }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; RXVT
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    else if TerminalType = rxvt
    {
      ;; to view all character
      NbCharacterX := NbCharacterX - 1
      ;; launch rxvt
      Run "%ExecPath%\rxvt.exe" -display :0 -sl %TerminalHistory% -fg %TerminalForeground% -bg %TerminalBackground% -fn %TerminalFont% -fb %TerminalFont% -fm %TerminalFont% -tn rxvt -title %TerminalTitle% -g %NbCharacterX%x%NbCharacterY% -e /bin/%TerminalShell% --login -i, , Hide, WinPID
    }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; MINTTY
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    else if TerminalType = mintty
    {
      if NoConfigMintty = True
      {
        ;; take default config file (~/.minttyrc)
        ConfigMintty =
      }
      else
      {
        ;; split font and font size
        StringSplit, Fonts, TerminalFont, -

        ;; manage mintty transparency
        ;; transparency is not very strong
        TerminalTransparency = off ; min
        if TerminalAlpha < 100
        {
          TerminalTransparency = low
        }
        else if TerminalAlpha < 98
        {
           TerminalTransparency = medium
        }
        else if TerminalAlpha < 95
        {
          TerminalTransparency = high ; max
        }

        ;; make config file
        FileDelete, QuahkeConsolerc
        FileAppend,
        (
Font=%Fonts1%
FontHeight=%Fonts2%
Transparency=%TerminalTransparency%
Scrollbar=none
        ), QuahkeConsolerc

        ;; take temporary config file
        ConfigMintty = --config QuahkeConsolerc
      }

      ;; to view all character
      NbCharacterX := NbCharacterX - 1
      ;; launch mintty
      Run "%ExecPath%\mintty.exe" --title %TerminalTitle% %ConfigMintty% --size %NbCharacterX%`,%NbCharacterY% --exec /bin/%TerminalShell% --login -i, , Hide, WinPID
    }
    ;;;;;;;;;;;;;
    ;; Unknown
    ;;;;;;;;;;;;;
    else
    {
      ;; show an error dialog box
      MsgBox, 0x10, %ApplicationName%: error, Error: wrong TerminalType, it must be "cmd" or "rxvt" or "mintty"
      Exit, -2
    }

    ;; wait instance of console window
    WinWaitActive, ahk_pid %WinPID%
    ;;
    Sleep, 250
    ;;
    ;; get the unique id of the console window
    TerminalHWND := TerminalWindowExist()

    ;; remove window decoration and apply alpha and always on top
    WindowDesign(TerminalHWND)
    ;; show the window by the top
    WindowSlideDown(TerminalHWND)
  }

  ;; disable detection of hidden window
  DetectHiddenWindows, off
Return

;
;;
;;; FUNCTIONS
;;
;;; Slide a Windows outside the screen by the top (to hide it)
WindowSlideUp(WindowHWND)
{
  global TerminalSlideTime, PosX, PosY, OffsetBottom, TimerMovePrecision, TerminalSlideTau

  ;; move windows immediately
  SetWinDelay, -1

;; enable animation only when the timer is not null (or negative)
  if TerminalSlideTime > 0
  {
    ;; to be sure that the console window is at the right place
    WinMove, ahk_id %WindowHWND%, , PosX, PosY
    ;; get pos and window size
    WinGetPos, WinPosX, WinPosY, W, H, ahk_id %WindowHWND%
    ;; Position of window out of screen to hide it
    WinHeight := H - OffsetBottom
    PosToStop := PosY - WinHeight

    ;; compute move precision to set time limit
    MovePrecision := (TimerMovePrecision * WinHeight) / TerminalSlideTime
    ;; compute coef for first order filter
    FirstOrderCoef := 1 - exp(-MovePrecision / TerminalSlideTau)
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
          WinPosY := WinPosY + ((PosToStop - WinPosY) * FirstOrderCoef) - 2
        }
        else
        {
          ;; time is over set full position
          WinPosY := PosToStop
        }
      }
      else
      {
        ;; move up the window with the precision pixel
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

;;
;;; Slide a Windows inside the screen by the top (to show it)
WindowSlideDown(WindowHWND)
{
  global TerminalSlideTime, PosX, PosY, TimerMovePrecision, TerminalSlideTau
  global OffsetTop, OffsetLeft, ScreenSizeX, ScreenSizeY
  global PosX, PosY, NbCharacterX, SizePercentX

  ;; move windows immediately
  SetWinDelay, -1

  ;; get window size
  WinGetPos, , , W, H, ahk_id %WindowHWND%
  if SizePercentX != 100
  {
    PosX := Ceil((ScreenSizeX - ((SizePercentX * ScreenSizeX) / 100)) / 2) - OffsetLeft
  }
  else
  {
    PosX := -OffsetLeft
  }
  PosY := -OffsetTop

  ;; place the window
  WinMove, ahk_id %WindowHWND%, ,  PosX, PosY - H
  ;;
  ;; Display the hidden console window
  WinShow, ahk_id %WindowHWND%
  ;;
  ;; make active the console2 window
  WinActivate, ahk_id %WindowHWND%

  ;; enable animation only when the timer is not null (or negative)
  if TerminalSlideTime > 0
  {
    ;; get pos and window size
    WinGetPos, WinPosX, WinPosY, W, H, ahk_id %WindowHWND%
    ;; height of showed window
    WinHeight := H
    ;; Position of window out of screen to showit
    PosToStop := PosY

    ;; compute move precision to set time limit
    MovePrecision := (TimerMovePrecision * WinHeight) / TerminalSlideTime
    ;; compute coef for first order filter
    FirstOrderCoef := 1 - exp(-MovePrecision / TerminalSlideTau)
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
          WinPosY := WinPosY + ((PosToStop - WinPosY) * FirstOrderCoef) + 2
        }
        else
        {
          ;; time is over set full position
          WinPosY := PosToStop
        }
      }
      else
      {
        ;; move up the window with the precision pixel
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

;;
;;; apply alpha, always on top and remove decoration of console window
WindowDesign(WindowHWND)
{
  global TerminalAlpha, TerminalAlwaysOnTop, OffsetTop, OffsetLeft, OffsetBottom, OffsetRight
  ;;
  ;; styles to be remove from console window
  WS_POPUP         := 0x80000000
  WS_CAPTION       :=   0xC00000
  WS_THICKFRAME    :=    0x40000
  WS_EX_CLIENTEDGE :=      0x200

  ;; move windows immediately
  SetWinDelay, -1

  ;; make the window of the terminal with alpha of 200 (only with rxvt)
  ;; (full transparent = 0, full opaque = 255)
  Alpha := (TerminalAlpha * 255) / 100
  WinSet, Transparent, %Alpha%, ahk_id %WindowHWND%
  ;;
  ;; console window always on top ? (use by test script)
  if TerminalAlwaysOnTop = True
  {
    ;; set the window to be always in front of other windows
    Winset, AlwaysOnTop, On, ahk_id %WindowHWND%
  }
  else
  {
    ;; set the window to be always in front of other windows
    Winset, AlwaysOnTop, Off, ahk_id %WindowHWND%
  }

  ;; remove almost all decoration window (do not work with cmd)
  WinSet, Style, % -(WS_POPUP|WS_CAPTION|WS_THICKFRAME), ahk_id %WindowHWND%
  WinSet, ExStyle, % -WS_EX_CLIENTEDGE, ahk_id %WindowHWND%

  ;; get window size
  WinGetPos, , , W, H, ahk_id %WindowHWND%
  ;; TODO get size window decoration
  ;; set size of mask to hide window decoration
  MaskX := W - OffsetRight - OffsetLeft
  MaskY := H - OffsetBottom - OffsetTop
  ;; mask window border
  WinSet, Region, %OffsetLeft%-%OffsetTop% w%MaskX% h%MaskY%, ahk_id %WindowHWND%
}
Return

;;
;;; Return the unique ID of the console windows if it exists
TerminalWindowExist()
{
  global TerminalTitle, TerminalType

  ;; set regex
  RegExMatched = i).*%TerminalTitle%\s*$
  ;; get all windows id
  WinGet, id, list, , , Program Manager
  ;; go through all windows id
  Loop, %id%
  {
    ;; get ahk id
    WinId := id%A_Index%
    ;; get the title
    WinGetTitle, WinTitle, ahk_id %WinId%
    if WinTitle
    {
      ;; match the title
      WinTitleMatched := RegExMatch(WinTitle, RegExMatched)
      ;; when the title match the terminal title
      if WinTitleMatched
      {
        if  WinTitleMatched > 0
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
    }
  }
  ;; nothing was found
  Return -1
}
Return

;
;;
;;; MENU HANDLER
;;
;;; handler of the item about
MenuAbout:
  Gui, About_:Margin, 30, 10
  Gui, About_:Add, Text, 0x1, % ApplicationName "`nVersion " . SoftwareVersion
  Gui, About_:Show, AutoSize, About %ApplicationName%
Return
;;
;;; handler for the about window
About_GuiClose:
About_GuiEscape:
  ;; destroy the window without saving anything
  Gui, Destroy
Return
;;
;;; handler of the item Reload .ini
MenuReload:
  GoSub, LoadIniFile
Return

;;
;;; handler for the item options
MenuOptions:
  ;; CONSOLE
  ;; frame with title "Console"
  Gui, Options_:Add, GroupBox, x8 y3 w550 h45, Console
  ;; display rigth type in list || after mean selected
  if TerminalType = cmd
    OptionsType = cmd||rxvt|mintty
  else if TerminalType = rxvt
    OptionsType = cmd|rxvt||mintty
  else if TerminalType = mintty
    OptionsType = cmd|rxvt|mintty||
  ;; add label at 15x15 pixels margin previous frame "Console"
  Gui, Options_:Add, Text, xp+15 yp+15 Section, Type (*):
  ;; add list in a new column
  Gui, Options_:Add, DropDownList, ys w70 gOptions_SetDefaultOffset vTType, %OptionsType%
  ;; add label in a new column
  Gui, Options_:Add, Text, ys, Title (*):
  ;; add edit in a new column
  Gui, Options_:Add, Edit, ys w350 vTTitle, %TerminalTitle%

  ;; SIZE
  ;; frame with title "Size"
  Gui, Options_:Add, GroupBox, x8 w550 h70, Size
  ;; label at 15x15 pixels margin previous frame "Size"
  Gui, Options_:Add, Text, xp+15 yp+15 w63 Section, Horizontal (*):
  ;; slider in a new column from 1 to 100 (at each modification it calls Options_SetNumSizePercentX)
  Gui, Options_:Add, Slider, ys w400 h20 Range1-100 TickInterval25 AltSubmit gOptions_SetNumSizePercentX vSlideSizePercentX, %SizePercentX%
  ;; edit in a new column (at each modification it calls Options_SetEditSlideSizePercentX)
  Gui, Options_:Add, Edit, ys xp+402 w40 gOptions_SetEditSlideSizePercentX vNumEditSizePercentX, %SizePercentX%
  ;; updown (arrows) associated with the previous edit (at each modification it calls Options_SetSlideSizePercentX)
  Gui, Options_:Add, UpDown, Range1-100 gOptions_SetSlideSizePercentX vNumSizePercentX, %SizePercentX%
  ;; label in a new column (xp+42 place it at 42 pixels from left of previous edit (width 40 + 2))
  Gui, Options_:Add, Text, ys xp+42, `%
  ;;
  ;; label in a new row
  Gui, Options_:Add, Text, xs w63 Section, Vertical (*):
  ;; slider from 1 to 100 (at each modification it call Options_SetNumSizePercentY)
  Gui, Options_:Add, Slider, ys w400 h20 Range1-100 TickInterval25 AltSubmit gOptions_SetNumSizePercentY vSlideSizePercentY, %SizePercentY%
  ;; edit in a new column (at each modification it calls Options_SetEditSlideSizePercentY)
  Gui, Options_:Add, Edit, ys xp+402 w40 gOptions_SetEditSlideSizePercentY vNumEditSizePercentY, %SizePercentY%
  ;; updown (arrows) associated with the previous edit (at each modification it calls Options_SetSlideSizePercentY)
  Gui, Options_:Add, UpDown, Range1-100 gOptions_SetSlideSizePercentY vNumSizePercentY, %SizePercentY%
  ;; label in a new column (xp+42 place it at 42 pixels from left of previous edit (width 40 + 2))
  Gui, Options_:Add, Text, ys xp+42, `%

  ;; FONTS
  ;; frame with title "Fonts"
  Gui, Options_:Add, GroupBox, x8 w550 h70, Fonts
  ;; label at 15x15 pixels margin previous frame "Fonts"
  Gui, Options_:Add, Text, xp+15 yp+15 w105 Section, Font (not cmd) (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w411 vTFont, %TerminalFont%
  ;;
  ;; label in a new row
  Gui, Options_:Add, Text, xs w105 Section, Character:    Width (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %CharacterSizeX%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range1-100 vCSizeX, %CharacterSizeX%
  ;; label in a new column (xp+42 place it at 42 pixels from left of previous edit (width 40 + 2))
  Gui, Options_:Add, Text, ys xp+42, pixels              Height (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %CharacterSizeY%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range1-100 vCSizeY, %CharacterSizeY%
  ;; label in a new column (xp+42 place it at 42 pixels from left of previous edit (width 40 + 2))
  Gui, Options_:Add, Text, ys xp+42, pixels

  ;; DECORATION
  ;; frame with title "Decoration"
  Gui, Options_:Add, GroupBox, x8 w550 h70, Decoration
  ;; label at 15x15 pixels margin previous frame "Decoration"
  Gui, Options_:Add, Text, xp+15 yp+15 Section, Alpha (not cmd) (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %TerminalAlpha%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-100 vTAlpha, %TerminalAlpha%
  ;; label in a new column (xp+42 place it at 42 pixels from left of previous edit (width 40 + 2))
  Gui, Options_:Add, Text, ys xp+42, `%
  ;; checkbox in a new column
  if TerminalAlwaysOnTop = True
    Gui, Options_:Add, CheckBox, ys xp+40 h20 Checked1 vTAlwaysOnTop, Always On Top
  else
    Gui, Options_:Add, CheckBox, ys xp+40 h20 Checked0 vTAlwaysOnTop, Always On Top
  Gui, Options_:Add, Button, w90 xp+150 gOptions_SetDefaultOffset, Default Offset
  ;;
  ;; label in a new row
  Gui, Options_:Add, Text, xs Section, Offset mask:       left:
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %OffsetLeft%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-1000 vOLeft, %OffsetLeft%
  ;; label in a new column
  Gui, Options_:Add, Text, ys xp+42, px       top:
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %OffsetTop%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-1000 vOTop, %OffsetTop%
  ;; label in a new column
  Gui, Options_:Add, Text, ys xp+42, px       bottom:
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %OffsetBottom%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-1000 vOBottom, %OffsetBottom%
  ;; label in a new column
  Gui, Options_:Add, Text, ys xp+42, px       right:
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w40, %OffsetRight%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-1000 vORight, %OffsetRight%
  ;; label in a new column
  Gui, Options_:Add, Text, ys xp+42, px

  ;; ANIMATION
  ;; frame with title "Animation"
  Gui, Options_:Add, GroupBox, x8 w550 h45, Animation
  ;; label at 15x15 pixels margin previous frame "Animation"
  Gui, Options_:Add, Text, xp+15 yp+15 Section, Animation Duration (ms):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w55, %TerminalSlideTime%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-10000 vTSlideTime, %TerminalSlideTime%
  ;; label in a new column (xp+95 place it at 95 pixels from left of previous edit (width 55 + 40))
  Gui, Options_:Add, Text, ys xp+95, Animation Acceleration (tau): (mostly duration / 5)
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w48, %TerminalSlideTau%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-2000 vTSlideTau, %TerminalSlideTau%

  ;; COLOR
  ;; frame with title "Color (not cmd and mintty)"
  Gui, Options_:Add, GroupBox, x8 w550 h45, Color (not cmd mintty)
  ;; label at 15x15 pixels margin previous frame "Color (not cmd and mintty)"
  Gui, Options_:Add, Text, xp+15 yp+15 Section, Foreground (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w100 vTForeground, %TerminalForeground%
  ;; label in a new column (xp+140 place it at 140 pixels from left of previous edit (width 100 + 40))
  Gui, Options_:Add, Text, ys xp+140, Background (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w105 vTBackground, %TerminalBackground%

  ;; SHORTCUT
  ;; frame with title "Shortcut"
  Gui, Options_:Add, GroupBox, x8 w550 h45, Shortcut
  ;; checkbox at 15x15 pixels margin previous frame "Shortcut"
  IfInString, ShortcutShowHide, #
  {
    Gui, Options_:Add, CheckBox, xp+15 yp+15 h20 Section Checked1 vWinKey, Windows + ...
    ;; remove windows keys reference
    StringReplace, myShortcut, ShortcutShowHide, #, , All
  }
  else
  {
    Gui, Options_:Add, CheckBox, xp+15 yp+15 h20 Section Checked0 vWinKey, Windows + ...
    myShortcut = %ShortcutShowHide%
  }
  ;; edit to capture shortcut in a new column
  Gui, Options_:Add, Hotkey, ys w200 vSShowHide, %myShortcut%

  ;; MISC
  ;; frame with title "Misc (not cmd)"
  Gui, Options_:Add, GroupBox, x8 w550 h70, Misc (not cmd)
  ;; label at 15x15 pixels margin previous frame "Misc (not cmd)"
  Gui, Options_:Add, Text, xp+15 yp+15 Section, Shell (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w100 vTShell, %TerminalShell%
  ;; label in a new column (xp+140 place it at 140 pixels from left of previous edit (width 100 + 40))
  Gui, Options_:Add, Text, ys xp+140, History (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w65, %TerminalHistory%
  ;; updown (arrows) associated with the previous edit
  Gui, Options_:Add, UpDown, Range0-100000 vTHistory, %TerminalHistory%
  ;; checkbox in a new column (xp+105 place it at 105 pixels from left of previous edit (width 65 + 40))
  if NoConfigMintty = True
    Gui, Options_:Add, CheckBox, ys xp+105 h20 Checked1 vNConfigMintty, Use .minttyrc (*)
  else
    Gui, Options_:Add, CheckBox, ys xp+105 h20 Checked0 vNConfigMintty, Use .minttyrc (*)
  ;; label in a new row
  Gui, Options_:Add, Text, xs Section, Cygwin bin path (*):
  ;; edit in a new column
  Gui, Options_:Add, Edit, ys w425 vEPath, %ExecPath%

  ;; TEXT
  ;; label centered in a new row
  Gui, Options_:Add, Text, x8 w550 Center, (*) need to quit the console before modified.

  ;; BUTTON
  ;; OK button (default) (center with the Cancel button Width (550 - 70 - 10 - 70) / 2 = 200)
  Gui, Options_:Add, Button, w70 x200 Section Default, OK
  ;; Cancel button in a new column (gap of 10 pixels between the button)
  Gui, Options_:Add, Button, w70 ys, Cancel
  ;; checkbox in a new column (xp+90 place it at 90 pixels from left of previous edit (width 70 + 20))
  Gui, Options_:Add, CheckBox, ys xp+90 Checked1 vSaveIniFile, Save settings

  ;; display the gui
  Gui, Options_:Show, AutoSize, %ApplicationName% - Options
Return
;;
;;; handler for slider and updown size
Options_SetNumSizePercentX:
  ;; set size percent of edit from slider
  GuiControl, Text, Edit2, %SlideSizePercentX%
Return
Options_SetNumSizePercentY:
  ;; set size percent of edit from slider
  GuiControl, Text, Edit3, %SlideSizePercentY%
Return
Options_SetSlideSizePercentX:
  ;; set size percent of slider from updown
  GuiControl, , msctls_trackbar321, %NumSizePercentX%
Return
Options_SetEditSlideSizePercentX:
  ;; set size percent of slider from edit
  GuiControlGet, NumEditSizePercentX
  GuiControl, , msctls_trackbar321, %NumEditSizePercentX%
Return
Options_SetSlideSizePercentY:
  ;; set size percent of slider from updown
  GuiControl, , msctls_trackbar322, %NumSizePercentY%
Return
Options_SetEditSlideSizePercentY:
  ;; set size percent of slider from edit
  GuiControlGet, NumEditSizePercentY
  GuiControl, , msctls_trackbar322, %NumEditSizePercentY%
Return
;;
;;; set the default offset
Options_SetDefaultOffset:
  ;; get console type
  GuiControlGet, TType
  ;; get default offset value
  OffsetArray := DefaultOffset(TType)
  ;; set gui with these value
  GuiControl, Text, Edit8,  % OffsetArray[1] ; left
  GuiControl, Text, Edit9,  % OffsetArray[2] ; top
  GuiControl, Text, Edit10, % OffsetArray[3] ; bottom
  GuiControl, Text, Edit11, % OffsetArray[4] ; right
Return
;;
;;: handler for the set shortcut window
Options_GuiClose:
Options_GuiEscape:
Options_ButtonCancel:
  ;; destroy the window without saving anything
  Gui, Destroy
Return
;;
;;; handler for the OK button of set shortcut window
Options_ButtonOK:
  ;; get the variable from the gui options
  GuiControlGet, TType
  GuiControlGet, TTitle
  GuiControlGet, NumSizePercentX
  GuiControlGet, NumSizePercentY
  GuiControlGet, TFont
  GuiControlGet, CSizeX
  GuiControlGet, CSizeY
  GuiControlGet, TAlpha
  GuiControlGet, TAlwaysOnTop
  GuiControlGet, OLeft
  GuiControlGet, OTop
  GuiControlGet, OBottom
  GuiControlGet, ORight
  GuiControlGet, TForeground
  GuiControlGet, TBackground
  GuiControlGet, TSlideTime
  GuiControlGet, TSlideTau
  GuiControlGet, WinKey
  GuiControlGet, SSHowHide
  GuiControlGet, TShell
  GuiControlGet, THistory
  GuiControlGet, EPath
  GuiControlGet, NConfigMintty
  GuiControlGet, SaveIniFile
  ;; remove the gui
  Gui, Destroy

  ;; enable detection of hidden window
  DetectHiddenWindows, on

  ;; get the console window id (-1 if nothing found)
  TerminalHWND := TerminalWindowExist()

  ;; if a console is launched
  if TerminalHWND != -1
  {
    ;; hide the console if already launch
    IfWinExist, ahk_id %TerminalHWND%
    {
      WindowSlideUp(TerminalHWND)
    }
  }
  ;; set global variables
  TerminalFont    = %TFont%
  CharacterSizeX := CSizeX
  CharacterSizeY := CSizeY
  TerminalAlpha  := TAlpha
  if TAlwaysOnTop = 1
  {
    TerminalAlwaysOnTop = True
  }
  else
  {
     TerminalAlwaysOnTop = False
  }
  OffsetLeft         := OLeft
  OffsetTop          := OTop
  OffsetBottom       := OBottom
  OffsetRight        := ORight
  TerminalForeground  = %TForeground%
  TerminalBackground  = %TBackground%
  TerminalSlideTime  := TSlideTime
  TerminalSlideTau   := TSlideTau
  TerminalShell       = %TShell%
  TerminalHistory    := THistory
  ExecPath            = %EPath%
  if NConfigMintty = 1
  {
    NoConfigMintty = True
  }
  else
  {
    NoConfigMintty = False
  }

  ;; when some settings are changed the console must be restart
  if (TType != TerminalType or TTitle != TerminalTitle or NumSizePercentX != SizePercentX or NumSizePercentY != SizePercentY or TFont != TerminalFont or CSizeX != CharacterSizeX or CSizeY != CharacterSizeY or (TType = "rxvt" and TForeground != TerminalForeground) or (TType = "rxvt" and TBackground != TerminalBackground) or (TType = "rxvt" and TShell != TerminalShell) or (TType = "rxvt" and THistory != TerminalHistory))
  {
    if TerminalHWND != -1
    {
      ;; remove window decoration and apply alpha and always on top
      WindowDesign(TerminalHWND)
      ;; show the console window to allow the user to close the console
      WindowSlideDown(TerminalHWND)
      MsgBox, 0x30, %ApplicationName%: console setting modified, The console have to be stopped (or it will be kill).
      ;; kill the console if not closed
      IfWinExist, ahk_id %TerminalHWND%
      {
        WinClose, ahk_id %TerminalHWND%
      }
    }

    ;; set gloabl variables
    TerminalType  = %TType%
    TerminalTitle = %TTitle%
    SizePercentX  := NumSizePercentX
    SizePercentY  := NumSizePercentY

    ;; launch console with new settings
    GoSub, ShowHide
  }
  else
  {
    ;; if a console is launched
    if TerminalHWND != -1
    {
      ;; hide the console if already launch
      IfWinExist, ahk_id %TerminalHWND%
      {
        ;; remove window decoration and apply alpha and always on top
        WindowDesign(TerminalHWND)
        ;; show the window by the top
        WindowSlideDown(TerminalHWND)
      }
    }
  }

  ;; get new shortcut and set it
  Options_SetShortcut(SSHowHide, WinKey)

  if SaveIniFile = 1
  {
    GoSub, MenuCreateSaveIni
  }
Return

;;
;;; set new shortcut
Options_SetShortcut(Key, WindowKey)
{
  global ShortcutShowHide, ApplicationName

  ;; when the checkbox window key is checked
  if WindowKey = 1
  {
    ;; prefix shortcut with #
    Key = % "#" Key
  }
  ;; unset previous shortcut
  HotKey, %ShortcutShowHide%, , Off
  ;; when key already exist
  HotKey, %Key%, , UseErrorLevel
  if ErrorLevel = 0
  {
    ;; enable new shortcut
    HotKey, %Key%, , On
  }
  else
  {
    ;; when it is not a nonexistent hotkey in the current script
    If ErrorLevel != 5
    {
      MsgBox, 0x10, %ApplicationName%: error, Error: Wrong shortcuts
    }
    else
    {
      ;; the shortcut do not already exist in the current script
    }
  }
  ;; set new shortcut
  HotKey, %Key%, ShowHide
  ;; set new shortcut and write in ini file
  ShortcutShowHide = %Key%
}
Return

;;
;;; determine the default value for offset
DefaultOffset(TType)
{
  ;; init variable
  AeroIsEnabled := 0
  ;; aero is enabled ?
  Aero := DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", AeroIsEnabled)
  ;; when dllcall success
  if (Aero == 0)
  {
    ;; Win 7 or Vista (dwmapi is known)

    ;; when aero is enabled
    if (AeroIsEnabled)
    {
      if TType = cmd
      {
        DefaultLeft   := 0
        DefaultTop    := 0
        DefaultBottom := 42
        DefaultRight  := 19
      }
      else
      {
        ;; rxvt or mintty
        DefaultLeft   := 0
        DefaultTop    := 0
        DefaultBottom := 42
        DefaultRight  := 19
      }
    }
    else
    {
       ;; aero is disabled

      if TType = cmd
      {
        DefaultLeft   := 0
        DefaultTop    := 0
        DefaultBottom := 40
        DefaultRight  := 20
      }
      {
        ;; rxvt or mintty
        DefaultLeft   := 0
        DefaultTop    := 0
        DefaultBottom := 0
        DefaultRight  := 0
      }
    }
  }
  else
  {
    ;; Win XP (Dwmapi is unknown)
    if TType = cmd
    {
      DefaultLeft   := 6
      DefaultTop    := 25
      DefaultBottom := 6
      DefaultRight  := 6
    }
    else
    {
      ;; rxvt or mintty
      DefaultLeft   := 0
      DefaultTop    := 0
      DefaultBottom := 0
      DefaultRight  := 0
    }
  }

  Return Array(DefaultLeft, DefaultTop, DefaultBottom, DefaultRight)
}

LoadIniFile:
  ;; type of terminal MS/cmd or Cygwin/rxvt
  IniRead, TerminalType,  %IniFile%, Terminal, TerminalType, cmd
  ;; title in terminal MS/cmd Cygwin/rxvt
  IniRead, TerminalTitle, %IniFile%, Terminal, TerminalTitle, QuahkeConsole
  ;;
  ;; percent size in X for the terminal window (%)
  IniRead, SizePercentX, %IniFile%, Size, SizePercentX, 100
  ;; percent size in Y for the terminal window (%)
  IniRead, SizePercentY, %IniFile%, Size, SizePercentY, 30
  ;;
  ;; font in terminal Cygwin/rxvt
  IniRead, TerminalFont,   %IniFile%, Font, TerminalFont, Courier-12
  ;; Character Size in X
  IniRead, CharacterSizeX, %IniFile%, Font, CharacterSizeX, 8
  ;; Character Size in Y
  IniRead, CharacterSizeY, %IniFile%, Font, CharacterSizeY, 12
  ;;
  ;; Transparence of terminal in percent (invisible (0) to full opaque (100))
  IniRead, TerminalAlpha,       %IniFile%, Display, TerminalAlpha, 80
  ;; always on top
  IniRead, TerminalAlwaysOnTop, %IniFile%, Display, TerminalAlwaysOnTop, True
  ;;
  ;; get default offset value
  OffsetArray := DefaultOffset(TerminalType)
  ;; offset to remove window decoration at left
  IniRead, OffsetLeft,   %IniFile%, Position, OffsetLeft, % OffsetArray[1]
  ;; offset to remove window decoration at top
  IniRead, OffsetTop,    %IniFile%, Position, OffsetTop, % OffsetArray[2]
  ;; offset to remove window decoration at bottom
  IniRead, OffsetBottom, %IniFile%, Position, OffsetBottom, % OffsetArray[3]
  ;; offset to remove window decoration at right
  IniRead, OffsetRight,  %IniFile%, Position, OffsetRight, % OffsetArray[4]
  ;;
  ;; time in ms of animation of hide/show console window
  IniRead, TerminalSlideTime, %IniFile%, Display, TerminalSlideTime, 500
  ;; time in ms of going to position in animation (Tau~63%, 3Tau~95%, 5Tau~99%)
  IniRead, TerminalSlideTau,  %IniFile%, Display, TerminalSlideTau, 80
  ;;
  ;; foreground color in terminal Cygwin/rxvt
  IniRead, TerminalForeground, %IniFile%, Display, TerminalForeground, white
  ;; background color in terminal Cygwin/rxvt
  IniRead, TerminalBackground, %IniFile%, Display, TerminalBackground, black
  ;;
  ;; shortcut for show/hide window console
  IniRead, ShortcutShowHide, %IniFile%, Misc, ShortcutShowHide, F1
  ;;
  ;; shell in terminal Cygwin/rxvt
  IniRead, TerminalShell,   %IniFile%, Misc, TerminalShell, bash
  ;; history size in terminal Cygwin/rxvt
  IniRead, TerminalHistory, %IniFile%, Misc, TerminalHistory, 5000
  ;; take default config from you config file (~/.minttyrc)
  IniRead, NoConfigMintty,  %IniFile%, Misc, NoConfigMintty, False
  ;; path of Cygwin (to run rxvt)
  IniRead, ExecPath,        %IniFile%, Misc, ExecPath, C:\cygwin\bin
Return

;;
;;; Edit a ini file
MenuEditIni:
  ;; Launch default editor maximized.
  Run, %IniFile%, , Max UseErrorLevel
  ;; when error to launch
  if ErrorLevel = ERROR
    MsgBox, 0x10, %ApplicationName%, cannot access %IniFile%: No such file or directory.`n(Use before "Create/Save .ini file")
Return

;;
;;; Save all settings in a ini file
MenuCreateSaveIni:
  ;; Section Terminal
  IniWrite, %TerminalType%,  %IniFile%, Terminal, TerminalType
  IniWrite, %TerminalTitle%, %IniFile%, Terminal, TerminalTitle
  ;; Section Size
  IniWrite, %SizePercentX%, %IniFile%, Size, SizePercentX
  IniWrite, %SizePercentY%, %IniFile%, Size, SizePercentY
  ;; Section Font
  IniWrite, %TerminalFont%,   %IniFile%, Font, TerminalFont
  IniWrite, %CharacterSizeX%, %IniFile%, Font, CharacterSizeX
  IniWrite, %CharacterSizeY%, %IniFile%, Font, CharacterSizeY
  ;; Section Display
  IniWrite, %TerminalAlpha%,       %IniFile%, Display, TerminalAlpha
  IniWrite, %TerminalAlwaysOnTop%, %IniFile%, Display, TerminalAlwaysOnTop
  ;; Section Position
  IniWrite, %OffsetLeft%,   %IniFile%, Position, OffsetLeft
  IniWrite, %OffsetTop%,    %IniFile%, Position, OffsetTop
  IniWrite, %OffsetBottom%, %IniFile%, Position, OffsetBottom
  IniWrite, %OffsetRight%,  %IniFile%, Position, OffsetRight
  ;; Section Display
  IniWrite, %TerminalSlideTime%,   %IniFile%, Display, TerminalSlideTime
  IniWrite, %TerminalSlideTau%,    %IniFile%, Display, TerminalSlideTau
  IniWrite, %TerminalForeground%,  %IniFile%, Display, TerminalForeground
  IniWrite, %TerminalBackground%,  %IniFile%, Display, TerminalBackground
  ;; Section Misc
  IniWrite, %ShortcutShowHide%,               %IniFile%, Misc, ShortcutShowHide
  IniWrite, %TerminalShell%,                  %IniFile%, Misc, TerminalShell
  IniWrite, %TerminalHistory%,                %IniFile%, Misc, TerminalHistory
  IniWrite, %NoConfigMintty%,                 %IniFile%, Misc, NoConfigMintty
  IniWrite, %ExecPath%,                       %IniFile%, Misc, ExecPath
  ;;
  ;; display a traytip to indicate file save
  TrayTip, %ApplicationName%, %IniFile% file saved., 5, 1
Return
