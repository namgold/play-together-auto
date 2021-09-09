#include <Misc.au3>

#include-once <debugBox.au3>
#include <const.au3>
#include <helper.au3>

global $exclaimationX = 0
global $exclaimationY = 0
global $rodPosition = 1
global $minimumIdleRod = 13
global $maximumTimeFishing = 60
_Singleton ('PlayTogetherAuto_main', 0)

_log('----------------------- Program started -----------------------')


_log('Checking resolution')
If @DesktopHeight / @DesktopWidth <> 0.5625 Then
    MsgBox($MB_OK, "Screen resolution not support", "This PC using not supported screen resolution ratio. Please use the screen with ratio 16:9 (1920:1080 is recommended)")
    Exit 1
EndIf

_log('Getting input')
getInput()

_log('Program run with params:')
_log('ExclaimationX: ' & $exclaimationX)
_log('ExclaimationY: ' & $exclaimationY)
_log('RodPosition: ' & $rodPosition)
_log('MinimumIdleRod: ' & $minimumIdleRod)
_log('MaximumTimeFishing: ' & $maximumTimeFishing)

HotKeySet("{esc}", "EscToggle")
func EscToggle()
    _log('Esc toggled')
    _log('Exit program')
    _log('----------------------- Program exit -----------------------')
    Exit
EndFunc

HotKeySet('`', "BackTickToggle")
func BackTickToggle()
    _log('Backtick toggled')
    _log('Exit program')
    _log('----------------------- Program exit -----------------------')
    Exit
EndFunc

While True
    local $startUsedRodTime
    local $beginLoopTime
    local $missedRod = false
    local $failUseRodAfterBag = false
    local $currentTimeDiff
    local $detectedisBagOpened = false
    local $detectedisTabToolOpened = false
    local $detectedisFishing = false
    _logLoopStarted()
    _log('-------- new loop --------')
    _log('Started new loop')

    #region Start detecting windows
    _log('Start detecting windows')
    if isMissionOpened()                then closeMission()
    if isPhoneOpened()                  then closePhone()
    if isOtherProfileOpened()           then closeOtherProfile()
    if isShopOpened()                   then closeShop()
    if isButtonPayMoneyFixRodShown()    then payMoneyFixRod()
    if isButtonFixedRodShown()          then successFixRod()
    if isStoreFishButtonShown()         then storeFish()
    if isStoreTrashButtonShown()        then storeTrash()

    if isBagOpened()            then $detectedisBagOpened = true
    if isTabToolSelected()      then $detectedisTabToolOpened = true
    if isFishing()              then $detectedisFishing = true
    _log('End detecting windows')
    #endregion

    if not $detectedisFishing then
        if not $detectedisBagOpened then
            $startUsedRodTime = TimerInit()
            LoopOn(isOpenBagButtonShown, clickRodBag, 'Spam clicking rod-bag')

            _log('Detecting is bag opened')
            sleep(200)
            $beginLoopTime = TimerInit()
            do
                local $currentTimeDiff = TimerDiff($beginLoopTime)
                _log('Detecting is bag opened ' & Round($currentTimeDiff/100)/10 & '/' & '5' & 's', false)
                if isBagOpened() then
                    _log('Detected bag opened')
                    doBagStuff()
                    LoopOn(isOpenBagButtonShown, clickUseRod, 'Clicking use rod')
                    if isOpenBagButtonShown() then
                        $failUseRodAfterBag = true
                    else
                        $startUsedRodTime = TimerInit()
                    endif
                    ExitLoop
                endif
            until $currentTimeDiff >= 5000
        else
            doBagStuff()
        endif
        if $failUseRodAfterBag then
            _log('End loop, fish failed')
            _log('-------- end loop --------')
            ContinueLoop
        endif

        _log('Idle rod for ' & $MinimumIdleRod & 's')
        do
            local $currentTimeDiff = TimerDiff($startUsedRodTime)
            _log('Idle rod for ' & Round($currentTimeDiff/100)/10 & '/' & $MinimumIdleRod & 's' , false)
            if isOpenBagButtonShown() Then
                _log('Open bag button found, probably missed fish')
                $missedRod = true
            EndIf
        until $currentTimeDiff >= $MinimumIdleRod * 1000 or $missedRod
        if $missedRod then
            _log('End loop, fish failed')
            _log('-------- end loop --------')
            ContinueLoop
        endif
    else
        $startUsedRodTime = TimerInit()
    endif

    Local $initColor = getCurrentExclaimationColor()

    _log('Detecting exclamimation')
    Local $currentColor
    Do
        $currentTimeDiff = TimerDiff($startUsedRodTime)
        _log('Detecting exclamimation ' & Round($currentTimeDiff/100)/10 & '/' & $MaximumTimeFishing & 's', false)
        $currentColor = getCurrentExclaimationColor()
        if isRGBNear($initColor, $currentColor) then
            $initColor = $currentColor 
        endif
        if isOpenBagButtonShown() Then
            _log('Open bag button found, probably missed fish')
            $missedRod = true
        EndIf
    Until $initColor <> $currentColor Or $currentTimeDiff > $MaximumTimeFishing * 1000 or $missedRod

    if $missedRod then
        _log('End loop, fish failed')
        _log('-------- end loop --------')
        ContinueLoop
    endif

    _log('Detected color changed, withdrawing rod')
    clickWithdrawRod()

    _log('Detecting store fish')

    Local $initTime = TimerInit()
    local $isSuccess = false
    Do
        if isStoreFishButtonShown() then
            _log('Fished successfully')
            storeFish()
            $isSuccess = true
            ExitLoop
        Else
            if isStoreTrashButtonShown() Then
                _log('Fished trash')
                storeTrash()
                $isSuccess = true
                ExitLoop
            Else
                if isOpenBagButtonShown() Then
                    if TimerDiff($initTime) < 2500 then
                        _log('Fish snapped')
                        $isSuccess = true
                    else
                        _log('Open bag button found, probably color changed wrong')
                        _log('Initial color: ' & $initColor)
                        _log('Changed color: ' & $currentColor)
                        $isSuccess = false
                    endif
                    ExitLoop
                EndIf
            EndIf
        endif
    Until TimerDiff($initTime) > 10000

    if $isSuccess then
        _logFishSuccess()
        _log('End loop, fish success')
    Else
        _log('End loop, fish failed')
    endif

    sleep(500)
    _log('-------- end loop --------')
WEnd