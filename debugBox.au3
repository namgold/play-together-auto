#include <File.au3>
#include <Date.au3>

#include <const.au3>

AutoItSetOption('GUIOnEventMode', 1)

local const $title='randomtitleabcxyzakdsjhfdfailgherw9ioutnbroi'
local $loopCount = 0
local $successCount = 0
Local $logFile = FileOpen($logFilePath, 1)
local $currentMsg = 'asd'

SplashTextOn($title, $currentMsg, '350', '35', '0', '0', 37, '', '', '')

func _log($msg, $isWriteToLog = true)
    if ($msg <> $currentMsg) then
        $formatedMsg = $successCount & '/' & $loopCount & ' ' & $msg
        ControlSetText($title, '', 'Static1', $formatedMsg)
        if $isWriteToLog then
            _FileWriteLog($logFile,  $formatedMsg)
        endif
        $currentMsg = $msg
    endif
EndFunc

func _logLoopStarted()
    $loopCount = $loopCount + 1
EndFunc

func _logFishSuccess()
    $successCount = $successCount + 1
EndFunc

func clickClose()
    Exit
EndFunc