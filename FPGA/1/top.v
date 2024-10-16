// filename: top.v
module top(
    input clk,
    input reset,
    output [6:0] hex0,
    output [6:0] hex1,
    output [6:0] hex2,
    output [6:0] hex3
);

clock u_clock (
    .clk(clk),
    .reset(reset),
    .hex0(hex0),
    .hex1(hex1),
    .hex2(hex2),
    .hex3(hex3)
);

endmodule
