#include <AutoItConstants.au3>
;~ #include <WinAPIGdi.au3>
;~ #include <WinAPIGdiDC.au3>
;~ #include <WinAPIHObj.au3>
;~ #include <WinAPISysWin.au3>
;~ #include <WindowsConstants.au3>

#include-once <const.au3>
#include <generateInput.au3>

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

func autoTrue()
    return true
endfunc

func doNotThing()
endfunc

func LoopOn($condition = autoTrue, $body = doNotThing, $logTitle = '', $timeout = 5, $beginLoopTime = TimerInit())
    if StringLen ($logTitle) > 0 then
        _log($logTitle & ': ' & $timeout & 's')
    endif
    local $currentTimerDiff = TimerDiff($beginLoopTime)
    while $condition() and $currentTimerDiff < $timeout * 1000
        if StringLen ($logTitle) > 0 then
            _log($logTitle & ': ' & Round($currentTimerDiff/100)/10 & '/' & $timeout & 's', false)
        endif
        $body()
        $currentTimerDiff = TimerDiff($beginLoopTime)
    wend
endfunc

func LoopOnNot($condition = autoTrue, $body = doNotThing, $logTitle = '', $timeout = 5, $beginLoopTime = TimerInit())
    if StringLen ($logTitle) > 0 then
        _log($logTitle & ': ' & $timeout & 's')
    endif
    local $currentTimerDiff = TimerDiff($beginLoopTime)
    while not $condition() and $currentTimerDiff < $timeout * 1000
        if StringLen ($logTitle) > 0 then
            _log($logTitle & ': ' & Round($currentTimerDiff/100)/10 & '/' & $timeout & 's', false)
        endif
        $body()
        $currentTimerDiff = TimerDiff($beginLoopTime)
    wend
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

func rgb($dec)
    local $result = [Floor($dec/65536), Floor(Mod($dec, 65536)/256), Mod($dec, 256)]
    return $result
endfunc

func isRGBNear($dec1, $dec2)
    local $rgb1 = rgb($dec1)
    local $rgb2 = rgb($dec2)
    return Abs($rgb1[0]-$rgb2[0]) <= 2 and Abs($rgb1[1]-$rgb2[1]) <= 2 and Abs($rgb1[2]-$rgb2[2]) <= 2
endfunc

;~ $hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
;~ $hPen = _WinAPI_CreatePen($PS_SOLID, 5, 0)
;~ $o_Orig = _WinAPI_SelectObject($hDC, $hPen)

;~ func drawCross()
;~     $length=30
;~     _WinAPI_DrawLine($hDC, $exclaimationX - $length/2, $exclaimationY, $exclaimationX + $length/2, $exclaimationY)
;~     _WinAPI_DrawLine($hDC, $exclaimationX, $exclaimationY - $length/2, $exclaimationX, $exclaimationY + $length/2)
;~     _WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0)
;~     _WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_ERASE)
;~     _WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN)
;~ EndFunc

#region Button clicking
global $nox = WinGetHandle('Bộ giả lập android Nox')
if @error <> 0 then
    $nox = false
endif

func click($x, $y, $clicks = 1, $speed = 100)
    if $nox then
        ControlClick($nox, '', $nox, 'left', $clicks, $x, $y)
    else
        MouseClick($MOUSE_CLICK_LEFT, $x, $y, $clicks, 2)
    endif
    sleep($speed)
EndFunc

local $clickTimer[] = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]

func clickDebounced($id, $x, $y, $clicks = 1, $speed = 100)
    if TimerDiff($clickTimer[$id]) >= $speed then
        $clickTimer[$id] = TimerInit()
        click($x, $y, $clicks, $speed)
    endif
EndFunc

func clickUseRod()
    clickDebounced(0, $buttonUseRodX, $buttonUseRodY, 1, 200)
EndFunc

func clickWithdrawRod()
    clickDebounced(1, $buttonWithdrawRodX, $buttonWithdrawRodY, 10, 10)
EndFunc

func clickOpenBag()
    clickDebounced(2, $buttonOpenBagX, $buttonOpenBagY, 1, 0) ;100 trở lên thì sleep vô tận cmnl, wtf?
