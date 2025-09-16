//This module is in charge of defining and keeping track of the 2D board array. Will have one array where each entry will either be 
// a 0 or an RGB value (if it's an RGB value then we know the cell is occupied)

module board(input rst, input clk, input[3:0] board_x, input[4:0] board_y, input[3:0] vga_board_x, input[4:0] vga_board_y,
input[2:0] write_colour, input validate_start, output vga_occupied,
input write_done, input[5:0] x0, input[5:0] x1, input[5:0] x2, input[5:0] x3, input[5:0] y0, input[5:0] y1, 
input[5:0] y2, input[5:0] y3, input[5:0] future_x0, input[5:0] future_x1, input[5:0] future_x2, input[5:0] future_x3,
input[5:0] future_y0, input[5:0] future_y1, input[5:0] future_y2, input[5:0] future_y3,output occupied, output[1:0] lines_cleared, 
output[2:0] output_colour, output validate_done_flag, output left_allowed, output right_allowed, output crash, output board_rdy,
output rotation_allowed);

    logic[2:0] board[0:19][0:9]; //y,x 2D memory array
    logic[4:0] x, y;    //Buffers so that we can initialize board as all 0's
    logic board_rdy_inner, occupied_inner, validate_done_inner, crash_inner, left_allowed_inner, right_allowed_inner, vga_occupied_inner;
    logic rotation_allowed_inner;
    logic[2:0] colour_inner;
    logic[1:0] lines_cleared_inner;
    logic[2:0] count;
    logic signed[5:0] write_row, read_row; //2 pointers for clear row 
    logic[2:0] output_colour_inner;
    logic full; //Flag for current scanning row is full or not 
    
enum{RESET, WAIT, WRITE, CHECKLINE, FILLZERO, COPYLINE} state;

    always_ff @(posedge clk) begin
        if(~rst) begin
            validate_done_inner <= 0;
            x <= 5'd0;
            y <= 5'd0;
            board_rdy_inner <= 0;
            state <= RESET;
        end else begin
            case(state)

