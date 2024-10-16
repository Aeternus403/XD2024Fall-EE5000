N = 100
.data
  databuf: .half N
           X = 17
           .rept N #重复N次，生成不同数值组
           X = (X+97) % 256 #采用累加求余进行伪随机
           .byte X
           .endr

.section .text
.globl _start

_start:
  
  csrci mstatus,0x8         #关闭中断
  call hi_watchdog_disable  #关闭看门狗，SOC上电默认打开看门狗功能，如果不关闭，会导致SOC复位重启
  call copy_data_to_ram
  /*编写主程序 */
  la t2, databuf                # t2 指向 DATABUF
  li t1, 100                  # 存放数据个数到DATABUF的前2字节
  sh t1, 0(t2)
  addi t2, t2, 2                # t2 指向存放数据的位置

  li t0, 100                      # 外层循环计数器

outer_loop:
    li t1, 0                      # 内层循环计数器
    la t2, databuf                # t2 指向 DATABUF
    addi t2, t2, 2                # t2 指向存放数据的位置

inner_loop:
    lbu t3, 0(t2)                  # 加载当前值
    lbu t4, 1(t2)                  # 加载下一个值
     
    # 比较并交换
    bltu t3, t4, no_swap           # 如果 t3 < t4，不交换
    sb t4, 0(t2)                  # 交换
    sb t3, 1(t2)
    j no_swap

no_swap:
    addi t2, t2, 1                # 移动到下一个数据
    addi t1, t1, 1                # 内层计数器加 1
    li t5, 99
    bltu t1, t5, inner_loop        # 如果还没处理完，继续内层循环

    # 判断外层循环是否继续
    addi t0, t0, -1               # 外层计数器减 1
    bgtz t0, outer_loop           # 如果外层计数器大于 0，继续外层循环

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

red_led_on:
    li t0,0x50006004  #GPIO传输方向控制
    li t1,0x400       #将bit[10]改写为1将GPIO10设置为输出
    sw t1,0(t0)      

    li t0,0x50006000  #GPIO传输值控制
    li t1,0x400       #将bit[10]改写为1将GPIO10设置为输出高电平，点亮LED
    sw t1,0(t0)
 
    ret
    
green_led_on:
    li t0,0x50006004  #GPIO传输方向控制
    li t1,0x800       #将bit[11]改写为1将GPIO11设置为输出
    sw t1,0(t0)      

    li t0,0x50006000  #GPIO传输值控制
    li t1,0x800       #将bit[11]改写为1将GPIO11设置为输出高电平，点亮LED
    sw t1,0(t0)
 
    ret

compare:
   la t0,databuf
   lhu t3,0(t0)
   addi t3,t3,-1
   addi t0,t0,2
L1:
   lbu t1,0(t0)
   lbu t2,1(t0)
   bge t1,t2,L2
   addi t0,t0,1
   addi t3,t3,-1
   bgtz t3,L1
   call green_led_on
   j L3
L2:
   call red_led_on
L3:
   ret