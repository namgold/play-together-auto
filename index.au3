#include <Misc.au3>

#include <debugBox.au3>
#include <helper.au3>
#include <const.au3>

_Singleton ('PlayTogetherAuto_main', 0)

If @DesktopHeight / @DesktopWidth <> 0.5625 Then
    MsgBox($MB_OK, "Screen resolution not support", "This PC using not supported screen resolution ratio. Please use the screen with ratio 16:9 (1920:1080 is recommended)")

    Exit 1
EndIf

getInput()

HotKeySet("{esc}", "ExitToggle")
HotKeySet('`', "ExitToggle")
func ExitToggle()
    Exit
EndFunc

While True
    local $startUsedRodTime
    local $beginLoopTime
    local $missedRod

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
    while TimerDiff($beginLoopTime) < 5000
        if isBagOpened() then
            doBagStuff()
            _log('Wait for bag completely closed')
            $beginLoopTime = TimerInit()
            While not isOpenBagButtonShown() and TimerDiff($beginLoopTime) < 5000
            WEnd
            _log('Clicking use rod')
            $beginLoopTime = TimerInit()
            While isOpenBagButtonShown() and TimerDiff($beginLoopTime) < 5000
                $startUsedRodTime = TimerInit()
                clickUseRod()
            WEnd
            ExitLoop
        endif
    wend

    $missedRod = false
    do ;sleep 13s and detect for is missed rod?
        local $currentTimeDiff = TimerDiff($startUsedRodTime)
        _log('Sleep 13s: ' & Round($currentTimeDiff/100)/10 & 's')
        if isOpenBagButtonShown() Then
            _log('Missed rod')
            $missedRod = true
        EndIf
    until $currentTimeDiff >= 13000 or $missedRod
    if $missedRod then
        ContinueLoop
    endif

    Local $initColor = getCurrentExclaimationColor()
    $beginLoopTime = TimerInit()

    _log('Detecting exclamimation')
    Local $currentColor
    $missedRod = false
    Do ;detecting exclaimation and detect for is missed rod?
        $currentTimeDiff = TimerDiff($beginLoopTime)
        _log('Detecting exclamimation ' & ' ' & Round($currentTimeDiff/100)/10 & 's')
        $currentColor = getCurrentExclaimationColor()
        if isOpenBagButtonShown() Then
            _log('Missed rod')
            $missedRod = true
        EndIf
    Until $initColor <> $currentColor Or $currentTimeDiff > 50000 or $missedRod

    if $missedRod then
        ContinueLoop
    endif

    _log('Withdrawing rod')
    clickWithdrawRod()

    _log('Detecting store fish')

    Local $initTime = TimerInit()
    Do
        if isStoreFishButtonShown() then
            _log('Storing fish')
            while isStoreFishButtonShown()
                clickStoreFish()
            wend
            ExitLoop
        Else
            if isStoreTrashButtonShown() Then
                _log('Storing trash')
                while isStoreTrashButtonShown()
                    clickStoreTrash()
                wend
                ExitLoop
            Else
                if isOpenBagButtonShown() Then
                    _log('Rod snapped')
                    ExitLoop
                EndIf
            EndIf
        endif
    Until TimerDiff($initTime) > 10000

    _log('End loop')
    sleep(500)
WEnd