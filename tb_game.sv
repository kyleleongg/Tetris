//Comment out initialization of tick_gen in game.sv and manually handle ticks here.
//NOTE that for testing, each cycle of spawning in, falling, locking into board, and then checking/clearing lines takes
//approximately 1000 clock cycles! (2000 units of time)

module tb_game();

//Instantiate inputs as reg and outputs as wire
reg clk;
reg rst;
reg notstart;
reg pause;
reg notleft;
reg notright;
reg notrotate;
wire gameover;

game dut(
    .clk(clk),
    .rst(rst),
    .notstart(notstart),
    .pause(pause),
    .notleft(notleft),
    .notright(notright),
    .notrotate(notrotate),
    .gameover(gameover)
);

//Type in command line to see the board matrix
/*/////////////////////////////////////////
add wave -r sim:/tb_game/dut/b/board 
/////////////////////////////////////////*/

//Initialize clock
initial begin
    clk = 1; #1;
    forever begin
        clk = 0; #1;
        clk = 1; #1;
    end
end

initial begin

//Test 1: testing that board.sv is resetting and not letting game start until board_rdy is asserted.
    dut.vertical_flag = 0;
    dut.horizontal_flag = 0;
    rst = 1;
    notleft = 1;
    notright = 1;
    pause = 1;
    notstart = 0; 
    #10;
    rst = 0;
    #10;
    rst = 1;
    #5;
    if(dut.state == dut.WAIT) begin
        $display("game.sv correctly went into WAIT state because board.sv not ready");
    end
    #5;
    notstart = 1;
    #420;   //reset should be good now
    if(dut.board_rdy) begin
        $display("Test 1 pass. Board reset and set rdy flag to 1, proceed to starting game!");
    end
    #16;
    
//Test 2: go into ACTIVE_PIECE state and AP_INIT ap_state 
    notstart = 0;
    #2;
    if(dut.state == dut.ACTIVE_PIECE && dut.ap_state == dut.AP_INIT) begin
        $display("T2 pass. went into ACTIVE_PIECE state and AP_INIT ap_state. Should also have a current_piece_id now");
    end
    #5;
//Test 3: go into AP_FETCH and set new current_x and current_y locations
    if(dut.ap_state == dut.AP_FETCH) begin
        $display("T3 pass. First piece ID = %0d", dut.current_piece_id);
    end

//Test 4: Check 4 piece locations and ensure ap_state goes into AP_MOVE_ALLOWED (game should "pause" here cuz ticking is done manual)
    #100;
    if(dut.ap_state == dut.AP_MOVE_ALLOWED) begin
        $display("T4 pass: initialized newest piece and set it's new current_x current_y positions");
    end
    $display("Piece locations (x,y): (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);

//Test 5: Allow piece to fall 1 tile and ensure substate is still in move_allowed
    dut.vertical_flag = 1;
    #3;
    $display("New piece locations, should just be y-1: (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);
    if(dut.ap_state == dut.AP_MOVE_ALLOWED) begin
        $display("T5 pass. Stayed in MOVE_ALLOWED");
    end
    
//Test 6: Allow piece to fall to bottom and then go into VALIDATE state
    #40;
    if(dut.state == dut.VALIDATE) begin
        $display("T6 pass. Went into VALIDATE state");
    end
    

//Test 7: Wait long time and ensure game ends up in a gameover state
    #11000;
    if(dut.state == dut.GAMEOVER) begin
        $display("T7 pass. Spawned in pieces continuously and went to gameover");
    end




//Test 8: Reset game and test that movement to the left works, and then goes to ap_move_not_allowed until deassert notleft
    dut.vertical_flag = 0;
    dut.horizontal_flag = 0;
    rst = 1;
    notleft = 1;
    notright = 1;
    notrotate = 1;
    pause = 1;
    notstart = 0; 
    #10;
    rst = 0;
    #10;
    rst = 1;
    #5;
    #5;
    notstart = 1;
    #420;   //reset should be good now
    notstart = 0;
    #200;
    $display("Piece locations before left(x,y): (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);
    notleft = 0;
    #3;
    dut.horizontal_flag = 1;
    #10;
    $display("Piece locations after left(x,y): (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);
    if(dut.ap_state == dut.AP_MOVE_NOT_ALLOWED) begin
        $display("T8 pass. Went into AP_MOVE_NOT_ALLOWED and stayed there");
    end

//Test 9: Spam left and ensure block stays on board
    notleft = 1; #3; notleft = 0; #3; notleft = 1; #3; notleft = 0; #3; notleft = 1; #3; notleft = 0; #3; 
    notleft = 1; #3; notleft = 0; #3; notleft = 1; #3; notleft = 0; #3; notleft = 1; #3; notleft = 0; #3; notleft = 1; #3;
    $display("Piece locations after spamming left(x,y): (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);
    if(dut.left_allowed == 0 && dut.right_allowed == 1) begin
        $display("T9 pass. Moved all the way to left and then blocked left movement");
    end

//Test 10: Spam right and ensure block stays on board
    notright = 0; #3; notright = 1; #3; notright = 0; #3; notright = 1; #3; notright = 0; #3; notright = 1; #3; 
    notright = 0; #3; notright = 1; #3; notright = 0; #3; notright = 1; #3; notright = 0; #3; notright = 1; #3;
    notright = 0; #3; notright = 1; #3; notright = 0; #3; notright = 1; #3; notright = 0; #3; notright = 1; #3;
    $display("Piece locations after spamming right(x,y): (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);
    if(dut.right_allowed == 0 && dut.left_allowed == 1) begin
        $display("T10 pass. Moved all the way right and blocked right movement while allowing left");
    end

//Test 11: Try allowing a diagonal movement, ensure block ONLY moves down
    notleft = 0;
    dut.vertical_flag = 1;
    #3;
    $display("Piece locations after 1 left 1 down at same time(x,y): (%0d,%0d), (%0d,%0d), (%0d,%0d), (%0d,%0d)", dut.current_x[0], dut.current_y[0],
             dut.current_x[1], dut.current_y[1], dut.current_x[2], dut.current_y[2], dut.current_x[3], dut.current_y[3]);
    #3;
    if(dut.ap_state == dut.AP_MOVE_NOT_ALLOWED) begin
        $display("Successfully stayed in AP_MOVE_NOT_ALLOWED");
    end
    #30;
    $finish;
    



//Test 10: Clear a line and ensure board.sv handles (it should since board.sv has already been tested)

end






endmodule: tb_game

