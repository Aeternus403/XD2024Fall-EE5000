`timescale 1ns / 1ps

module tb_led_breathing;

    reg clk;               // 时钟信号
    reg rst_n;             // 复位信号
    wire [9:0] leds;      // LED输出信号

    // 实例化被测试的模块
    led_breathing uut (
        .clk(clk),
        .rst_n(rst_n),
        .leds(leds)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 每10ns翻转一次，频率为50MHz
    end

    // 复位信号生成
    initial begin
        rst_n = 0;            // 初始为低电平
        #20;
        rst_n = 1;            // 复位解除
    end

    // 仿真过程
    initial begin
        // 观察LED变化
        $monitor("Time=%0t | LED output = %b", $time, leds);
        
        // 运行一段时间后结束仿真
        #10000000; // 运行100ms
        $finish; // 结束仿真
    end

endmodule

