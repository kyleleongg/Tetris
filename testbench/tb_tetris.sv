module tb_tetris();

//Initialize inputs as reg and outputs as wire
reg CLOCK_50;
reg[3:0] KEY;
reg[9:0] SW;
wire[7:0] VGA_R, VGA_G, VGA_B, VGA_X;
wire VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT;
wire[6:0] VGA_Y;
wire[2:0] VGA_COLOUR;

tetris dut(
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .SW(SW),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_CLK(VGA_CLK),
    .VGA_X(VGA_X),
    .VGA_Y(VGA_Y),
    .VGA_COLOUR(VGA_COLOUR),
    .VGA_PLOT(VGA_PLOT)
);


//Initialize clock
initial begin
    CLOCK_50 = 1; #1;
    forever begin
        CLOCK_50 = 0; #1;
        CLOCK_50 = 1; #1;
    end
end


/* Use this tb function to test the state transitions and colours. comment out game and vga initialization.
initial begin
    SW[9] = 1;
    SW[8] = 1;
    dut.current_colour = 3'b001;
    dut.gameover = 0;
    dut.vga_occupied = 0;
    #10;

//Test 1: Ensure tetris goes into RESET and after 19200 cycles, it goes into WAITTOSTART
    SW[9] = 0;
    #5;
    SW[9] = 1;
    #38400;
    if(dut.state == dut.WAITTOSTART) begin
        $display("T1 pass: Reset and went into WAITTOSTART state");
    end
    #10;

//Test 2: Enter the SCANDRAW state, and have board_occupied = 0, but have the currentxy set to (0,1)
//This should correspond to all the pixels in the square with top left (3,6) and bottom right (8,11)
    dut.current_x0 = 0;
    dut.current_y0 = 1;
    SW[8] = 0;
    #1440; //Enough time to scan the "Top 2" rows of board
    $finish;
end
*/

//Use this tb function to test game.sv, ignore the vga. Set an auto ticker for vertical and horizontal flag
initial begin
    dut.g.vertical_flag = 1; #1;
    forever begin
        dut.g.vertical_flag = 0; #1000;
        dut.g.vertical_flag = 1; #2;
    end
end

initial begin
    dut.g.horizontal_flag = 1; #1;
    forever begin
        dut.g.horizontal_flag = 0; #100;
        dut.g.horizontal_flag = 1; #2;
    end
end

initial begin
    SW[9] = 1;
    SW[8] = 1;
    KEY = 4'b1111;
    #10;
    SW[9] = 0;
    #10;
    SW[9] = 1;
    //Everything should be resetting now. Wait 38400 ticks to start the game. board should be all 0's, each pixel should be 0
    #38500;
//Test 1: Ensure everything goes into correct wait states after a reset
    if(dut.state == dut.WAITTOSTART && dut.g.state == dut.g.WAIT && dut.g.board_rdy == 1) begin
        $display("T1 pass. Everything in correct state after reset, waiting for start signal");
    end
//Test 2: Start the game and ensure it goes into activepiece
    SW[8] = 0;
    #3;
    SW[8] = 1;
    if(dut.g.state == dut.g.ACTIVE_PIECE) begin
        $display("T2 pass. Went into ACTIVE_PIECE state");
    end
    #80000;
    $finish;
end

endmodule: tb_tetris
