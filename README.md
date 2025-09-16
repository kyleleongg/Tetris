# Tetris

Successfully recreated Tetris in SystemVerilog for use on DE1-SoC board and VGA monitor. Used vga adapter library, credits in vga_adapter.sv.
Game includes line clearing, rotations, fast-dropping, and other features included in the original NES Tetris game.

### Demo
[![Watch the video](https://img.youtube.com/vi/U0KNt0yqEvo/0.jpg)](https://youtube.com/shorts/U0KNt0yqEvo?si=VbXQbLx3mzL5n5Wa)

### How to Run/Build on Your Own:

1. Download repo and create new project in Quartus Prime.  
2. Include all `.sv` files that DO NOT begin with "tb_" (testbenches) with `tetris.sv` as the top-level module.  
3. In Assignments -> Import Assignments -> Upload the `DE1_SoC.qsf` file (pin planner).  
4. Compile the design, then go to Tools -> Programmer -> Select your board and upload to DE1-SoC.  
5. To start the game:  
   - Switch SW[9] to reset  
   - Switch SW[8] to start  
   - Move with KEY[3]/KEY[2], rotate with KEY[1], fast drop with KEY[0]  


Enjoy!

Created by Kyle Leong
