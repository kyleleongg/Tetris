//This will be the control logic for the main events of the game. Will deal with user inputs, pass this to other modules,
//clear lines, etc. 

//Global spawn constants for easy access
`define SPAWN_X 3
`define SPAWN_Y 0

module game(input clk, input rst, input notstart, input pause, input notleft, input notright, input notrotate, input notfastdrop,
            input[3:0] vga_board_x, input[4:0] vga_board_y, output vga_occupied,
            output logic gameover, output logic[2:0] board_colour, output [2:0] current_colour, output[5:0] vga_x0, output[5:0] vga_x1,
            output[5:0] vga_x2, output[5:0] vga_x3, output[5:0] vga_y0, output[5:0] vga_y1, output[5:0] vga_y2, output[5:0] vga_y3);

//newpiece logic
    logic[2:0] piece, nextpiece;

//score logic
    logic[23:0] score;

//Falling piece logic
    logic vertical_flag, horizontal_flag;
    logic[2:0] current_piece_id, next_piece_id, count;
    logic[1:0] rotation, row_index;
    logic[3:0] piece_row, board_x, x_fetch, check_x;
    logic[4:0] board_y, y_fetch, check_y;
    logic[5:0] current_x[3:0], current_y[3:0]; //Absolute values of all 4 x,y's of each piece. 
    logic signed[5:0] relative_x, relative_y;  //Relative signals helps with reassigning the piece after a rotation
    logic[5:0] future_x[3:0], future_y[3:0];   //Future x,y if a rotation were to happen


//Board logic
    logic board_rdy, validate_start, validate_done_flag, write_done, occupied, rotation_allowed, movement_allowed; 
    logic left_allowed, right_allowed, crash, fastdrop_allowed;
    logic[2:0] current_piece_rgb;


//Main FSM
enum{WAIT, ACTIVE_PIECE, VALIDATE, GAMEOVER, PAUSE} state;

//Subset of states inside active piece for reading from rom, spawning, and moving
enum{AP_INIT, AP_FETCH, AP_SPAWN, AP_MOVE_ALLOWED, AP_MOVE_NOT_ALLOWED, AP_ROTATION, AP_ROTATE_FETCH, AP_FASTDROP} ap_state; 

    always_ff @(posedge clk) begin
        if(~rst) begin
            gameover <= 0;
            state <= WAIT;
 //           active_piece <= 0;
        end else begin
            case(state)

//Only allowed to start if the board is reset and ready!
                WAIT: begin
                    if(~notstart && board_rdy && notfastdrop) begin
                        state <= ACTIVE_PIECE;
                        ap_state <= AP_INIT;
                    end else state <= WAIT;
                end

//Spawn new piece then immediately check if collision happens between pieces, if not constantly check horizontal and vertical flag
//until a vert tick happens and there would be a collision, then transition to VALIDATE
                ACTIVE_PIECE: begin

                //Only allow fast drops if it is deasserted after every time it's pressed
                    if(notfastdrop) begin
                        fastdrop_allowed <= 1;
                    end

                    case(ap_state)

//Lock piece into a register, set count to 0, etc. Prep for fetching from ROM
                        AP_INIT: begin
                                count <= 3'b000;
                                x_fetch <= 4'b000;
                                y_fetch <= 5'b000;
                                current_piece_id <= piece;
                                rotation <= 2'b00;
                                row_index <= 2'b00;
                                fastdrop_allowed <= 1;
                                relative_x <= `SPAWN_X;
                                relative_y <= `SPAWN_Y;
                                ap_state <= AP_FETCH;
                        end

