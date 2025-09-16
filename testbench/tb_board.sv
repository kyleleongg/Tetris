module tb_board();

//Declare inputs as reg and outputs as wire
reg rst;
reg clk;
reg[3:0] board_x;
reg[4:0] board_y;
reg[23:0] write_colour;
reg validate_start;
reg write_done;
wire occupied, validate_done_flag;
wire[1:0] lines_cleared;
wire[23:0] output_colour;

board dut(
    .rst(rst),
    .clk(clk),
    .board_x(board_x),
    .board_y(board_y),
    .write_colour(write_colour),
    .validate_start(validate_start),
    .write_done(write_done),
    .occupied(occupied),
    .lines_cleared(lines_cleared),
    .output_colour(output_colour),
    .validate_done_flag(validate_done_flag)
);

//Initialize clock.
initial begin
    clk = 1; #1;
    forever begin
        clk = 0; #1;
        clk = 1; #1;
    end
end

initial begin
    rst = 1;
    write_colour = 24'd1;
    validate_start = 0;
    write_done = 0;
    board_x = 0;
    board_y = 19;
    #10;

//////////////////////////////////////////
//Type in add wave -r sim:/tb_board/dut/board to be able to view board array in waveform
//////////////////////////////////////////

//Reset the board, check that it is initialized to 0's
    rst = 0;
    #10;
    rst = 1;
    #420;
    if(dut.board[0][0] == 0) begin
        if(dut.board[19][9] ==0) begin
            $display("Matrix initialized to 0. RESET good.");
        end
    end else begin
        $display("Matrix RESET failed.");
    end

    if(dut.state == dut.WAIT) begin
        $display("Module correctly waits in WAIT state after resetting");
    end

//Now test the writing state and ensure you can write 4 blocks into memory
    validate_start = 1;
    #3;
//board[19][0] = 1
    board_x = 1;
    #3;
//board[19][1] = 1
    board_x = 2;
    #3;
//board[19][2] = 1
    board_x = 1;
    board_y = 18;
    #3;
//board[18][1] = 1
    if(dut.board[19][0] == 1 && dut.board[19][1] == 1 && dut.board[19][2] == 1 && dut.board[18][1] == 1) begin
        $display(" WRITE success. 4 inputs tested and written correctly to board array");
    end

//Test that with no full rows, nothing changes in the board
    write_done = 1;
    #10;
    write_done = 0;
    validate_start = 0;
    #2000;
    if(dut.board[19][0] == 1 && dut.board[19][1] == 1 && dut.board[19][2] == 1 && dut.board[18][1] == 1 && dut.board[0][9] == 0) begin
        $display("No cleared lines success!");
    end

//Test that the combinational blocks work for checking for occupied and colour:
    board_x = 0;
    board_y = 19;
    #10;
    if(occupied && output_colour == 24'd1) begin
        $display("Combinational occupied success");
    end
    #2;
    board_x = 0;
    board_y = 0;
    #10;
    if(!occupied) begin
        $display("Combinational unoccupied success");
    end

    validate_start = 1;
    #5;

//Now fill the entire bottom row, with 1 block at board[18][1], ensure bottom row gets cleared and leaves this block in 19th row 
    board_y = 19;
    board_x = 3;
    #3
    board_x = 4;
    #3;
    board_x = 5;
    #3;
    board_x = 6;
    #3;
    board_x = 7;
    #3;
    board_x = 8;
    #3;
    board_x = 9;
    #3;
    validate_start = 0;
    write_done = 1;
    #10;
    write_done = 0;
    #2000;
    if(dut.board[19][1] == 1 && dut.board[18][1] == 0 && dut.board[19][9] == 0 && dut.board[19][0] == 0) begin
        $display("One line clear success!");
    end
    if(dut.crash) begin
        $display("Crash signal valid for 1 bit on y = 19");
    end

    $finish;



end

endmodule: tb_board
