#include-once <debugBox.au3>
#include-once <const.au3>
#include <generateInput.au3>

_log('Starting separated capture program')
_log('Capturing exclaimation position')
generateInput()
$exclaimationX = IniRead($inputPath, "Exclaimation Mark", "exclaimationX", 0)
$exclaimationY = IniRead($inputPath, "Exclaimation Mark", "exclaimationY", 0)
_log('Captured with data:')
_log('ExclaimationX: ' & $exclaimationX)
_log('ExclaimationY: ' & $exclaimationY)