//Scan 4x4 matrix of piece ROM to store all 4 blocks from current piece into active registers
                        AP_FETCH: begin
                            if(count == 3'd4) begin
                                count <= 3'd0;
                                ap_state <= AP_MOVE_ALLOWED;
                            end else begin
                                
                                if(x_fetch == 4'd4) begin
                                    row_index <= row_index + 1;
                                    x_fetch <= 4'd0;
                                end 
                                else begin 
                                    x_fetch <= x_fetch + 1;
                                    if(piece_row[x_fetch] == 1) begin
                                        current_x[count] <= x_fetch + `SPAWN_X;
                                        current_y[count] <= row_index + `SPAWN_Y;
                                        count <= count + 1;
                        //While in this state, board_x is assigned to x_fetch + spawn_x (same for board_y)
                                        if(occupied) begin
                                            state <= GAMEOVER;
                                            gameover <= 1;
                                        end
                                    end
                                end
                            end
                        end


//Deals with movement and rotation. Hierarchy of priority of vertical > horiontal > rotation
//MOVE_ALLOWED allows horizontal movement, MOVE_NOT_ALLOWED doesn't allow for horizontal movement, will return to allowed state
//when both notleft, notright, and notrotate are deasserted (only clicks allowed, holding doesn't work).
                        AP_MOVE_ALLOWED: begin
                            if(vertical_flag) begin
                                if(crash) begin
                                    state <= VALIDATE;
                                    validate_start <= 1;
                                end 
                                else begin
                                    current_y[0] <= current_y[0] + 1;
                                    current_y[1] <= current_y[1] + 1;
                                    current_y[2] <= current_y[2] + 1;
                                    current_y[3] <= current_y[3] + 1;
                                    relative_y <= relative_y + 1;
                                end
                            end 
                            else begin
                                if(horizontal_flag) begin
                                    if(!notleft && left_allowed) begin
                                        current_x[0] <= current_x[0] - 1;
                                        current_x[1] <= current_x[1] - 1;
                                        current_x[2] <= current_x[2] - 1;
                                        current_x[3] <= current_x[3] - 1;
                                        relative_x <= relative_x - 1;
                                        ap_state <= AP_MOVE_NOT_ALLOWED;
                                    end
                                    if(!notright && right_allowed) begin
                                        current_x[0] <= current_x[0] + 1;
                                        current_x[1] <= current_x[1] + 1;
                                        current_x[2] <= current_x[2] + 1;
                                        current_x[3] <= current_x[3] + 1;
                                        relative_x <= relative_x + 1;
                                        ap_state <= AP_MOVE_NOT_ALLOWED;
                                    end
                                end
                                else begin
                                    if(!notrotate) begin
                                        rotation <= (rotation + 1) % 4;
                                        count <= 2'd0;
                                        x_fetch <= 4'b000;
                                        y_fetch <= 5'b000;
                                        ap_state <= AP_ROTATE_FETCH;
                                    end else begin
                                        if(!notfastdrop && !crash && fastdrop_allowed) begin
                                            fastdrop_allowed <= 0;
                                            ap_state <= AP_FASTDROP;
                                        end
                                    end
                                end
                                
                            end     
                        end

                        AP_MOVE_NOT_ALLOWED: begin
                            if(vertical_flag) begin
                                if(crash) begin
                                    state <= VALIDATE;
                                    validate_start <= 1;
                                end 
                                else begin
                                    current_y[0] <= current_y[0] + 1;
                                    current_y[1] <= current_y[1] + 1;
                                    current_y[2] <= current_y[2] + 1;
                                    current_y[3] <= current_y[3] + 1;
                                    relative_y <= relative_y + 1;
                                end
                            end
                            if(notright && notleft && notrotate && notfastdrop) begin
                                ap_state <= AP_MOVE_ALLOWED;
                            end
                        end

            //Find where all 4 pieces WOULD be if rotate did happen
                        AP_ROTATE_FETCH: begin
                            if(count == 3'd4) begin
                                count <= 3'd0;
                                ap_state <= AP_ROTATION;
                            end else begin
                                
                                if(x_fetch == 4'd4) begin
                                    row_index <= row_index + 1;
                                    x_fetch <= 4'd0;
                                end 
                                else begin 
                                    x_fetch <= x_fetch + 1;
                                    if(piece_row[x_fetch] == 1) begin
                                        future_x[count] <= x_fetch + relative_x;
                                        future_y[count] <= row_index + relative_y;
                                        count <= count + 1; 
                                    end
                                end
                            end
                        end

            //If the  future rotated pieces are all valid, then set them as current, if rotation wasn't allowed, -1 cuz we added 1 b4.
                        AP_ROTATION: begin
                            ap_state <= AP_MOVE_NOT_ALLOWED;
                            if(rotation_allowed) begin
                                current_x[0] <= future_x[0];
                                current_x[1] <= future_x[1];
                                current_x[2] <= future_x[2];
                                current_x[3] <= future_x[3];
                                current_y[0] <= future_y[0];
                                current_y[1] <= future_y[1];
                                current_y[2] <= future_y[2];
                                current_y[3] <= future_y[3];
                            end else begin
                                rotation <= (rotation - 1) % 4;
                            end
                        end

            //Continously drop the piece until there will be a crash in the next cycle, then lock in the piece by going to validate
                        AP_FASTDROP: begin
                            if(crash) begin
                                state <= VALIDATE;
                                validate_start <= 1;
                            end else begin
                                current_y[0] <= current_y[0] + 1;
                                current_y[1] <= current_y[1] + 1;
                                current_y[2] <= current_y[2] + 1;
                                current_y[3] <= current_y[3] + 1;
                            end
                        end
                    endcase

                end

//Passes work to board. Writes piece into the array, checks for full lines + shifts board down. When board is done, gets signal 
//and moves back to activepiece state
                VALIDATE: begin
                    validate_start <= 0;
                    if(validate_done_flag) begin
                        state <= WAIT;
                    end          
                end

            endcase
        end
    end

    always_comb begin
 //       active_piece = 0;
   //     validate_start = 0;

        case(state)

            WAIT: begin
            end

            ACTIVE_PIECE: begin
 //               active_piece = 1;
            end


            VALIDATE: begin
 //               validate_start = 1;
            end

            GAMEOVER: begin
            end

//Ticking pause taken care of in tick_gen instantiation
            PAUSE: begin
            end

        endcase
    end

    assign board_x = (ap_state == AP_FETCH) ? (x_fetch + `SPAWN_X) : check_x;
    assign board_y = (ap_state == AP_FETCH) ? (row_index + `SPAWN_Y) : check_y;
    assign current_colour = current_piece_rgb;
    assign vga_x0 = current_x[0];
    assign vga_x1 = current_x[1];
    assign vga_x2 = current_x[2];
    assign vga_x3 = current_x[3];
    assign vga_y0 = current_y[0];
    assign vga_y1 = current_y[1];
    assign vga_y2 = current_y[2];
    assign vga_y3 = current_y[3];



//Instantiate newpiece module. Note that np will run on the same reset as game because it should constantly output "random" pieces.
newpiece np(
    .clk(clk),
    .rst(rst),
    .piece(piece),
    .next(nextpiece)
);

//Instantiate piece_rom. 
piece_rom pr(
    .piece_id(current_piece_id),
    .rotation(rotation),
    .row_index(row_index),
    .piece_row(piece_row),
    .piece_rgb(current_piece_rgb)
);


//Instantiate tick_gen. Note how we enable ticking
tick_gen tg(
    .clk(clk),
    .rst(rst),
    .ticking(((state == ACTIVE_PIECE) && (ap_state != AP_ROTATE_FETCH) && (ap_state != AP_FASTDROP))),
    .vertical_flag(vertical_flag),
    .horizontal_flag(horizontal_flag)
);


//Instantiate board module
board b(
    .clk(clk),
    .rst(rst),
    .board_rdy(board_rdy),
    .board_x(board_x),
    .board_y(board_y),
    .vga_board_x(vga_board_x),
    .vga_board_y(vga_board_y),
    .vga_occupied(vga_occupied),
    .x0(current_x[0]),
    .x1(current_x[1]),
    .x2(current_x[2]),
    .x3(current_x[3]),
    .y0(current_y[0]),
    .y1(current_y[1]),
    .y2(current_y[2]),
    .y3(current_y[3]),
    .future_x0(future_x[0]),
    .future_x1(future_x[1]),
    .future_x2(future_x[2]),
    .future_x3(future_x[3]),
    .future_y0(future_y[0]),
    .future_y1(future_y[1]),
    .future_y2(future_y[2]),
    .future_y3(future_y[3]),
    .left_allowed(left_allowed),
    .right_allowed(right_allowed),
    .rotation_allowed(rotation_allowed),
    .write_colour(current_piece_rgb),
    .validate_start(validate_start),
    .write_done(write_done),
    .validate_done_flag(validate_done_flag),
    .crash(crash),
    .occupied(occupied),
    .lines_cleared(),
    .output_colour(board_colour)
);

endmodule: game
