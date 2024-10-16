.data
TAXRATE:      .half 3,10,20,25,30,35,45
DEDUCTION:    .half 0,210,1410,2660,4410,7160,15160
TAXPOINT:     .word 3000,12000,25000,35000,55000,80000,300000


XDAT:         .half 19,5000
              .word 8800,9800,7800,14000,15400,16000,17000,18000
              .word 9000,10000,15000,25000,30000,40000,50000,59900
              .word 60000,65000,200000
              
YDAT:         .zero 200
ZDAT:         .zero 200

.globl _start

.text

_start:
  csrci mstatus,0x8         #关闭中断
  call hi_watchdog_disable  #关闭看门狗，SOC上电默认打开看门狗功能，如果不关闭，会导致SOC复位重启
  call copy_data_to_ram
 
# 主程序开始
  la t0,XDAT
  lh s1,0(t0)
  addi t0,t0,2
  lh s2,0(t0)       #取得个税起征点
  addi t0,t0,2
  la a3,YDAT
  sh s1,0(a3)
  addi a3,a3,6
  xor s4,s4,s4      #保存单位所得税
  
LP:
  lw s3,0(t0)       #取出一位员工工资
  addi t0,t0,4
  call INCOMERATE   #计算个人所得税
  sw s3,0(a3)       #保存个人所得税
  addi a3,a3,4
  add s4,s4,s3
  addi s1,s1,-1
  bgtz s1,LP
  la a3,YDAT
  sw s4,2(a3)
  call compare_taxi
  call compare
1:
  j 1b


INCOMERATE:
  sub s3,s3,s2
  bltz s3,INCRATE3  #不需纳税出口
  la t2,TAXPOINT
  li t5,0
  li t6,7
INCRATE1:
  lw s5,0(t2)
  blt s3,s5,INCRATE2
  addi t2,t2,4
  addi t5,t5,2
  addi t6,t6,-1
  bgtz t6,INCRATE1
INCRATE2:
  la t3,TAXRATE
  add t3,t3,t5
  lhu s6,0(t3)
  mul s3,s3,s6
  li t6,100
  divu s3,s3,t6
  la t4,DEDUCTION
  add t4,t4,t5
  lhu s6,0(t4)
  sub s3,s3,s6
  J INCRATE4
INCRATE3:
  li s3,0
INCRATE4:
  ret

compare:
  mv s7,ra
  la t0,YDAT
  la t1,ZDAT
  lhu t4,0(t0)
  addi t4,t4,-1
  addi t0,t0,2
  addi t1,t1,2
L1:
  lw t2,0(t0)
  lw t3,0(t1)
  beq t2,t3,L2
  call red_led_on
  j L3
L2:
  addi t0,t0,4
  addi t1,t1,4
  addi t4,t4,-1
  bgtz t4,L1
  call green_led_on
L3:
  mv ra,s7
  ret

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

compare_taxi:
  mv s7,ra
  la t0,XDAT
  lhu s1,0(t0)
  addi t0,t0,2
  lh s2,0(t0)       #取得个税起征点
  addi t0,t0,2
  la t1,ZDAT
  sh s1,0(t1)
  sw x0,2(t1)
  addi t1,t1,6
  xor s4,s4,s4      #保存单位所得税
  
LP1:
  lw s3,0(t0)       #取出一位员工工资
  addi t0,t0,4
  call INCOMERATE   #计算个人所得税
  sw s3,0(t1)       #保存个人所得税
  addi t1,t1,4
  add s4,s4,s3
  addi s1,s1,-1
  bgtz s1,LP1
  mv ra,s7
  la t1,ZDAT
  sw s4,2(t1)
  ret