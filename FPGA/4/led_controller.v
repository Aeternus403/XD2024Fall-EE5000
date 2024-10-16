module led_controller(
    input clk,
    input rst_n,
    output reg [9:0] led   // 将未打包数组改为打包形式
);

    reg [6:0] pwm_counter;
    reg [9:0] led_pattern;  // 控制LED亮度的模式

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led_pattern <= 10'b0000000001;  // 初始状态
        else
            led_pattern <= {led_pattern[8:0], led_pattern[9]};  // 右移一位
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pwm_counter <= 0;
        else
            pwm_counter <= pwm_counter + 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led <= 0;
        else
            led <= led_pattern;  // 这里是打包后的 LED 控制
    end

endmodule

