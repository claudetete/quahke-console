#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;;------------------------------------------------------------------------------
;; !!! NEED TO BE CHANGED FOR TESTS !!!
;;------------------------------------------------------------------------------
TExecPath = D:\cygwin\bin
TShell = zsh

TestCMD    = True
TestRXVT   = True
TestMinTTY = True

;;------------------------------------------------------------------------------
;; !!! END NEED TO BE CHANGED FOR TESTS !!!
;;------------------------------------------------------------------------------

;; get the size of the current monitor (without taskbar)
ScreenWidth := A_ScreenWidth
SysGet, ScreenHeight, 62

;; useful for win7 cmd
SetTitleMatchMode, 2

MainTitle = Test QuahkeConsole

;;------------------------------------------------------------------------------
;; Test CMD
;;------------------------------------------------------------------------------
if TestCMD = True
{
  TConsole = cmd
  MsgBox, 0, %MainTitle%, TEST for %TConsole%.`n`n(Timeout at 60s for each test case), 60

  TFontSize = 8x12
  MsgBox, 0, %MainTitle%, Set (default) %TFontSize% font in %TConsole%, 60
  RunTestCase("Test_0001", 100, 50, 500, 100, "NotUsed")
  RunTestCase("Test_0002", 80, 20, 100, 100, "NotUsed")
  RunTestCase("Test_0003", 50, 70, 1000, 100, "NotUsed")
  RunTestCase("Test_0003", 95, 95, 300, 100, "NotUsed")

  TFontSize = 6x8
  MsgBox, 0, %MainTitle%, Set (default) %TFontSize% font in %TConsole%, 60
  RunTestCase("Test_0011", 100, 50, 500, 100, "NotUsed")
  RunTestCase("Test_0012", 80, 20, 100, 100, "NotUsed")
  RunTestCase("Test_0013", 50, 70, 1000, 100, "NotUsed")
  RunTestCase("Test_0013", 95, 95, 300, 100, "NotUsed")
}

;;------------------------------------------------------------------------------
;; Test RXVT
;;------------------------------------------------------------------------------
if TestRXVT = True
{
  TConsole = rxvt
  MsgBox, 0, %MainTitle%, TEST for %TConsole%.`n`n(Timeout at 60s for each test case), 60

  TFontSize = 8x13
  RunTestCase("Test_0101", 100, 50, 500, 80, "Courier-12")
  RunTestCase("Test_0102", 60, 20, 100, 50, "Courier-12")
  RunTestCase("Test_0103", 30, 70, 1000, 20, "Courier-12")
  RunTestCase("Test_0104", 95, 95, 1000, 75, "Courier-12")

  TFontSize = 6x8
  RunTestCase("Test_0111", 100, 50, 500, 80, "Terminal-8")
  RunTestCase("Test_0112", 60, 20, 100, 50, "Terminal-8")
  RunTestCase("Test_0113", 30, 70, 1000, 20, "Terminal-8")
  RunTestCase("Test_0114", 95, 95, 300, 75, "Terminal-8")

  TFontSize = 6x10
  RunTestCase("Test_0121", 100, 50, 500, 80, "ProggyTinySZ-6")
  RunTestCase("Test_0122", 60, 20, 100, 50, "ProggyTinySZ-6")
  RunTestCase("Test_0123", 30, 70, 1000, 20, "ProggyTinySZ-6")
  RunTestCase("Test_0124", 95, 95, 300, 75, "ProggyTinySZ-6")
}

;;------------------------------------------------------------------------------
;; Test MINTTY
;;------------------------------------------------------------------------------
if TestMinTTY = True
{
  TConsole = mintty
  MsgBox, 0, %MainTitle%, TEST for %TConsole%.`n`n(Timeout at 60s for each test case), 60

  TFontSize = 8x13
  RunTestCase("Test_0201", 100, 50, 500, 100, "Lucida Console-10")
  RunTestCase("Test_0202", 60, 20, 100, 98, "Lucida Console-10")
  RunTestCase("Test_0203", 30, 70, 1000, 96, "Lucida Console-10")
  RunTestCase("Test_0204", 95, 95, 300, 94, "Lucida Console-10")

  TFontSize = 6x8
  RunTestCase("Test_0211", 100, 50, 500, 100, "Terminal-8")
  RunTestCase("Test_0212", 60, 20, 100, 98, "Terminal-8")
  RunTestCase("Test_0213", 30, 70, 1000, 96, "Terminal-8")
  RunTestCase("Test_0214", 95, 95, 300, 94, "Terminal-8")

  TFontSize = 6x10
  RunTestCase("Test_0221", 100, 50, 500, 100, "ProggyTinySZ-6")
  RunTestCase("Test_0222", 60, 20, 100, 98, "ProggyTinySZ-6")
  RunTestCase("Test_0223", 30, 70, 1000, 96, "ProggyTinySZ-6")
  RunTestCase("Test_0224", 95, 95, 300, 94, "ProggyTinySZ-6")
}


