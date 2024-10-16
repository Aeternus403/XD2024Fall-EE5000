// filename: tb_clock.v
`timescale 1ms / 1ms  // 定义时间单位

module tb_clock;

    // 仿真文件中的输入输出信号
    reg clk;           // 时钟信号
    reg reset;         // 复位信号
    wire [6:0] hex0;   // 秒的个位数的七段数码管显示
    wire [6:0] hex1;   // 秒的十位数的七段数码管显示
    wire [6:0] hex2;   // 分钟的个位数的七段数码管显示
    wire [6:0] hex3;   // 分钟的十位数的七段数码管显示

    // 实例化待测的计时器模块
    clock uut (
        .clk(clk),
        .reset(reset),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3)
    );

    // 时钟信号生成，周期为20ns（50MHz）
    always begin
        #500 clk = ~clk;  // 每0.5s翻转时钟信号
    end

    // 初始块：复位信号和仿真时间的控制
    initial begin
        // 初始化信号
        clk = 0;
        reset = 1;

        // 释放复位，在20s时，复位信号变为0
        #20000 reset = 0;
		  #1000 reset = 1;

        // 仿真持续100s
        #100000;

        // 结束仿真
        $stop;
    end

    // 监控显示输出的变化
    initial begin
        $monitor("Time: %0t | hex3=%b hex2=%b : hex1=%b hex0=%b", 
            $time, hex3, hex2, hex1, hex0);
    end

endmodule
