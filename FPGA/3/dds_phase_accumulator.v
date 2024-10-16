module dds_phase_accumulator(
    input i_sys_clk,                      // 系统时钟输入
    input i_sys_rst,                      // 系统复位输入
    input [25:0] i_dds_phase_accumulator_word, // 相位累加器控制字
    output reg [25:0] o_dds_phase_accumulator  // 相位累加器输出
);


// 在时钟上升沿触发
always @(posedge i_sys_clk or negedge i_sys_rst) begin
    if (!i_sys_rst) begin
        // 复位时将相位累加器清零
        o_dds_phase_accumulator <= 26'd0;
    end else begin
        // 否则每个时钟周期将相位累加器与控制字相加
        o_dds_phase_accumulator <= o_dds_phase_accumulator + i_dds_phase_accumulator_word;
    end
end


endmodule
