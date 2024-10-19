# XD2024Fall-EE5000
2024秋数字逻辑与微处理器实验

#### 最近更新
- **2024-10-19**: 更新目录；上传MIT问题记录。
- **2024-10-16**: 提交已完成代码。

### FPGA
> 仅提交 .v 文件。相关软硬件使用请参阅教材与手册。

[计时器实验](FPGA/1/)  
设计 FPGA 逻辑，使用 DE0 实验板上的七段数码管 HXE3-HEX0，实现一个计数范围为 0 分 0 秒到 59 分 59 秒的计时器，其中 HEX3 和 HEX2 显示分钟数值，HEX1 和 HEX0 显示秒钟数值。通过 BUTTON2 对计时器清零。

[PWM 实验](FPGA/2/)  
设计 FPGA 逻辑，实现单路 PWM 发生器。通过拨动 DE0 开发板上 SW6-SW0 拨码开关，调节 DE0 实验板上的发光二极管 LED4 的亮度。

[DDS 实验](FPGA/3/)  
设计硬件逻辑，实现一个 DDS 波形发生器，能产生 10kHz 正弦信号。同时考虑如何产生三角波、方波、锯齿波等其它波形，并可利用某一按键切换输出不同波形。

[呼吸流水灯实验](FPGA/4/)  
> 为了好看，频率与作业要求不一致。

设计硬件逻辑，如教材中图 4.1 所示，以 10Hz 频率点亮 DE0 开发板上的发光二极管 LED9-LED0，使发光二极管的亮度呈明暗变化，形似呼吸。


### RISC-V 汇编语言程序设计实验
> .S 后缀在 LiteOS 对应框架中运行，riscvX.s 在 Jupiter 中运行。

