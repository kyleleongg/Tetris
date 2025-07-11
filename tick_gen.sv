//This module will generate the flags that will either allow for or force a vertical drop or a horizontal movement. 
//Both shall never be allowed at the same time. This will be controlled in the game.sv file with an if-else statement
//1 unit drops happen every 750ms and horizontal movement is checked every 50ms (20Hz)

module tick_gen(input clk, input rst, input ticking, output vertical_flag, output horizontal_flag);

    logic[24:0] vertical_tick;
    logic[24:0] horizontal_tick;
    logic vertical_flag_inner;
    logic horizontal_flag_inner;

    always_ff @(posedge clk) begin
        if(~rst) begin
            vertical_tick <= 25'd0;
            horizontal_tick <= 25'd0;
            vertical_flag_inner <= 0;
            horizontal_flag_inner <= 0;
//If vertical tick gets to 42,500,000 ticks, reset to 0 and raise flag (750ms). Same logic for horizontal.
//Only count ticks if the game isn't paused.
        end else if(ticking == 1)begin
            if(vertical_tick == 25'd42_500_000 && horizontal_tick != 25'd2_500_000) begin   //use smaller count while simulating!
                vertical_tick <= 25'd0;
                vertical_flag_inner <= 1;
            end else vertical_tick <= vertical_tick + 1;

            if(horizontal_tick == 25'd2_500_000 && vertical_tick != 25'd42_500_000) begin //use smaller count while simulating!
                horizontal_tick <= 25'd0;
                horizontal_flag_inner <= 1;
            end else horizontal_tick <= horizontal_tick + 1;

            if(horizontal_tick == 25'd2_500_000 && vertical_tick == 25'd42_500_000) begin //use smaller count while simulating!
                vertical_tick <= 25'd0;
                vertical_flag_inner <= 1;
                horizontal_tick <= 25'd0;
                horizontal_flag_inner <= 1;
            end

            if(vertical_flag_inner == 1) vertical_flag_inner <= 0;
            if(horizontal_flag_inner == 1) horizontal_flag_inner <= 0;
        end
    end

    assign vertical_flag = vertical_flag_inner;
    assign horizontal_flag = horizontal_flag_inner;
endmodule: tick_gen