EndFunc

func clickTabTool()
    clickDebounced(3, $buttonTabTool1X, $buttonTabTool1Y, 1, 200)
EndFunc

func clickCloseBag()
    clickDebounced(4, $buttonCloseBag3X, $buttonCloseBag3Y, 1, 200)
EndFunc

func clickStoreFish()
    clickDebounced(5, $buttonStoreFishX, $buttonStoreFishY, 1, 200)
EndFunc

func clickStoreTrash()
    clickDebounced(6, $buttonStoreTrashX, $buttonStoreTrashY, 1, 200)
EndFunc

func clickFixRod()
    clickDebounced(7, pick($buttonFixRodX), pick($buttonFixRodY), 1, 1000)
EndFunc

func clickPayMoneyFixRod()
    clickDebounced(8, $buttonPayMoneyFixRodX, $buttonPayMoneyFixRodY, 1, 1000)
EndFunc

func clickFixedRod()
    clickDebounced(9, $buttonFixedRodX, $buttonFixedRodY, 1, 1000)
EndFunc

func clickSelectRod()
    clickDebounced(10, pick($bagItemX), pick($bagItemY), 1, 200)
EndFunc

func clickCloseMission()
    clickDebounced(11, $buttonCloseMissionX, $buttonCloseMissionY, 1, 200)
endfunc

func clickClosePhone()
    clickDebounced(12, $boardPhoneButtonClose1X, $boardPhoneButtonClose1Y, 1, 2000)
endfunc

func clickCloseOtherProfile()
    clickDebounced(13, $boardOtherProfileButtonX, $boardOtherProfileButtonY, 1, 2000)
endfunc

func clickCloseShop()
    clickDebounced(14, $shopCloseButtonX, $shopCloseButtonY, 1, 2000)
endfunc
#endregion

#region Detecting
func isMissionOpened()
    return PixelGetColor($boardMission1X, $boardMission1Y) == $boardMission1Color _
       and PixelGetColor($boardMission2X, $boardMission2Y) == $boardMission2Color _
       and not isOpenBagButtonShown()
EndFunc

func isPhoneOpened()
    return PixelGetColor($boardPhoneButtonClose1X, $boardPhoneButtonClose1Y) == $boardPhoneButtonClose12345Color _
       and PixelGetColor($boardPhoneButtonClose2X, $boardPhoneButtonClose2Y) == $boardPhoneButtonClose12345Color _
       and PixelGetColor($boardPhoneButtonClose3X, $boardPhoneButtonClose3Y) == $boardPhoneButtonClose12345Color _
       and PixelGetColor($boardPhoneButtonClose4X, $boardPhoneButtonClose4Y) == $boardPhoneButtonClose12345Color _
       and PixelGetColor($boardPhoneButtonClose5X, $boardPhoneButtonClose5Y) == $boardPhoneButtonClose12345Color _
       and PixelGetColor($boardPhoneButtonClose6X, $boardPhoneButtonClose6Y) <> $boardPhoneButtonClose6NotColor _
       and PixelGetColor($boardPhoneButtonMailX, $boardPhoneButtonMailY) == $boardPhoneButtonMailColor _
       and PixelGetColor($boardPhoneButtonPlazaX, $boardPhoneButtonPlazaY) == $boardPhoneButtonPlazaColor _
       and not isOpenBagButtonShown()
EndFunc

func isOpenBagButtonShown()
    return PixelGetColor($buttonOpenBagX, $buttonOpenBagY) == $buttonOpenBagColor
EndFunc

func isBagOpened()
    return not isOpenBagButtonShown() _
       And isCloseBagButtonShown() _
       And PixelGetColor($bagOpenedX, $bagOpenedY) == $bagOpenedColor
EndFunc

func isTabToolSelected()
    return isBagOpened() _
       And PixelGetColor($buttonTabTool1X, $buttonTabTool1Y) <> $buttonTabTool1Color _
       And PixelGetColor($buttonTabTool2X, $buttonTabTool2Y) <> $buttonTabTool2Color _
       And PixelGetColor($buttonTabTool3X, $buttonTabTool3Y) == $buttonTabTool3Color
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

