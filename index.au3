#include <Misc.au3>

#include-once <debugBox.au3>
#include <const.au3>
#include <helper.au3>
_log('----------------------- Program started -----------------------')

_Singleton ('PlayTogetherAuto_main', 0)

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
    local $missedRod
    _logLoopStarted()
    _log('-------- new loop --------')
    _log('Started new loop')

    _log('Spam rod-bag')
    $beginLoopTime = TimerInit()
    While isOpenBagButtonShown() and TimerDiff($beginLoopTime) < 5000
        $startUsedRodTime = TimerInit()
        clickUseRod()
        clickOpenBag()
    WEnd

    _log('Detecting is bag opened')
    sleep(200)
    $beginLoopTime = TimerInit()
    do
        local $currentTimeDiff = TimerDiff($beginLoopTime)
        _log('Detecting is bag opened ' & Round($currentTimeDiff/100)/10 & '/' & $MinimumIdleRod & 's', false)
        if isBagOpened() then
            _log('Detected bag opened')
            doBagStuff()
            ;~ _log('Wait for bag completely closed')
            ;~ $beginLoopTime = TimerInit()
            ;~ While not isOpenBagButtonShown() and $currentTimeDiff < 5000
            ;~ WEnd
            _log('Clicking use rod')
            $beginLoopTime = TimerInit()
            While isOpenBagButtonShown() and $currentTimeDiff < 5000
                $startUsedRodTime = TimerInit()
                clickUseRod()
            WEnd
            ExitLoop
        endif
    until $currentTimeDiff >= 5000

    $missedRod = false
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

    Local $initColor = getCurrentExclaimationColor()

    _log('Detecting exclamimation')
    Local $currentColor
    $missedRod = false
    Do
        $currentTimeDiff = TimerDiff($startUsedRodTime)
        _log('Detecting exclamimation ' & Round($currentTimeDiff/100)/10 & '/' & $MaximumTimeFishing & 's', false)
        $currentColor = getCurrentExclaimationColor()
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
            _log('Store fish button found, storing fish')
            while isStoreFishButtonShown()
                clickStoreFish()
            wend
            $isSuccess = true
            ExitLoop
        Else
            if isStoreTrashButtonShown() Then
                _log('Store trash button found, storing trash')
                while isStoreTrashButtonShown()
                    clickStoreTrash()
                wend
                $isSuccess = true
                ExitLoop
            Else
                if isOpenBagButtonShown() Then
                    _log('Open bag button found, probably color changed wrong or rod snapped')
                    _log('Initial color: ' & $initColor)
                    _log('Changed color: ' & $currentColor)

                    $isSuccess = false
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