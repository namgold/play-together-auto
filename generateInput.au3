#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIMisc.au3>

#include <const.au3>
_Singleton ('PlayTogetherAuto_generate_input', 0)
AutoItSetOption('GUIOnEventMode', 1)

local $X1 = 0
local $Y1 = 0
local $X2 = 0
local $Y2 = 0
local $labelUpdated = false
local $isdone = false
local $isexit = false

func genLabel()
    return 'Current position:'                      & @CRLF & _
           'X = ' & $X1                             & @CRLF & _
           'Y = ' & $Y1                             & @CRLF & _
                                                      @CRLF & _
           "Press F2 to capture current position:"  & @CRLF & _
           "X = " & $X2                             & @CRLF & _
           "Y = " & $Y2
endfunc

func Capture()
    $X2 = $X1
    $Y2 = $Y1
    $labelUpdated = true
EndFunc

Func _Cancel()
    $isexit = true
EndFunc

Func _Generate()
    IniWrite($inputPath, "Exclaimation Mark", "exclaimationX", $X2)
    IniWrite($inputPath, "Exclaimation Mark", "exclaimationY", $Y2)

    $rodPosition = IniRead($inputPath, "General", "RodPosition", 1)
    $minimumIdleRod = IniRead($inputPath, "General", "MinimumIdleRod", 13)
    $maximumTimeFishing = IniRead($inputPath, "General", "MaximumTimeFishing", 60)
    IniWrite($inputPath, "General", "RodPosition", $rodPosition)
    IniWrite($inputPath, "General", "MinimumIdleRod", $minimumIdleRod)
    IniWrite($inputPath, "General", "MaximumTimeFishing", $maximumTimeFishing)
    $isdone = true
EndFunc

func generateInput()
    local const $Form1 = GUICreate("Capture ! position", 280, 208)
    local const $Label1 = GUICtrlCreateLabel(genLabel(), 12, 12, 255, 150)
    GUICtrlSetFont($Label1, 12)
    GUISetOnEvent($GUI_EVENT_CLOSE, "_Cancel", $Form1)


    local const $ButtonGenerate = GUICtrlCreateButton("Save settings", 48, 168, 80, 25)
    local const $ButtonCancel = GUICtrlCreateButton("Cancel", 144, 168, 75, 25)
    GUICtrlSetOnEvent($ButtonGenerate, '_Generate')
    GUICtrlSetOnEvent($ButtonCancel, '_Cancel')
    HotKeySet("{F2}", "Capture")

    GUISetState(@SW_SHOW)

    While not $isdone and not $isexit
        $mousepos = _WinAPI_GetMousePos()
        $X1_new = DllStructGetData($mousepos, "X")
        $Y1_new = DllStructGetData($mousepos, "Y")
        if $X1_new <> $X1 or $Y1_new <> $Y1 then
            $X1 = $X1_new
            $Y1 = $Y1_new
            $labelUpdated = true
        endif
        if $labelUpdated then
            GUICtrlSetData($Label1, genLabel())
            $labelUpdated = false
        endif
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                isexit = true

        EndSwitch
        ;~ GUICtrlSetData($Label1, 'a')
    WEnd
    GUIDelete($Form1)
    if $isexit then exit
EndFunc

