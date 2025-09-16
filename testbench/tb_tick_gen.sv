module tb_tick_gen();

//Declare inputs as reg and outputs as wire:
reg clk;
reg rst;
wire vertical_flag;
wire horizontal_flag;


tick_gen dut (
    .clk(clk),
    .rst(rst),
    .vertical_flag(vertical_flag),
    .horizontal_flag(horizontal_flag)
);

initial begin
    clk = 0; #1;
    forever begin
        clk = 1; #1;
        clk = 0; #1;
    end
end

initial begin
    rst = 1;
    #10;
    rst = 0;
    #10;
    rst = 1;
    #1100;
    $finish;
end



endmodule: tb_tick_gen

