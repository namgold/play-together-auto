#include <AutoItConstants.au3>
;~ #include <WinAPIGdi.au3>
;~ #include <WinAPIGdiDC.au3>
;~ #include <WinAPIHObj.au3>
;~ #include <WinAPISysWin.au3>
;~ #include <WindowsConstants.au3>

#include-once <const.au3>
#include <generateInput.au3>

global $exclaimationX = 0
global $exclaimationY = 0
global $rodPosition = 1
global $minimumIdleRod = 13
global $maximumTimeFishing = 60

local $deep = 0
func getInput()
    $deep = $deep + 1
    _log('Starting get input with deep' & $deep)
    if $deep > 10 Then
        _log('Deep is too high: ' & $deep)
        alert('Something went wrong, please try again.')
        _log('Exting program')
        Exit
    endif
    _log('Checking is input file exists')
    if FileExists($inputPath) then
        _log('Input file found, reading')
        $exclaimationX = IniRead($inputPath, "Exclaimation Mark", "exclaimationX", 0)
        $exclaimationY = IniRead($inputPath, "Exclaimation Mark", "exclaimationY", 0)
        $rodPosition = IniRead($inputPath, "General", "RodPosition", 1)
        $minimumIdleRod = IniRead($inputPath, "General", "MinimumIdleRod", 13)
        $maximumTimeFishing = IniRead($inputPath, "General", "MaximumTimeFishing", 60)
        _log('Read done')
    else
        _log('Input file not found, creating new one')
        _log('Capturing exclaimation position')
        generateInput()
        _log('Created input file, now read again')
        getInput()
    endif
    _log('Exit get input')
endfunc

func getCurrentExclaimationColor()
    return PixelGetColor($exclaimationX, $exclaimationY)
EndFunc

func alert($msg)
    MsgBox($MB_SYSTEMMODAL, "Alert", $msg)
EndFunc

func pick($arrayPos)
    return $arrayPos[$rodPosition - 1] * $screenscale
endfunc

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
global $timeStartClicked = TimerInit()
func clickDebounced($x, $y, $clicks = 1, $speed = 100, $clickspeed = 2)
    if TimerDiff($timeStartClicked) > $speed then
        $timeStartClicked = TimerInit()
        MouseClick($MOUSE_CLICK_LEFT, $x, $y, $clicks, $clickspeed)
    endif
EndFunc

global $nox = WinGetHandle('Bộ giả lập android Nox')
if @error <> 0 then
    $nox = false
endif

func click($x, $y, $clicks = 1, $speed = 100)
    if $nox then
        ControlClick($nox, '', $nox, 'left', $clicks, $x, $y)
    else
        MouseClick ($MOUSE_CLICK_LEFT, $x, $y, $clicks, 2)
    endif
    sleep($speed)
EndFunc

func clickUseRod()
    click($buttonUseRodX, $buttonUseRodY, 1, 200)
EndFunc

func clickWithdrawRod()
    click($buttonWithdrawRodX, $buttonWithdrawRodY, 10, 10)
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

func clickFixRod()
    clickDebounced(pick($buttonFixRodX), pick($buttonFixRodY), 1, 2000)
EndFunc

func clickPayMoneyFixRod()
    click($buttonPayMoneyFixRodX, $buttonPayMoneyFixRodY, 1, 200)
EndFunc

func clickFixedRod()
    click($buttonFixedRodX, $buttonFixedRodY, 1, 200)
EndFunc

func clickSelectRod()
    click(pick($bagItemX), pick($bagItemY), 1, 200)
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
    return PixelGetColor(pick($rodCheckMarkX), pick($rodCheckMarkY)) == $rodCheckMarkColor
endfunc

func isRodNeedFix()
    return PixelGetColor(pick($buttonFixRodX), pick($buttonFixRodY)) == $buttonFixRodColor
EndFunc

func isButtonPayMoneyFixRodShown()
    return PixelGetColor($buttonPayMoneyFixRodX, $buttonPayMoneyFixRodY) == $buttonPayMoneyFixRodColor
EndFunc

func isButtonFixedRodShown()
    return PixelGetColor($buttonFixedRodX, $buttonFixedRodY) == $buttonFixedRodColor
EndFunc
#endregion

#region complex select
func doBagStuff()
    _log('Start doing bag stuff')
    while isTabToolNotSelected()
        _log('Clicking tab tool')
        clickTabTool()
    wend
    _log('Tab tool opened')

    _log('Detecting is rod need fix')
    sleep(200)
    if isRodNeedFix() Then
        _log('Start fixing rod')

        _log('Clicking fix rod')
        while not isButtonPayMoneyFixRodShown()
            clickFixRod()
        wend
        _log('Clicking pay money')
        while isButtonPayMoneyFixRodShown()
            clickPayMoneyFixRod()
        wend
        _log('Waiting for success show')
        while not isButtonFixedRodShown()
        wend
        _log('Click success')
        while isButtonFixedRodShown()
            clickFixedRod()
        wend

    endif

    _log('Close/select until bag is closed and button open bag shown')
    while isBagOpened() and not isOpenBagButtonShown()
        if rodCheckMarkExits() then
            _log('Clicking close bag')
            clickCloseBag()
        Else
            _log('Clicking select rod')
            clickSelectRod()
        endif
    wend
    _log('End doing bag stuff')
    Sleep(200)
endfunc

#endregion