MsgBox, 0, %MainTitle%, All Tests passed., 60

exit


;;------------------------------------------------------------------------------
;; Sub Function
;;------------------------------------------------------------------------------
;
;;
;;; run a test case
RunTestCase(TestText, TWidth, THeight, TTime, TAlpha, TFont)
{
  global TFontSize, TConsole, ScreenWidth, ScreenHeight, MainTitle

  ;; prepare setting file
  CopySettingFile(TWidth, THeight, TTime, TAlpha, TFont)
  ;; run script to test
  Run, "C:\Program Files\AutoHotkey\AutoHotkey.exe" "..\QuahkeConsole.ahk", , , ScriptPID
  Sleep, 500
  ;; open the console window
  SendInput, {F1}
  Sleep, 1500
  WinWait, QuahkeConsole
  ;; display message for the tester
  MsgBox, 3, %MainTitle%, %TestText%:`nA Window of %TConsole% with width of %TWidth%`% and height of %THeight%`% show in %TTime% ms and transparency of %TAlpha%`%?, 60
  ;; close console window
  WinClose, QuahkeConsole
  WinClose, ahk_pid %ScriptPID%
  ;; when Cancel or No, it will exit the test script
  IfMsgBox, No
  {
     exit, 1
  }
  IfMsgBox, Cancel
  {
     exit, 2
  }
}
Return

;
;;
;;; set ini file with all settings
CopySettingFile(TWidth, THeight, TTime, TAlpha, TFont)
{
  global TFontSize, TConsole, TExecPath, TShell
  ;;
  ;; get size from NxN
  StringSplit, TFontSizes, TFontSize, x
  ;;
  ;; compute tau
  TTau := Round(TTime / 5, 0)

  ;; get size of window decoration
  if TConsole = cmd
  {
    if A_OSVersion in WIN_7,WIN_VISTA
    {
      TOffsetTop    := 0
      TOffsetLeft   := 0
      TOffsetRight  := 19
      TOffsetBottom := 42
    }
    else
    {
      TOffsetTop    := 25
      TOffsetLeft   := 6
      TOffsetRight  := 6
      TOffsetBottom := 6
    }
  }
  else if TConsole = rxvt
  {
    if A_OSVersion in WIN_7,WIN_VISTA
    {
      TOffsetTop    := 0
      TOffsetLeft   := 0
      TOffsetRight  := 19
      TOffsetBottom := 40
    }
    else
    {
      TOffsetTop    := 0
      TOffsetLeft   := 0
      TOffsetRight  := 0
      TOffsetBottom := 0
    }
  }
  else if TConsole = mintty
  {
    TOffsetTop    := 0
    TOffsetLeft   := 0
    TOffsetRight  := 0
    TOffsetBottom := 0
  }
  else
  {
    TOffsetTop    := 0
    TOffsetLeft   := 0
    TOffsetRight  := 0
    TOffsetBottom := 0
  }

  ;; remove old setting file
  FileDelete, ..\QuahkeConsole.ini
  ;; write new file
  FileAppend,
( ;; file start here...
[Position]
OffsetTop=%TOffsetTop%
OffsetLeft=%TOffsetLeft%
OffsetRight=%TOffsetRight%
OffsetBottom=%TOffsetBottom%
[Size]
SizePercentX=%TWidth%
SizePercentY=%THeight%
[Font]
TerminalFont=%TFont%
CharacterSizeX=%TFontSizes1%
CharacterSizeY=%TFontSizes2%
[Terminal]
TerminalType=%TConsole%
TerminalTitle=QuahkeConsole
[Display]
TerminalAlpha=%TAlpha%
TerminalForeground=white
TerminalBackground=black
TerminalSlideTime=%TTime%
TerminalSlideTau=%TTau%
TerminalAlwaysOnTop=False
[Misc]
TerminalShell=%TShell%
TerminalHistory=10000
ExecPath=%TExecPath%
), ..\QuahkeConsole.ini ;; ...and end here
}
Return
