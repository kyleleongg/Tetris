//This module will be used to spawn in any pieces matrix and rgb values given a piece ID, rotation, and row_index
//Use a row index so that we read the matrix one row at a time**

//Note that piece_row and row are bit indexed as [0:3] so that top left bit is 0,0 and not 3,0. It matches board.sv!
module piece_rom(input[2:0] piece_id, input[1:0] rotation, input[1:0] row_index, output[0:3] piece_row, output[2:0] piece_rgb);
    
    logic[0:3] row;
    logic[2:0] piece_rgb_inner;

//FOR NOW ALL RGB'S ARE JUST 1 2 3 4 5 6 7
    always_comb begin
        case(piece_id)

//I piece
            3'b000: begin
                piece_rgb_inner = 3'b011;
                if(rotation == 2'b01 || rotation == 2'b11) begin
                    case(row_index)
                        2'b00: row = 4'b0010;
                        2'b01: row = 4'b0010;
                        2'b10: row = 4'b0010;
                        2'b11: row = 4'b0010;
                    endcase
                end else begin
                    case(row_index)
                        2'b00: row = 4'b1111;
                        2'b01: row = 4'b0000;
                        2'b10: row = 4'b0000;
                        2'b11: row = 4'b0000;
                    endcase
                end
            end

//J piece
            3'b001: begin
                piece_rgb_inner = 3'b001;
                case(rotation)
                    2'b00: begin
                        case(row_index)
                            2'b00: row = 4'b0100;
                            2'b01: row = 4'b0111;
                            2'b10: row = 4'b0000;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b01: begin
                        case(row_index)
                            2'b00: row = 4'b0010;
                            2'b01: row = 4'b0010;
                            2'b10: row = 4'b0110;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b10: begin
                        case(row_index)
                            2'b00: row = 4'b0000;
                            2'b01: row = 4'b0111;
                            2'b10: row = 4'b0001;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b11: begin
                        case(row_index)
                            2'b00: row = 4'b0011;
                            2'b01: row = 4'b0010;
                            2'b10: row = 4'b0010;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                endcase
            end

//L piece
            3'b010: begin
                piece_rgb_inner = 3'b111;
                case(rotation)
                    2'b00: begin
                        case(row_index)
                            2'b00: row = 4'b0001;
                            2'b01: row = 4'b0111;
                            2'b10: row = 4'b0000;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b01: begin
                        case(row_index)
                            2'b00: row = 4'b0110;
                            2'b01: row = 4'b0010;
                            2'b10: row = 4'b0010;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b10: begin
                        case(row_index)
                            2'b00: row = 4'b0000;
                            2'b01: row = 4'b0111;
                            2'b10: row = 4'b0100;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b11: begin
                        case(row_index)
                            2'b00: row = 4'b0010;
                            2'b01: row = 4'b0010;
                            2'b10: row = 4'b0011;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                endcase
            end

//Square piece 
            3'b011: begin
                piece_rgb_inner = 3'b110;
                case(row_index)
                    2'b00: row = 4'b0110;
                    2'b01: row = 4'b0110;
                    2'b10: row = 4'b0000;
                    2'b11: row = 4'b0000;
                endcase
            end

//S piece
            3'b100: begin
                piece_rgb_inner = 3'b010;
                if(rotation == 2'b00 || rotation == 2'b10) begin
                    case(row_index)
                        2'b00: row = 4'b0011;
                        2'b01: row = 4'b0110;
                        2'b10: row = 4'b0000;
                        2'b11: row = 4'b0000;
                    endcase
                end else begin
                    case(row_index)
                        2'b00: row = 4'b0100;
                        2'b01: row = 4'b0110;
                        2'b10: row = 4'b0010;
                        2'b11: row = 4'b0000;
                    endcase
                end
            end

//T piece
            3'b101: begin
                piece_rgb_inner = 3'b101;
                case(rotation)
                    2'b00: begin
                        case(row_index)
                            2'b00: row = 4'b0010;
                            2'b01: row = 4'b0111;
                            2'b10: row = 4'b0000;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b01: begin
                        case(row_index)
                            2'b00: row = 4'b0010;
                            2'b01: row = 4'b0110;
                            2'b10: row = 4'b0010;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b10: begin
                        case(row_index)
                            2'b00: row = 4'b0000;
                            2'b01: row = 4'b0111;
                            2'b10: row = 4'b0010;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                    2'b11: begin
                        case(row_index)
                            2'b00: row = 4'b0010;
                            2'b01: row = 4'b0011;
                            2'b10: row = 4'b0010;
                            2'b11: row = 4'b0000;
                        endcase
                    end
                endcase
            end

//Z piece
            3'b110: begin
                piece_rgb_inner = 3'b100;
                if(rotation == 2'b00 || rotation == 2'b10) begin
                    case(row_index)
                        2'b00: row = 4'b0110;
                        2'b01: row = 4'b0011;
                        2'b10: row = 4'b0000;
                        2'b11: row = 4'b0000;
                    endcase
                end else begin
                    case(row_index)
                        2'b00: row = 4'b0001;
                        2'b01: row = 4'b0011;
                        2'b10: row = 4'b0010;
                        2'b11: row = 4'b0000;
                    endcase
                end
            end

            default: begin
                row = 4'b0000;
                piece_rgb_inner = 3'b000;
            end
        endcase
    end

    assign piece_row = row;
    assign piece_rgb = piece_rgb_inner;

endmodule: piece_rom

