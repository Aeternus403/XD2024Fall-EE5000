module pwm (
    input clk,              // 系统时钟
    input [6:0] sw,        // 占空比输入
    output reg pwm_out      // PWM输出信号
);

    reg [19:0] count;          // 用于生成50000Hz时钟的计数器
    reg [19:0] pwm_count;      // 用于PWM输出的计数器
    reg [19:0] duty_cycle;     // 占空比计数
    reg clk_50000Hz;           // 50000Hz的时钟信号

    // 生成50000Hz时钟信号
    always @(posedge clk) begin
        if (count < 499) begin  // 50MHz / 50000Hz - 1 = 999
            count <= count + 1;
        end else begin
            count <= 0;  // 重置计数器
            clk_50000Hz <= ~clk_50000Hz;  // 翻转时钟信号
        end
    end

    // 将占空比输入转换为占空比
    always @(*) begin
        if (sw > 99) begin
            duty_cycle = 0;  // 超过100则输出0
        end else begin
            duty_cycle = sw;  // 计算占空比，范围为0到100
        end
    end

    // PWM输出逻辑
    always @(posedge clk_50000Hz) begin
        if (pwm_count < duty_cycle) begin
            pwm_out <= 1;  // 输出高电平
        end else begin
            pwm_out <= 0;  // 输出低电平
        end

        if (pwm_count < 99) begin
            pwm_count <= pwm_count + 1;  // 每个周期计数
        end else begin
            pwm_count <= 0;  // 重置计数器
        end
    end

endmodule