//Loops through every x and y and writes 0 to the cell
                RESET: begin
                    board[y][x] <= 24'd0;
                    x <= x + 1;
                    if(x == 5'd9) begin
                        x <= 5'd0;
                        y <= y + 1;
                        if(y == 5'd19) begin
                            state <= WAIT;
                            board_rdy_inner <= 1;
                        end
                    end
                end

//Sit in an idle state until game goes into the validate state. Then write and check/clear lines
                WAIT: begin
                    validate_done_inner <= 0;
                    if(validate_start) begin
                        state <= WRITE;
                        count <= 3'd0;
                    end
                    else state <= WAIT;
                end

//Blindly write the colour values into the desired location in the board matrix. Check for full lines after game.sv tells us that it's
//done writing to board.               
                WRITE: begin
                    count <= count + 1;
                    if(count == 3'd4) begin
                        state <= CHECKLINE;
                        lines_cleared_inner <= 2'b00;
                        write_row <= 6'd19;
                        read_row <= 6'd19;
                        x <= 5'd0;
                        full <= 1;
                    end
                    if(count == 3'd0) board[y0][x0] <= write_colour;
                    if(count == 3'd1) board[y1][x1] <= write_colour;
                    if(count == 3'd2) board[y2][x2] <= write_colour;
                    if(count == 3'd3) board[y3][x3] <= write_colour;
                end

//Start write_row @ 19. Iterate read_row from 19 to 0. For each read_row, if row is full skip it. If it's not full, copy that row
//to write_row and then decrement write_row.
//This approach is literally two-pointer from data structures and algorithms***
                CHECKLINE: begin
                    if(read_row == -6'd1) begin
                        state <= FILLZERO;
                        x <= 6'd0;
                    end else begin
                        x <= x + 1;
                        if(x == 6'd0) full <= 1;
                    
                    //If any value is 0 in a row, full = 0
                        if(board[read_row][x] == 0) begin
                            full <= 0;
                        end

                        if(x == 6'd10 && full == 1) begin
                            read_row <= read_row - 1;
                            //x <= 6'd0;
                        end

                        if(x == 6'd10 && full == 0) begin
                            state <= COPYLINE;
                            x <= 6'd0;
                        end
                    end
                end

//Every time a line isn't full, copy read_row row into write_row row.  
                COPYLINE: begin
                    if(x == 6'd10) begin
                        state <= CHECKLINE;
                        write_row <= write_row - 1;
                        read_row <= read_row - 1;
                        x <= 6'd0;
                        full <= 1;
                    end else begin
                        x <= x + 1;
                        board[write_row][x] <= board[read_row][x];
                    end
                end

//Now fill the remaining lines above write_row with 0's
                FILLZERO: begin
                    if(write_row == -6'd1) begin
                        state <= WAIT;
                        validate_done_inner <= 1;
                    end else begin
                        x <= x + 1;
                        board[write_row][x] <= 24'd0;
                        if(x == 10) begin
                            write_row <= write_row - 1;
                            x <= 6'd0;
                        end
                    end
                end

            endcase
        end
    end

//Combinational block that returns whether cell being checked is occupied or not, and if so, the rgb colour that is in it
    always_comb begin
        if(board[board_y][board_x] != 24'd0) begin
            occupied_inner = 1;
        end else begin
            occupied_inner = 0;
        end

        if(board[vga_board_y][vga_board_x] != 24'd0) begin
            vga_occupied_inner = 1;
            output_colour_inner = board[vga_board_y][vga_board_x];
        end else begin
            vga_occupied_inner = 0;
            output_colour_inner = 3'd0;
        end

//Logic for handling state transition from ACTIVE_PIECE to VALIDATE
    if ((board[y0+1][x0] != 24'd0) || (board[y1+1][x1] != 24'd0) || (board[y2+1][x2] != 24'd0) || (board[y3+1][x3] != 24'd0) ||
        (y0+1 == 6'd20) || (y1+1 == 6'd20) || (y2+1 == 6'd20) || (y3+1 == 6'd20)) begin
            crash_inner = 1;
        end else begin
            crash_inner = 0;
        end

//Logic for allowing left/right movements and rotations
        if((board[y0][x0+1] == 24'd0) && (board[y1][x1+1] == 24'd0) && (board[y2][x2+1] == 24'd0) && (board[y3][x3+1] == 24'd0) &&
            (x0+1 != 6'd10) && (x1+1 != 6'd10) && (x2+1 != 6'd10) && (x3+1 != 6'd10)) begin
                right_allowed_inner = 1;
            end else begin
                right_allowed_inner = 0;
            end

        if((board[y0][x0-1] == 24'd0) && (board[y1][x1-1] == 24'd0) && (board[y2][x2-1] == 24'd0) && (board[y3][x3-1] == 24'd0) &&
            (x0-1 <= 6'd9) && (x0-1 >= 6'd0) && (x1-1 <= 6'd9) && (x1-1 >= 6'd0) && (x2-1 <= 6'd9) && (x2-1 >= 6'd0) && 
            (x3-1 <= 6'd9) && (x3-1 >= 6'd0)) begin
                left_allowed_inner = 1;
            end else begin
                left_allowed_inner = 0;
            end

        if((board[future_y0][future_x0] == 24'd0) && (board[future_y1][future_x1] == 24'd0) && (board[future_y2][future_x2] == 24'd0) &&
           (board[future_y3][future_x3] == 24'd0) && (future_x0 <= 6'd9) && (future_x0 >= 6'd0) && (future_x1 <= 6'd9) && 
           (future_x1 >= 6'd0) && (future_x2 <= 6'd9) && (future_x2 >= 6'd0) && (future_x3 <= 6'd9) && (future_x3 >= 6'd0) && 
           (future_y0 >= 6'd0) && (future_y0 <= 6'd19) && (future_y1 >= 6'd0) && (future_y1 <= 6'd19) && 
           (future_y2 >= 6'd0) && (future_y2 <= 6'd19) && (future_y3 >= 6'd0) && (future_y3 <= 6'd19)) begin
            rotation_allowed_inner = 1;
           end else begin
            rotation_allowed_inner = 0;
           end
    end

    assign validate_done_flag = validate_done_inner;
    assign occupied = occupied_inner;
    assign output_colour = output_colour_inner;
    assign crash = crash_inner;
    assign left_allowed = left_allowed_inner;
    assign right_allowed = right_allowed_inner;
    assign rotation_allowed = rotation_allowed_inner;
    assign board_rdy = board_rdy_inner;
    assign vga_occupied = vga_occupied_inner;
        
endmodule: board
