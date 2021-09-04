#include <AutoItConstants.au3>
;~ #include <WinAPIGdi.au3>
;~ #include <WinAPIGdiDC.au3>
;~ #include <WinAPIHObj.au3>
;~ #include <WinAPISysWin.au3>
;~ #include <WindowsConstants.au3>

#include <const.au3>
#include <generateInput.au3>

global $exclaimationX
global $exclaimationY
global $rodPosition

func getInput()
    _log('Reading exclaimation position')
    if FileExists($inputPath) then
        $exclaimationX = IniRead($inputPath, "Exclaimation Mark", "exclaimationX", "")
        $exclaimationY = IniRead($inputPath, "Exclaimation Mark", "exclaimationY", "")
        $rodPosition = IniRead($inputPath, "General", "RodPosition", 1)
        $minimumIdleRod = IniRead($inputPath, "General", "MinimumIdleRod", 13)
        $maximumTimeFishing = IniRead($inputPath, "General", "MaximumTimeFishing", 60)
    else
        _log('Capturing exclaimation position')
        generateInput()
        getInput()
    endif
endfunc

func getCurrentExclaimationColor()
    return PixelGetColor($exclaimationX, $exclaimationY)
EndFunc

func alert($msg)
    MsgBox($MB_SYSTEMMODAL, "Alert", $msg)
EndFunc

;~ $hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
;~ $hPen = _WinAPI_CreatePen($PS_SOLID, 5, 0)
;~ $o_Orig = _WinAPI_SelectObject($hDC, $hPen)

func drawCross()
    $length=30
    _WinAPI_DrawLine($hDC, $exclaimationX - $length/2, $exclaimationY, $exclaimationX + $length/2, $exclaimationY)
    _WinAPI_DrawLine($hDC, $exclaimationX, $exclaimationY - $length/2, $exclaimationX, $exclaimationY + $length/2)
    _WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0)
    _WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_ERASE)
    _WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN)

EndFunc

#region Button clicking
func click($x, $y, $clicks = 1, $speed = 100, $clickspeed = 2)
    MouseClick ($MOUSE_CLICK_LEFT, $x, $y, $clicks, $clickspeed)
    sleep($speed)
EndFunc

func clickUseRod()
    click($buttonUseRodX, $buttonUseRodY, 1, 200)
EndFunc

func clickWithdrawRod()
    click($buttonWithdrawRodX, $buttonWithdrawRodY, 10, 10, 0)
EndFunc

func clickOpenBag()
    click($buttonOpenBagX, $buttonOpenBagY, 1, 0) ;100 trở lên thì sleep vô tận cmnl, wtf?
EndFunc

func clickTabTool()
    click($buttonTabTool1X, $buttonTabTool1Y, 1, 200)
EndFunc

func clickCloseBag()
    click($buttonCloseBag3X, $buttonCloseBag3Y, 1, 200)
EndFunc

func clickStoreFish()
    click($buttonStoreFishX, $buttonStoreFishY, 1, 200)
EndFunc

func clickStoreTrash()
    click($buttonStoreTrashX, $buttonStoreTrashY, 1, 200)
EndFunc

func clickSelectRod()
    click($bagItemX[$rodPosition - 1] * $screenscale, $bagItemY[$rodPosition - 1] * $screenscale, 1, 200)
EndFunc
#endregion

#region Detecting
func isOpenBagButtonShown()
    return PixelGetColor($buttonOpenBagX, $buttonOpenBagY) == $buttonOpenBagColor
EndFunc

func isBagOpened()
    return not isOpenBagButtonShown() _
            And isCloseBagButtonShown() _
            And PixelGetColor($bagOpenedX, $bagOpenedY) == $bagOpenedColor
EndFunc

func isTabToolNotSelected()
    return isBagOpened() _
            And PixelGetColor($buttonTabTool1X, $buttonTabTool1Y) == $buttonTabTool1Color _
            And PixelGetColor($buttonTabTool2X, $buttonTabTool2Y) == $buttonTabTool2Color _
            And PixelGetColor($buttonTabTool3X, $buttonTabTool3Y) <> $buttonTabTool3Color
EndFunc

func isCloseBagButtonShown()
    return PixelGetColor($buttonCloseBag1X, $buttonCloseBag1Y) == $buttonCloseBag1Color _
        And PixelGetColor($buttonCloseBag2X, $buttonCloseBag2Y) == $buttonCloseBag2Color
EndFunc

func isStoreFishButtonShown()
    return PixelGetColor($buttonStoreFishX, $buttonStoreFishY) == $buttonStoreFishColor
EndFunc

func isStoreTrashButtonShown()
    return PixelGetColor($buttonStoreTrashX, $buttonStoreTrashY) == $buttonStoreTrashColor
EndFunc

func rodCheckMarkExits()
    return PixelGetColor($rodCheckMarkX[$rodPosition - 1] * $screenscale, $rodCheckMarkY[$rodPosition - 1] * $screenscale) == $rodCheckMarkColor
endfunc
#endregion

#region complex select
func doBagStuff()
    _log('Doing bag stuff')
    while isTabToolNotSelected()
        _log('Clicking tab tool')
        clickTabTool()
    wend

    while isBagOpened() and not isOpenBagButtonShown()
        if rodCheckMarkExits() then
            _log('Clicking close bag')
            clickCloseBag()
        Else
            _log('Clicking select rod')
            clickSelectRod()
        endif
    wend
    Sleep(200)
endfunc

#endregion