.equ   N,500
.data
greatz: .half 0
zeros: .half 0
littlez: .half 0
buffer: .half 500
        X = 1023
        .rept N #重复N次，生成不同数值组
        X = (X+1024) % 65535 #采用累加求余进行伪随机
        .half X
        .endr
.section .text
.global _start

_start: 
    csrci mstatus,0x8         #关闭中断
    call hi_watchdog_disable  #关闭看门狗，SOC上电默认打开看门狗功能，如果不关闭，会导致SOC复位重启
    call copy_data_to_ram
    
    li t0, 500                     # t0 = N，准备生成N个数据
    la t2, buffer                # t2 指向 buffer
    sh t0, 0(t2)                 # 存放数据个数到buffer的前2字节
    addi t2, t2, 2               # t2 指向存放数据的位置

    li t1, 0                     # 索引寄存器 t1 初始化为 0

count_data:
    # 判断 t3 的大小
    lh t3, 0(t2)
    bltz t3, less_than_zero      # 如果 t3 < 0，跳转到 less_than_zero
    bgtz t3, greater_than_zero   # 如果 t3 > 0，跳转到 greater_than_zero

    # 等于 0 的情况
    la t4, zeros
    lhu t5, 0(t4)                 # 加载 ZERO 的当前值
    addi t5, t5, 1               # ZERO 计数 +1
    sh t5, 0(t4)                 # 更新 ZERO
    j next_data

greater_than_zero:
    la t4, greatz
    lhu t5, 0(t4)                 # 加载 GREATZ 的当前值
    addi t5, t5, 1               # GREATZ 计数 +1
    sh t5, 0(t4)                 # 更新 GREATZ
    j next_data

less_than_zero:
    la t4, littlez
    lhu t5, 0(t4)                 # 加载 LITTLEZ 的当前值
    addi t5, t5, 1               # LITTLEZ 计数 +1
    sh t5, 0(t4)                 # 更新 LITTLEZ
    j next_data

next_data:
    addi t2, t2, 2               # t2 指向下一个数据
    addi t1, t1, 1               # 索引加 1
    li t5, 500                     # 判断是否处理完 500 个数据
    bne t1, t5, count_data


    call compare
1: 
    j 1b

#关闭看门狗的函数，无须关注
hi_watchdog_disable:
    lui a4,0x50000
    lhu a5,48(a4)
    slli    a5,a5,0x10
    srli    a5,a5,0x10
1:
    andi    a5,a5,-2
    slli    a5,a5,0x10
    srli    a5,a5,0x10
    sh  a5,48(a4)
    lui a4,0x40000
    lw  a5,0(a4) 
    andi    a3,a5,2
    bnez    a3,1b
    lui a5,0x11c
    sb  zero,-1804(a5)
    ret
    lui a3,0x11c
    li  a2,1
    sb  a2,-1804(a3)
    andi     a5,a5,-3
    sw  a5,0(a4)
    ret

copy_data_to_ram: #从flash上加载数据段到RAM上
    la t0,__data_load
    la t1,__data_start
    la t2,__data_end
    beq t1,t2,2f
1:
    lw t3,0(t0)
    sw t3,0(t1)
    addi t0,t0,4
    addi t1,t1,4
    bne t1,t2,1b
2:
    ret
    
green_led_on:
    li t0,0x50006004  #GPIO传输方向控制
    li t1,0x800       #将bit[11]改写为1将GPIO11设置为输出
    sw t1,0(t0)      

    li t0,0x50006000  #GPIO传输值控制
    li t1,0x800       #将bit[11]改写为1将GPIO11设置为输出高电平，点亮LED
    sw t1,0(t0)
 
    ret

red_led_on:
    li t0,0x50006004  #GPIO传输方向控制
    li t1,0x400       #将bit[10]改写为1将GPIO10设置为输出
    sw t1,0(t0)      

    li t0,0x50006000  #GPIO传输值控制
    li t1,0x400       #将bit[10]改写为1将GPIO10设置为输出高电平，点亮LED
    sw t1,0(t0)
 
    ret

compare:
    /*la t0,greatz
    lhu a1,0(t0)
    li a2,255 #大于等于255 小于256 但不等于255/256
    bne a1,a2,L1*/
    
    la t0,greatz
    lhu a1,0(t0)
    li a2,254
    bne a1,a2,L1
    la t0,zeros
    lhu a1,0(t0)
    li a2,1
    bne a1,a2,L1
    la t0,littlez
    lhu a1,0(t0)
    li a2,245
    bne a1,a2,L1
    call green_led_on
    j L2
L1:
    call red_led_on
L2:
    ret

