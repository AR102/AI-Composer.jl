# AI at music - Computers learn composing
This is a project by MatteoFriedrich and me for the Jugend Forscht 2021 competition in Germany. It is capable of creating new, mostly original Jazz music by using an Auto Encoder. If you want to know more about it, you can read "paper (German).pdf".

## Installation
Windows and Linux are recommended.

Install the zip file from https://github.com/AR102/JuFo2021/releases/tag/v1.0. Move it to a preffered location and unzip it.
### Windows
Open the folder "Neural Jazz" and execute the Batch file ("Neural Jazz.bat"). The first startup may take a while as a few packages have to be installed. An internet connection is necessary.

### MacOS and Linux
Install the Julia programming language (https://julialang.org/downloads/), currently only version 1.5 is tested. Then start it by typing "julia" into your systems terminal. Now navigate to the location of the folder by typing "cd("path/to/Neural Jazz/src"). To start it, type "include("main.jl")". The first startup may take a while as a few packages have to be installed. An internet connection is necessary.

## Usage
Change the features of the neuronal network by changing the values of the five sliders in the top right. You can set them to random values with the "Random Seed" Button below. The output of the neuronal is shown in the top left as a 16 high and 21 wide Array / "grid". The width is the position of a note (an eighth note each) and the height the tone of a note (from C-4 at the bottom to C-6 at the top). If the rectangle at a specific position is white, it means that there is no note played there. If it's black, it is played. The shade of black / grey is determined by how probable the neuronal network thinks it is that the note is "right" (sounds good). It ranges from 0.0 (definitely not - white) to 1.0 (definitely - black) with 0.5 (maybe - grey) in the middle. The slider in the middle left is the "tendency" slider. It determines what notes are going to be shown in the bottom left: The "probability" of a note has to be higher than the tendency for it to be shown there. You can hear the notes there by clicking "Play", though the quality won't be very good. To hear it in high quality with a piano as an instrument, you have to choose different motives or "modules". You can save the current notes to module x by clicking the "Keep as Module x" button and delete the notes of module x by clicking the "Reset Module x" button. Once you have all four modules set, you can click "Save Song (all modules)". It'll composite the four modules int the scheme 1, 1, 2, 1, 3, 4, 2, 1, 4, 1 as each module is only 2 tacts long. After you chose the location, the midi file of the song will be saved there. If you want to change the tempo of it or export it as a different file, you can use another program like musescore (https://musescore.org/de) to open and edit the file. You can just ignore the slider over the "Play" Button, it does nothing for now.
