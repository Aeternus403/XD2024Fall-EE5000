// filename: clock.v
module clock(
    input clk,          // 时钟信号
    input reset,        // 复位信号
    output [6:0] hex0,  // 显示秒的个位
    output [6:0] hex1,  // 显示秒的十位
    output [6:0] hex2,  // 显示分的个位
    output [6:0] hex3   // 显示分的十位
);

reg [5:0] sec = 0;  // 秒的计数器，范围 0-59
reg [5:0] min = 0;  // 分钟的计数器，范围 0-59

reg [25:0] clk_divider = 0;  // 时钟分频器（假设系统时钟为50MHz）
reg clk_1Hz = 0;              // 1Hz 时钟信号

// 时钟分频器，产生 1Hz 的时钟信号
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        clk_divider <= 0;
        clk_1Hz <= 0;
    end else begin
        if (clk_divider == 25_000_000 - 1) begin
            clk_divider <= 0;
            clk_1Hz <= ~clk_1Hz;  // 翻转 clk_1Hz，产生 1Hz 的时钟信号
        end else begin
            clk_divider <= clk_divider + 1;
        end
    end
end

// 计时逻辑，使用 1Hz 时钟信号
always @(posedge clk_1Hz or negedge reset) begin
    if (!reset) begin  
        sec <= 0;
        min <= 0;
    end else if (sec == 59) begin
        sec <= 0;
        if (min == 59)
            min <= 0;
        else
            min <= min + 1;
    end else begin
        sec <= sec + 1;
    end
end

// 实例化 display 模块，分别显示分钟和秒钟
display display_sec_ones (.value(sec % 10), .seg(hex0)); // 秒的个位
display display_sec_tens (.value(sec / 10), .seg(hex1)); // 秒的十位
display display_min_ones (.value(min % 10), .seg(hex2)); // 分钟的个位
display display_min_tens (.value(min / 10), .seg(hex3)); // 分钟的十位

endmodule

