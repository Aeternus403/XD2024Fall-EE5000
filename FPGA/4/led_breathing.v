module led_breathing (
    input clk,      // 时钟信号
    input rst_n,    // 复位信号，低电平有效
    output wire pwm_out [0:9]  // 定义 10 个 7 位的输出端口
);
    reg [6:0] led [9:0];  // 定义一个 10 元素的数组，每个元素为 7 位，表示每个 LED 的亮度

    reg [6:0] pwm_duty [0:3];  // 4个不同亮度的占空比
    reg [23:0] counter;        // 用于分频计数
    reg clock_10Hz;           // 10Hz分频时钟信号
    reg [4:0] shift_pos;       // 控制当前显示的LED数
    integer i;
    integer	j;// 循环变量

    // 初始化PWM占空比和移位位置
    initial begin
        pwm_duty[0] = 7'b0000001; // 1%亮度
        pwm_duty[1] = 7'b0000101; // 5%亮度
        pwm_duty[2] = 7'b0100011; // 35%亮度
        pwm_duty[3] = 7'b1000110; // 70%亮度
        shift_pos = 5'b00000;      // 初始没有亮灯
		  // 初始化 LED 状态为熄灭
        for (i = 0; i < 10; i = i + 1) begin
            led[i] = 7'b0000000;  // 初始化所有LED为熄灭状态
        end
    end

    // 10Hz频率分频，控制LED移动速度
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clock_10Hz <= 0; // 初始化10Hz时钟
        end
        else if (counter >= 24'd625000) begin  // 假设系统时钟频率为50MHz  2500000对应10Hz
            counter <= 0;
            clock_10Hz <= ~clock_10Hz; // 反转10Hz时钟
        end
        else
            counter <= counter + 1;
    end

    // 控制LED移位
    always @(posedge clock_10Hz or negedge rst_n) begin
        if (!rst_n) begin
            shift_pos <= 5'b00000; // 复位
        end
        else begin
            if (shift_pos < 5'b11100) begin
                shift_pos <= shift_pos + 1; // 递增到27
            end else begin
                shift_pos <= 5'b00000; // 确保从0开始
            end
        end
    end

    // 根据移位位置控制LED亮度
    always @(*) begin

        if (shift_pos < 14) begin
            for(i=0;i<10;i=i+1)begin
				j= shift_pos - i;
			   if (j >= 0 && j <= 3) begin
				case (j)
                0: led[i] = pwm_duty[0]; // 1%亮度
                1: led[i] = pwm_duty[1]; // 5%亮度
                2: led[i] = pwm_duty[2]; // 35%亮度
                3: led[i] = pwm_duty[3]; // 70%亮度
            endcase
			   end else begin
                led[i] = 7'b0; // 熄灭
            end
				end

        end else begin
		      for(i=0;i<10;i=i+1)begin
				j = 26-shift_pos-i;
				if (j >= 0 && j <= 3) begin
            case (j)
                3: led[i] = pwm_duty[0]; // 1%亮度
                2: led[i] = pwm_duty[1]; // 5%亮度
                1: led[i] = pwm_duty[2]; // 35%亮度
                0: led[i] = pwm_duty[3]; // 70%亮度
            endcase
				end else begin
                led[i] = 7'b0; // 熄灭
            end
            end
    end
end
    // PWM模块实例化

    genvar idx;
    generate
        for (idx = 0; idx < 10; idx = idx + 1) begin : pwm_instance
            pwm pwm_inst (
                .clk(clk), 
                .sw(led[idx]), 
                .pwm_out(pwm_out[idx])
            );
        end
    endgenerate

endmodule

