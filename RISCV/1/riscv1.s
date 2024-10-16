.data
BUF:        .space 12            # 缓冲区，用于存储数据（前2字节为数据个数，后续为数据）
GREATZ:     .word 0              # 大于 0 的计数
ZERO:       .word 0              # 等于 0 的计数
LITTLEZ:    .word 0              # 小于 0 的计数
seed:       .word 1              # 随机数种子
str_greatz: .asciiz "GREATZ: "   # 定义字符串 "GREATZ: "
str_zero:   .asciiz "ZERO: "     # 定义字符串 "ZERO: "
str_littlez:.asciiz "LITTLEZ: "  # 定义字符串 "LITTLEZ: "
NEWLINE: .byte 10

.text
.globl __start
__start:
    # 初始化，生成 5 个伪随机数
    li t0, 5                     # t0 = 5，准备生成5个数据
    la t2, BUF                   # t2 指向 BUF
    sh t0, 0(t2)                 # 存放数据个数到BUF的前2字节
    addi t2, t2, 2               # t2 指向存放数据的位置

    li t1, 0                     # 索引寄存器 t1 初始化为 0

generate_data:
    # 生成伪随机数
    la t3, seed                  # 加载随机数种子的地址
    lw t4, 0(t3)                 # 加载当前种子
    li t5, 1664525               # a = 1664525
    mul t4, t4, t5               # 生成伪随机数：a * seed
    li t5, 1013904223            # c = 1013904223
    add t4, t4, t5               # 生成伪随机数：a * seed + c
    sw t4, 0(t3)                 # 更新种子

    # 随机数的低 16 位生成有符号数
    srai t4, t4, 16              # 将高位右移16位，作为伪随机数
    sh t4, 0(t2)                 # 存入 BUF

    # 更新缓冲区指针和索引
    addi t2, t2, 2               # t2 偏移到下一条数据
    addi t1, t1, 1               # 索引加 1
    li t5, 5                     # 判断是否生成了 5 个数据
    bne t1, t5, generate_data    # 如果没有生成5个数据，继续生成

    # 数据生成完毕，开始统计
    li t1, 0                     # 索引清零
    la t2, BUF                   # t2 指向 BUF
    addi t2, t2, 2               # 跳过前 2 个字节，指向数据开始的位置

count_data:
    lh t3, 0(t2)
    lh a1, 0(t2)
    li a0, 1
    ecall
    la a1, NEWLINE               # 加载换行字符的地址
    li a0, 4                      # 字符串长度（换行字符为1个字节）
    ecall
    # 判断 t3 的大小
    bltz t3, less_than_zero      # 如果 t3 < 0，跳转到 less_than_zero
    bnez t3, greater_than_zero   # 如果 t3 > 0，跳转到 greater_than_zero

    # 等于 0 的情况
    la t4, ZERO
    lw t5, 0(t4)                 # 加载 ZERO 的当前值
    addi t5, t5, 1               # ZERO 计数 +1
    sw t5, 0(t4)                 # 更新 ZERO
    j next_data

greater_than_zero:
    la t4, GREATZ
    lw t5, 0(t4)                 # 加载 GREATZ 的当前值
    addi t5, t5, 1               # GREATZ 计数 +1
    sw t5, 0(t4)                 # 更新 GREATZ
    j next_data

less_than_zero:
    la t4, LITTLEZ
    lw t5, 0(t4)                 # 加载 LITTLEZ 的当前值
    addi t5, t5, 1               # LITTLEZ 计数 +1
    sw t5, 0(t4)                 # 更新 LITTLEZ

next_data:
    addi t2, t2, 2               # t2 指向下一个数据
    addi t1, t1, 1               # 索引加 1
    li t5, 5                     # 判断是否处理完 5 个数据
    bne t1, t5, count_data       # 如果没处理完，继续统计


    la a1, NEWLINE               # 加载换行字符的地址
    li a0, 4                      # 字符串长度（换行字符为1个字节）
    ecall
    # 统计完毕，输出结果
    # 输出 GREATZ
    la a1, str_greatz
    li a0, 4                     # 调用 sys_write 输出
    ecall
    la a3, GREATZ
    lw a1,0(a3)
    li a0, 1
    ecall

    la a1, NEWLINE               # 加载换行字符的地址
    li a0, 4                      # 字符串长度（换行字符为1个字节）
    ecall                        # 执行系统调用

    # 输出 ZERO
    la a1, str_zero
    li a0, 4                     # 调用 sys_write 输出
    ecall
    la a3, ZERO
    lw a1,0(a3)
    li a0, 1
    ecall
    
    la a1, NEWLINE               # 加载换行字符的地址
    li a0, 4                      # 字符串长度（换行字符为1个字节）
    ecall                        # 执行系统调用
    
    # 输出 LITTLEZ
    la a1, str_littlez
    li a0, 4                     # 调用 sys_write 输出
    ecall
    la a3, LITTLEZ
    lw a1,0(a3)
    li a0, 1
    ecall
    
    # 调用 exit 系统调用结束程序
    li a0, 10                    # exit 系统调用号
    ecall
