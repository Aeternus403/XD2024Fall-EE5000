// filename: display.v
module display(
    input [3:0] value,    // 输入的 4 位数值
    output reg [6:0] seg  // 输出到七段数码管的信号
);

// 逻辑用于将 4 位的二进制数转换为七段数码管显示的信号
always @(*) begin
    case (value)
        4'b0000: seg = 7'b1000000; // 0
        4'b0001: seg = 7'b1111001; // 1
        4'b0010: seg = 7'b0100100; // 2
        4'b0011: seg = 7'b0110000; // 3
        4'b0100: seg = 7'b0011001; // 4
        4'b0101: seg = 7'b0010010; // 5
        4'b0110: seg = 7'b0000010; // 6
        4'b0111: seg = 7'b1111000; // 7
        4'b1000: seg = 7'b0000000; // 8
        4'b1001: seg = 7'b0010000; // 9
        default: seg = 7'b1111111;  // 默认不显示
    endcase
end
endmodule
