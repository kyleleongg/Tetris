//Highest level module. Will instantiate game.sv and the vga_adapter module. Will take inputs from the DE1-SoC to pass into
//game module, and produce outputs to pass to the vga adapter

module tetris(input logic CLOCK_50, input logic[3:0] KEY, input logic[9:0]SW, output logic[6:0] HEX5,
              output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
              output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
              output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
              output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

//Signal that will be the multiplex of board_colour or current_colour
    logic[2:0] board_colour, current_colour;

//Signals used to plot on the screen
    logic[7:0] x;
    logic[6:0] y;

//Signal used as input to board so that we can retrieve the colour in each cell
    logic[4:0] vga_board_y;
    logic[3:0] vga_board_x;
    logic vga_occupied;

//Signals taken from game.sv so we know the current x y values for plotting the active piece
    logic[5:0] current_x0, current_x1, current_x2, current_x3, current_y0, current_y1, current_y2, current_y3;

    logic gameover;
    

    enum{RESET, WAITTOSTART, SCANDRAW, GAMEOVER} state;

    always_ff @(posedge CLOCK_50) begin
        if(~SW[9]) begin
            state <= RESET;
            x <= 8'd0;
            y <= 7'd0;
            HEX5 <= 7'b0001001;
            VGA_PLOT <= 1;
        end else begin
            case(state)
        
        //When the game is reset, draw black to everywhere on screen, except draw the white side bars
                RESET: begin
                    y <= y + 1;
                    if(y == 7'd119) begin
                        x <= x + 1;
                        y <= 7'd0;
                        if(x == 8'd159) begin
                            x <= 8'd3;
                            y <= 7'd0;
                            state <= WAITTOSTART;
                        end
                    end 

                end

                WAITTOSTART: begin
                    if(~SW[8]) begin
                        state <= SCANDRAW;
                    end
                end

        //Scan the entire playing area and plot the colours if a piece exists there (done combinationally)
                SCANDRAW: begin
                    if(gameover) begin
                        state <= GAMEOVER;
                    end else begin
                        x <= x + 1;
                        if(x == 8'd62) begin
                            x <= 8'd3;
                            y <= y + 1;
                            if(y == 7'd119) begin
                                y <= 7'd0;
                                x <= 8'd3;
                            end
                        end
                    end
                end

                GAMEOVER: begin 

                end

            endcase
        end
    end

//Direct mapping from our large 60x120 pixel grid to the board grid (10x20) 
    always_comb begin
        vga_board_x = (x - 3) / 6;
        vga_board_y = y / 6;
        VGA_COLOUR = 3'b000;

    //Use the case operator to combinationally assign colours so that colour assignment isn't one state behind
        case(state)

        //Set colour to 1 so that we draw two white bars which will be our board bounds
            RESET: begin
                if((x <= 8'd2) || (x >= 8'd63 && x <= 8'd65)) begin
                    VGA_COLOUR = 3'b111;
                end else begin
                    VGA_COLOUR = 3'b000;
                end
            end

            WAITTOSTART: begin
            end

        //If the screen pixel we're checking falls on an occupied board index OR the current piece's index, plot it. 
            SCANDRAW: begin
                if(vga_occupied) begin
                    VGA_COLOUR = board_colour;
                end else if((vga_board_x == current_x0 && vga_board_y == current_y0) || 
                            (vga_board_x == current_x1 && vga_board_y == current_y1) ||
                            (vga_board_x == current_x2 && vga_board_y == current_y2) || 
                            (vga_board_x == current_x3 && vga_board_y == current_y3)) begin
                                VGA_COLOUR = current_colour;
                            end
                        else begin
                            VGA_COLOUR = 3'b000;
                        end
            end

            GAMEOVER: begin
            end
        endcase
    end

    assign VGA_X = x;
    assign VGA_Y = y;





//Instantiate game module
    game g(
        .clk(CLOCK_50),
        .rst(SW[9]),
        .notstart(SW[8]),
        .pause(SW[7]),
        .notleft(KEY[3]),
        .notright(KEY[2]),
        .notrotate(KEY[1]),
        .notfastdrop(KEY[0]),
        .gameover(gameover),
        .vga_board_x(vga_board_x),
        .vga_board_y(vga_board_y),
        .vga_occupied(vga_occupied),
        .board_colour(board_colour),
        .current_colour(current_colour),
        .vga_x0(current_x0),
        .vga_x1(current_x1),
        .vga_x2(current_x2),
        .vga_x3(current_x3),
        .vga_y0(current_y0),
        .vga_y1(current_y1),
        .vga_y2(current_y2),
        .vga_y3(current_y3)
    );


//Instantiate VGA adapter
    vga_adapter #(.RESOLUTION("160x120"))va 
    (
        .resetn(SW[9]),
        .clock(CLOCK_50),
        .colour(VGA_COLOUR),
        .x(VGA_X),  
        .y(VGA_Y),
        .plot(VGA_PLOT),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(),
        .VGA_SYNC(),
        .VGA_CLK(VGA_CLK)
    ); 




endmodule: tetris


