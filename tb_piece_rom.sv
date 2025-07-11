module tb_piece_rom();

//Declare inputs as reg and outputs as wire
reg[2:0] piece_id;
reg[1:0] rotation;
reg[1:0] row_index;
wire[3:0] piece_row;
wire[23:0] piece_rgb;

piece_rom dut(
    .piece_id(piece_id),
    .rotation(rotation),
    .row_index(row_index),
    .piece_row(piece_row),
    .piece_rgb(piece_rgb)
);

initial begin
    #10;
    piece_id = 3'b000;
    rotation = 2'b00;
    row_index = 2'b00;
    #10;
    rotation = 2'b10;
    #10;
    rotation = 2'b11;
    #10;

    piece_id = 3'b011;
    #10;
    $finish;
end


endmodule: tb_piece_rom
