//This module is in charge of generating "random" new piece. This will be achieved by cycling through a 50MHz clock
//There are 7 different pieces in tetris, hence 7 possible outputs. 
module newpiece(input clk, input rst, output[2:0] piece, output[2:0] next);

logic[2:0] number, nextpiece;

always_ff @(posedge clk) begin
    if(~rst) begin
        number <= 0;
    end else begin
        if(number == 3'd6) begin
            number <= 0;
        end else begin
        number <= number + 1;
        end
    end
end

always_comb begin
    if(number == 3'd5) begin
        nextpiece = 3'd0;
    end else begin
        nextpiece = number + 2;
    end
end


assign piece = number;
assign next = nextpiece;


endmodule: newpiece
