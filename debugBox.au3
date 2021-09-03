AutoItSetOption('GUIOnEventMode', 1)

local const $title="randomtitleabcxyzakdsjhfdfailgherw9ioutnbroi"

SplashTextOn($title, 'aaa',"350","35","0","0",37,"","","")

func _log($msg)
    ControlSetText($title, '', 'Static1', $msg)
    $currentmsg = $msg
EndFunc

func clickClose()
    Exit
EndFunc