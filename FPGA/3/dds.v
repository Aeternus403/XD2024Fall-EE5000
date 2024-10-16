module dds (
    input i_sys_clk,                               // 系统时钟输入
    input i_sys_rst,                               // 系统复位输入    
    output [9:0] o_sine_wave                       // 输出的正弦波数据
);

    // 相位累加器输出
    wire [25:0] phase_accum_output;
	 localparam i_dds_phase_accumulator_word = 26'd859008; // 相位累加器控制字


    // 实例化相位累加器模块
    dds_phase_accumulator phase_accu (
        .i_sys_clk(i_sys_clk),
        .i_sys_rst(i_sys_rst),
        .i_dds_phase_accumulator_word(i_dds_phase_accumulator_word),
        .o_dds_phase_accumulator(phase_accum_output)
    );

    // 实例化 ROM 模块，使用相位累加器的高位部分作为地址
    rom rom (
        .clock(i_sys_clk),
        .address(phase_accum_output[25:16]),  // 使用相位累加器的高 10 位作为地址
        .q(o_sine_wave)                       // 从 ROM 输出正弦波数据
    );

endmodule
