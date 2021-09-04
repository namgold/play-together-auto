# Play Together Auto Fishing

This Play Together Auto Fishing tool has been written in AutoIT.

## 1. How to use
1. Download latest `playtogether.exe` file from [release](./releases)
2. Run :D

## 2. Notes
- Exit tool with `Esc` or `` ` `` button.
- Please run the game as fullscreen.
- If you have multiple monitor, please make sure the game is running on `main display` screen
- This tool only support screen with ratio 16:9 at any pixel value. The tool working on pixel coordinate and will automatically scale base on your screen pixel value.
- The first times the tool run, it will ask to capture the coordinate of the exclaimation mark then save into `setting.ini` file. You can freely modify this file manually. This file also contains some other settings:
  - `RodPosition`: position of rod in bag (`1`-`6`) (Default `1`)
  - `MinimumIdleRod`: as the game behavior, when throw the rod, it will takes at least some time for the fish to be appeared. Below is minimum time for each rod. (Default `13` seconds)
    - `Pro Rod` - `Cần chuyên nghiệp`: `13`s
    - `Duck Rod` - `Cần vịt`: `17`s
    - `Wooden Rod` - `Cần gỗ`: `18`s
    - `Sword Rod` - `Cần kiếm`: `18`s
    - `Amateur Rod` - `Cần không chuyên`: `19`s
  - `MaximumTimeFishing`: maximum time in seconds for fishing if nothing is detected (could be caused by tool's bug) (Default `60`seconds)

- If you want to re-capture the coordinate of the exclaimation mark, please download `captureExclaimation.exe` file from [release](./releases) then run.

## Author
This tool is written by namgold