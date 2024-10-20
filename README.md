# XD2024Fall-EE5000
2024秋数字逻辑与微处理器实验

#### 🚩最近更新
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

[统计有符号数](RISCV/1/) 
编写程序随机生成一组测试数据（有符号数），将其存放在缓冲区BUF中，每个数据占2个字节，数据个数存放在BUF缓冲区的前2个字节。现要求分别统计出大于0、等于0和小于0的数据个数，将个数分别存放在GREATZ、ZERO、LITTLEZ变量中。

[递增顺序排序](RISCV/2/)
随机生成一组数据（无符号数），将其存放在缓冲区DATABUF中，其数据个数存放在DATABUF的前2个字节，要求编写RISC-V汇编语言程序将数据按递增顺序排列。

[计算个人所得税](RISCV/3/)
在首址为XDAT的字型数组中，第一个字存放某单位的人数N（N<1000），第二个字存放B（个人所得税起征额），从第三个字开始分别存放该单位N个人的A（本月收入总额，A<300000）。要求编写汇编语言程序实现：根据个人所得税率表和个人所得税计算公式计算个人应纳税和单位应纳税总额，将结果存储在首址为YDAT的字型组中，其中第一个字存放单位人数，第二个字存放单位纳税总额，从第三个字开始分别存放该单位N个人的个人应纳税。

![image](https://github.com/user-attachments/assets/9e262e12-3cdb-4c54-a53f-275654d33265)

[统计分数线和录取人数](RISCV/4/)
在AVG缓冲区中保存有按报考号顺序排列的研究生考生平均成绩，在MIN缓冲区保存有与AVG相对应的考生单科最低成绩，报考学生总人数存储在字变量NUM中，给定录取条件为：

（1）最低单科成绩不得低于60分；

（2）选定录取分数线，按平均成绩从高分到低分录取，但录取人数不超过800人。

编程求取录取分数线N1和实际录取人数N2。
