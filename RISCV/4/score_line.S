.data
NUM: .half 2000             #保存报考人数
AVG: .zero 2000             #保存各个考生的平均成绩
MIN: .zero 2000             #保存各个考生的最低成绩
N1:  .zero 2                #保存分数线
N2:  .zero 2                #保存录取人数
N3:  .zero 2
N4:  .zero 2
BUF1:.zero 2000             #保存临时数据
BUF2:.zero 2000

.globl _start

.text

_start:
  csrci mstatus,0x8         #关闭中断
  call hi_watchdog_disable  #关闭看门狗，SOC上电默认打开看门狗功能，如果不关闭，会导致SOC复位重启
  call copy_data_to_ram

  la t0,NUM
  lh t3,0(t0)
  call PRODUCT   #产生模拟数据

  /*编写主程序 */
  la t0,NUM
  lh t3,0(t0)
  la t0,AVG
  la t1,MIN
  la t2,BUF1
  la t5,BUF2
  li t6,0
  li t4,60
E:
  lbu s1,0(t1)
  blt s1,t4,E1
  lbu s2,0(t0)
  sb s2,0(t2)
  addi t2,t2,1
  sh t6,0(t5)
  addi t5,t5,2
E1:
  addi t6,t6,1
  addi t0,t0,1
  addi t1,t1,1
  addi t3,t3,-1
  bgtz t3,E 
  la t0,BUF1
  sub t3,t2,t0
  la t2,BUF2
  call SORT
  li t4,800
  blt t3,t4,MAT
  li t3,800
MAT:
  la t0,BUF1
  add t0,t0,t3
  lbu a1,0(t0)
  la t0,N1
  la t1,N2
  sb a1,0(t0)
  sh t3,0(t1)
  call compare_score
  call compare
  li a0, 10
  ecall
1:
  j 1b



PRODUCT:  
  mv s3,t3
  li s1,17
  li s2,59
  li t4,100
  li t5,40
  la t0,AVG
PR1:
  add s1,s1,s2
  andi s1,s1,0x000000ff
  bge s1,t4,PR1
  blt s1,t5,PR1
  sb s1,0(t0)
  addi t0,t0,1
  addi t3,t3,-1
  bgtz t3,PR1
  mv t3,s3
  li s1,5
  li s2,3
  li t4,15
  la t0,AVG
  la t1,MIN
PR2:
  add s1,s1,s2
  andi s1,s1,0x000000ff
  bge s1,t4,PR2
  lbu s4,0(t0)
  sub s4,s4,s1
  sb s4,0(t1)
  addi t0,t0,1
  addi t1,t1,1
  addi t3,t3,-1
  bgtz t3,PR2
  ret
  
SORT:
  mv s3,t3
  mv t4,s3
LP1:
  la t0,BUF1
  la t1,BUF2
LP2:
  lbu s1,0(t0)
  lbu s2,1(t0)
  bge s1,s2,NOXCHG
  sb s1,1(t0)
  sb s2,0(t0)
  lhu s1,0(t1)
  lhu s2,2(t1)
  sh s1,1(t1)
  sh s2,0(t1)
NOXCHG:
  addi t0,t0,1
  addi t1,t1,2
  addi t3,t3,-1
  bgtz t3,LP2
  addi t4,t4,-1
  bgtz t4,LP1
  mv t3,s3
  ret

compare:
  mv s7,ra
  la t0,N1
  lhu t2,0(t0)
  la t1,N3
  lhu t3,0(t1)
  beq t2,t3,L1
  call red_led_on
L1:
  la t0,N2
  lhu t2,0(t0)
  la t1,N4
  lhu t3,0(t1)
  beq t2,t3,L2
  call red_led_on
  j L3
L2:
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

compare_score:
  mv s7,ra
  la t0,NUM
  lh t3,0(t0)
  la t0,AVG
  la t1,MIN
  la t2,BUF1
  la t5,BUF2
  li t6,0
  li t4,60
ELIMINATE:
  lbu s1,0(t1)
  blt s1,t4,ELIMINATE1
  lbu s2,0(t0)
  sb s2,0(t2)
  addi t2,t2,1
  sh t6,0(t5)
  addi t5,t5,2
ELIMINATE1:
  addi t6,t6,1
  addi t0,t0,1
  addi t1,t1,1
  addi t3,t3,-1
  bgtz t3,ELIMINATE  
  la t0,BUF1
  sub t3,t2,t0
  la t2,BUF2
  call SORT
  li t4,800
  blt t3,t4,MATRI00
  li t3,800
MATRI00:
  la t0,BUF1
  add t0,t0,t3
  lbu a1,0(t0)
  la t0,N3
  la t1,N4
  sb a1,0(t0)
  sh t3,0(t1)
  mv ra,s7
  ret