module clk_divider(
    input clk,          // 输入时钟
    input rst_n,        // 复位信号
    output reg pwm_clk  // 输出10Hz的PWM控制时钟
);
    reg [31:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 0;
        else if (counter == 5000000) begin // 分频到10Hz
            counter <= 0;
            pwm_clk <= ~pwm_clk;
        end else
            counter <= counter + 1;
    end
endmodule
