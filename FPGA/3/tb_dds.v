`timescale 1ns / 1ps

module tb_dds;

    // 测试信号
    reg i_sys_clk;                                    // 系统时钟
    reg i_sys_rst;                                    // 系统复位
    reg [25:0] i_dds_phase_accumulator_word;         // 相位累加器控制字
    wire [9:0] o_sine_wave;                          // 输出的正弦波

    // 实例化被测试模块
    dds uut (
        .i_sys_clk(i_sys_clk),
        .i_sys_rst(i_sys_rst),
        .i_dds_phase_accumulator_word(i_dds_phase_accumulator_word),
        .o_sine_wave(o_sine_wave)
    );

    // 时钟生成
    initial begin
        i_sys_clk = 0;
        forever #5 i_sys_clk = ~i_sys_clk; // 20ns周期
    end

    // 测试序列
    initial begin
        // 初始化
        i_sys_rst = 1;                          // 复位
        i_dds_phase_accumulator_word = 26'd1;  // 控制字初始化

        // 复位周期
        #10;
        i_sys_rst = 0;                          // 释放复位

        // 运行一段时间
        repeat (100) begin
            #20;                                // 每次循环20ns
            // 这里可以根据需要修改控制字的值
            i_dds_phase_accumulator_word = 26'd6711; // 设定累加器控制字
        end

        // 停止仿真
        #100;
        $finish;
    end

    // 输出监视
    initial begin
        $monitor("Time: %0t | o_sine_wave: %b | phase_accum_output: %b", 
                  $time, o_sine_wave, uut.phase_accum_output);
    end
endmodule
