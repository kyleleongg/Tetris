# Tetris

Successfully recreated Tetris in SystemVerilog for use on DE1-SoC board and VGA monitor. Used vga adapter library, credits in vga_adapter.sv.
Game includes line clearing, rotations, fast-dropping, and other features included in the original NES Tetris game.

### Demo
[![Watch the video](https://img.youtube.com/vi/U0KNt0yqEvo/0.jpg)](https://youtube.com/shorts/U0KNt0yqEvo?si=VbXQbLx3mzL5n5Wa)

### How to Run/Build on Your Own:
Download repo and create new project in Quartus Prime. Include all .sv files that DO NOT begin with "tb_" (those are the testbench files which are not required) with tetris.sv as the top-level module.
In Assignments -> Import Assignments -> Upload the DE1_SoC.qsf file (pin planner).
Compile the design, and when it's finished click on the Tools drop down -> Programmer -> Select your board and upload to your DE1 Soc. 
To start the game, switch SW[9] to reset the game, and then switch SW[8] to start. Move pieces left and right with KEY[3] and KEY[2], rotate with KEY[1], and fast drop with KEY[0].

Enjoy!

Created by Kyle Leong
