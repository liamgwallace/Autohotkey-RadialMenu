
;;N.B. this program is designed to have multiple instances of itself running.
;;     If you run the exe with no additional parameters it sits idle and waits for the hotkey
;;     When you press the hotkey it loads the same exe file again. But this time with an additional parameter
;;     This parameter is the name of an ini file to be used as the menu list
;;
;;     This only works with compiled scripts
;;
;;     Reflecting on this, I could have done this differently and not need to open multiple instances of the same file
;;     Perhaps I will change this.
;;
;;     Also there is no handling of errors or unforseen circumstances yet. The user will get lots of error messages when something doesnt work as expected

;;##################################################
;;############### SOME SETTINGS ##################
;;##################################################
#SingleInstance OFF ;FORCE replaces the old instance - IGNORE leaves old instance running - OFF multiple instances

;;set some defaults and stuff
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;##################################################
;;############## BEGIN THE PROGRAM #################
;;##################################################

iniHKPath=%A_ScriptDir%\Hotkey.ini                         ;I should be checking if this path exists
IniRead, myHotkey, %iniHKPath%, Main , Hotkey              ;read the first ini file for settings
if 0 < 1                                                   ;If the script has been passed no arguments we are opening the first menu
{                                                          ;the register '0' holds the number of arguments passed when the script is executed
    IniRead, myDuration, %iniHKPath%, Main , Duration      ;read some ini settings
    IniRead, myFirstMenu, %iniHKPath%, Main , FirstMenu
    HotKey, %myHotkey%, RunFirstMenu                       ;activate the menu hotkey and bind it to the RunFirstMenu procedure
    HotKey, %myHotkey%, On
    return                                                 ;stop running script and wait for a hotkey
}
HotKey, %myHotkey%, myQuit                                 ;we have been passed some parameters so bind the hotkey to myQuit procedure
HotKey, %myHotkey%, On                                     ;this is because if a menu is up and we press the hotkey we want the first menu to go away

iniName=%1%                                                ;the first and only parameter when running the script is the menu ini name
iniPath=%A_ScriptDir%\%iniName%

Gosub GetData                                              ;read the ini file for data
Gosub DrawMenu                                             ;draw the menu with that data
return                                                     ;stop running script and wait for a hotkey (menu click)

;;##################################################
;;############ BEGINNING OF ROUTINES ###############
;;##################################################

RunFirstMenu:                                              ;Launches first menu when hotkey is pressed
  Path = %A_ScriptDir%\%A_ScriptName% %myFirstMenu%        ;run the exe file with an additional parameter myFirstMenu
  Run, %Path%
return

myQuit:                                                    ;simple routine to exit script, it will be needed to kill all the gui stuff when that is working
  HotKey, %myHotkey%, Off
  exitapp
return 

GetItemClicked(myTitle)                                    ;function to return an index number of the option clicked - can be used if we have multiple windows later
{
  IfWinNotActive, %myTitle%
  {
      ToolTip
      Return 0                                             ;return 0 if we clicked elsewhere
  }
  MouseGetPos, mX, mY
  ToolTip
  mY -= 4                                                  ;space after which first line starts
  mY /= 15                                                 ;space taken by each line - this is a bit broken, it will need to be tweaked for different peoples computers
  return mY
}

MenuClick:                                                 ;routine that runs a path the user selected
  ItemIndex:=GetItemClicked(Title)
  IfLess, ItemIndex, 1, gosub myQuit                       ;quit if we clicked the title
  IfLess, ListLength,%ItemIndex% , gosub myQuit            ;quit if we clicked off the botom
  SelectedPath:=Path%ItemIndex%                            ;set the path we want to execute
  Run, %SelectedPath%                                      ;run it
  gosub myQuit                                             ;quit this instance of the program
return

DrawMenu:                                                  ;draw the gui - more shit to go here later
  Menu=%Title%
  Count:=1
  
  Loop %ListLength%
  {
    StringTrimLeft, MenuText, Text%Count%, 0              ;Autohotkey doesnt have arrays, this is a method of reading an array element to another variable
    Menu = %Menu%`n%MenuText%
    Count+=1  
  }
  MouseGetPos, Origin_X, Origin_Y
  Origin_X-=40
  Origin_Y-=25
  ToolTip, %Menu%, %Origin_X%, %Origin_Y%
  WinActivate, %Title%
  
  HotKey, ~LButton, MenuClick                              ;bind the left click to MenuClick routine
  HotKey, ~LButton, On
return

GetData:                                                   ;routine to read the menu ini file for data. N.B.Autohotkey is bad at handling arrays
  IniRead, ListLength, %iniPath%, Main , ListLength
  IniRead, Title, %iniPath%, Main , Title

  Count:=0
  Loop %ListLength%
  {
    Count+=1 
    IniRead, Text%Count%, %iniPath%, Main , Text%Count%         ;read the ini data to Text{i}
    IniRead, Path%Count%, %iniPath%, Main , Path%Count%         ;read the ini data to Path{i}
    StringLeft, tmpLeft, Path%Count%, 1                         ;get the leftmost character of Path
    if tmpLeft = #                                              ;if the left character is a # we have the filename of an ini file
    {
      StringTrimLeft, newiniPath, Path%Count%, 1                ;remove the # character
      Path%Count% = %A_ScriptDir%\%A_ScriptName% %newiniPath%   ;give it the full ini path
    }
  } 
return