func isOtherProfileOpened()
    return PixelGetColor($boardOtherProfile1X, $boardOtherProfile1Y) == $boardOtherProfile1Color _
       And PixelGetColor($boardOtherProfileButtonX, $boardOtherProfileButtonY) == $boardOtherProfileButtonColor
EndFunc

func isShopOpened()
    return PixelGetColor($shop1X, $shop1Y) == $shop1Color _
       And PixelGetColor($shop2X, $shop2Y) == $shop2Color _
       And PixelGetColor($shopCloseButtonX, $shopCloseButtonY) == $shopCloseButtonColor
EndFunc

func isFishing()
    return not isOpenBagButtonShown() _
       and not isBagOpened() _
       and not isPhoneOpened() _
       and not isMissionOpened() _
       and not isShopOpened() _
       and not isOtherProfileOpened() _
       and not isButtonFixedRodShown() _
       and not isButtonPayMoneyFixRodShown() _
       and not isStoreFishButtonShown()
EndFunc
#endregion

#region complex select
func clickRodBag()
    clickUseRod()
    clickOpenBag()
endfunc

func closeMission()
    _log('Start closing mission')
    LoopOn(isMissionOpened, clickCloseMission, 'Closing mission')
    LoopOnNot(isOpenBagButtonShown, doNotThing)
    _log('End closing mission')
endfunc

func closePhone()
    _log('Start closing phone')
    LoopOn(isPhoneOpened, clickClosePhone, 'Closing phone')
    LoopOnNot(isOpenBagButtonShown, doNotThing)
    _log('End closing phone')
endfunc

func closeOtherProfile()
    _log('Start closing other''s profile')
    LoopOn(isOtherProfileOpened, clickCloseOtherProfile, 'Closing other''s profile')
    LoopOnNot(isOpenBagButtonShown, doNotThing)
    _log('End closing other''s profile')
endfunc

func closeShop()
    _log('Start closing shop')
    LoopOn(isShopOpened, clickCloseShop, 'Closing shop')
    LoopOnNot(isOpenBagButtonShown, doNotThing)
    _log('End closing shop')
endfunc

func storeFish()
    _log('Start store fish')
    LoopOn(isStoreFishButtonShown, clickStoreFish, 'Storing fish')
    LoopOnNot(isOpenBagButtonShown, doNotThing)
    _log('End store fish')
endfunc

func storeTrash()
    _log('Start store trash')
    LoopOn(isStoreTrashButtonShown, clickStoreTrash, 'Storing trash')
    LoopOnNot(isOpenBagButtonShown, doNotThing)
    _log('End store trash')
endfunc

func selectRodOrExit()
    if rodCheckMarkExits() then
        _log('Clicking close bag')
        clickCloseBag()
    Else
        _log('Clicking select rod')
        clickSelectRod()
    endif
endfunc

func successFixRod()
    _log('Start click success fix rod')
    LoopOn(isButtonFixedRodShown, clickFixedRod, 'Clicking')
    _log('End pay money fix rod')

endfunc

func payMoneyFixRod()
    _log('Start pay money fix rod')
    LoopOn(isButtonPayMoneyFixRodShown, clickPayMoneyFixRod, 'Paying money fix rod')
    LoopOnNot(isButtonFixedRodShown, doNotThing, 'Waiting for success show')
    successFixRod()
    _log('End pay money fix rod')

endfunc

func doBagStuff()
    _log('Start doing bag stuff')
    LoopOn(isTabToolNotSelected, clickTabTool, 'Clicking tab tool')

    sleep(200)
    if isRodNeedFix() Then
        _log('Detected rod needs fix')
        LoopOnNot(isButtonPayMoneyFixRodShown, clickFixRod, 'Clicking fix rod')
        payMoneyFixRod()
        LoopOn(isButtonFixedRodShown, clickFixedRod, 'Click success')
    endif

    LoopOn(isBagOpened, selectRodOrExit, 'Closing/selecting until bag is closed and button open bag shown')

    _log('End doing bag stuff')
    Sleep(200)
endfunc

#endregion