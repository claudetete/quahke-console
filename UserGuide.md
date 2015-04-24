# Presentation #
  * QuahkeConsole manage console window in MS Windows to have quake style with your favorite console.
  * It use your current console (cmd, rxvt or mintty), it is not a new terminal emulator for MS Windows.

# Installation #
  * Download the latest version of QuahkeConsole http://code.google.com/p/quahke-console/downloads/list
  * Unzip

# Use #
  * Run QuahkeConsole.exe and start with F1 shortcut (can be modified)
  * a new icon is placed in system tray
  * right click to show the menu
```
  About
  Options
  Reload .ini file
  Edit .ini file
  Create/Save .ini file
  Suspend Hotkeys
  Pause Script
  Exit
```
  * Of course if you want use rxvt you have to install [Cygwin](http://www.cygwin.com) with the package rxvt (example of settings in [UserGuide#rxvt](UserGuide#rxvt.md)), same for mintty.

# Configuration #
  * Create the .ini file (default value are for Windows XP, cmd and 8x12 font) and edit it.
> OR
  * Use the Options GUI in menu

### Section Position ###
| **Name** | **About** | **Default** |
|:---------|:----------|:------------|
| OffsetLeft | Offset to hide console window decoration by the left | depends upon OS and console Type |
| OffsetRight | Offset to hide console window decoration by the right | depends upon OS and console Type |
| OffsetTop | Offset to hide console window decoration by the top | depends upon OS and console Type |
| OffsetBottom | Offset to hide console window decoration by the bottom | depends upon OS and console Type |

### Section Size ###
| **Name** | **About** | **Default** |
|:---------|:----------|:------------|
| SizePercentX | Width of the console in percent of screen | _100_ |
| SizePercentY | Height of the console in percent of screen | _30_ |

### Section Font ###
| **Name** | **About** | **Default** |
|:---------|:----------|:------------|
| TerminalFont | Font to be used in the console (only rxvt or mintty) | _Courier-12_ |
| CharacterSizeX | Font width used in the console (in pixels) | _8_ |
| CharacterSizeY | Font height used in the console (in pixels) _1 pixels is added about between line_ | _12_ |

### Section Terminal ###
| **Name** | **About** | **Default** |
|:---------|:----------|:------------|
| **TerminalType** | Type of terminal you want, only **rxvt** or **cmd** or **mintty** | _cmd_ |
| TerminalTitle | Title of the console window | _QuahkeConsole_ |

### Section Display ###
| **Name** | **About** | **Default** |
|:---------|:----------|:------------|
| TerminalAlpha | Value of the transparency of the console window in percent (only rxvt) | _80_ |
| TerminalForeground | Color of the foreground of the terminal (only rxvt) | _white_ |
| TerminalBackground | Color of the background of the terminal (only rxvt) | _black_ |
| TerminalSlideTime | Time to show or hide the console window (in ms) | _500_ |
| TerminalSlideTau | Constant time to configure the animation (first order filter) (in ms (~ SlideTime / 5)) | _80_ |
| TerminalAlwaysOnTop | Boolean to set console window always on top or not | _True_ |

### Section Misc ###
| **Name** | **About** | **Default** |
|:---------|:----------|:------------|
| TerminalShell | Shell you want used in the terminal window (only rxvt) | _bash_ |
| TerminalHistory | Number of lines to be keep in memory (only rxvt) | _5000_ |
| ExecPath | Path of the executable (only rxvt) | _C:\cygwin\bin_ |
| NoConfigMintty | Take mintty configuration from your .minttyrc and not from QuahkeConsole.ini | False |

# rxvt #
Example of settings for rxvt in Win XP:
  * In the QuahkeConsole.ini file:
```
[Position]
OffsetTop=0
OffsetLeft=0
OffsetRight=0
OffsetBottom=0
[Size]
SizePercentX=100
SizePercentY=20
[Font]
TerminalFont=ProggyTinySZ-6
CharacterSizeX=6
CharacterSizeY=9
[Terminal]
TerminalType=rxvt
TerminalTitle=QuahkeConsole
[Display]
TerminalAlpha=80
TerminalForeground=white
TerminalBackground=black
TerminalSlideTime=100
TerminalSlideTau=30
TerminalAlwaysOnTop=True
[Misc]
TerminalShell=zsh
TerminalHistory=10000
ExecPath=D:\cygwin\bin
NoConfigMintty=False
```
  * In the .Xdefaults file from the cygwin home:
```
  Rxvt*background:   #000000
  Rxvt*foreground:   #ffffff
  Rxvt*cursorColor:  #d8d8d8
  Rxvt*colorBD:      lightyellow
  Rxvt*colorUL:      yellow
  Rxvt*reverseVideo: false
  Rxvt*scrollBar:    false
  Rxvt*keysym.Home:  \033[1~
  Rxvt*keysym.End:   \033[4~
  rxvt*loginShell:   true
  Rxvt*tintColor:    #dfdfdf
  !! black
  Rxvt*color0:       #676767
  Rxvt*color8:       #757575
  !! red
  Rxvt*color1:       #EA6868
  Rxvt*color9:       #FF7272
  !! green
  Rxvt*color2:       #ABCB8D
  Rxvt*color10:      #AFD78A
  !! yellow
  !Rxvt*color3:       #E8AE5B
  Rxvt*color11:      #FFA75D
  !! blue
  Rxvt*color4:       #71C5F4
  Rxvt*color12:      #67CDE9
  !! magenta
  Rxvt*color5:       #E2BAF1
  Rxvt*color13:      #ECAEE9
  !! cyan
  Rxvt*color6:       #21F1EA
  Rxvt*color14:      #36FFFC
  !! white
  Rxvt*color7:       #F1F1F1
  Rxvt*color15:      #FFFFFF
```
### Window Title ###
  * In you shell you do not must change window title (it is use by QuahkeConsole to recognize the console window)
  * If you want to use bash you can put this in your _.bashrc_
```
echo -ne "\e]2;QuahkeConsole\a\e]1;\a"
```
  * If you want to use zsh you can put this in your _.zshrc_
```
print -Pn "\e]0;QuahkeConsole\a"
```
  * QuahkeConsole should be **TerminalTitle** value from ini file.


# mintty #
  * To use your configuration file (_.minttyrc_) set **NoConfigMintty** to **True** in **Misc** section but, the alpha and font setting in QuahkeConsole.ini will be not considered.