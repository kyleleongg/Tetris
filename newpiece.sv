module newpiece(input clk, input rst, output[2:0] piece);

logic[2:0] number;

always_ff @(posedge clk) begin
    if(~rst) begin
        number <= 0;
    end else begin
        if(number == 3'd7) begin
            number <= 0;
        end else begin
        number <= number + 1;
        end
    end
end

assign piece = number;


endmodule: newpiece
