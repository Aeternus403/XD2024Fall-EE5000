.data
DATABUF:    .space 12             # 缓冲区，用于存储数据（前2字节为数据个数，后续为数据）
seed:       .word 1                # 随机数种子
NEWLINE:    .byte 10               # 定义换行字符，十进制10

.text
.globl __start
__start:
    # 初始化，生成 5 个伪随机数
    li t0, 5                      # t0 = 5，准备生成5个数据
    la t2, DATABUF                # t2 指向 DATABUF
    sh t0, 0(t2)                  # 存放数据个数到DATABUF的前2字节
    addi t2, t2, 2                # t2 指向存放数据的位置

    li t1, 0                      # 索引寄存器 t1 初始化为 0

generate_data:
    # 生成伪随机数
    la t3, seed                   # 加载随机数种子的地址
    lw t4, 0(t3)                  # 加载当前种子
    li t5, 1664525                # a = 1664525
    mul t4, t4, t5                # 生成伪随机数：a * seed
    li t5, 1013904223             # c = 1013904223
    add t4, t4, t5                # 生成伪随机数：a * seed + c
    sw t4, 0(t3)                  # 更新种子

    # 随机数的低 16 位生成无符号数
    andi t4, t4, 0x7FF           # 取低16位作为无符号数
    sh t4, 0(t2)                  # 存入 DATABUF

    # 更新缓冲区指针和索引
    addi t2, t2, 2                # t2 偏移到下一条数据
    addi t1, t1, 1                # 索引加 1
    li t5, 5                      # 判断是否生成了 5 个数据
    bne t1, t5, generate_data     # 如果没有生成5个数据，继续生成

    # 数据生成完毕，开始输出原始数据
    li t1, 0                      # 索引清零
    la t2, DATABUF                # t2 指向 DATABUF
    addi t2, t2, 2                # 跳过前 2 个字节，指向数据开始的位置

print_data:
    lh t4, 0(t2)                  # 从 DATABUF 加载 16 位无符号数
    # 输出当前数值
    li a0, 1                       # sys_write 的功能码
    mv a1, t4                      # 将数值移动到 a1
    ecall                         # 执行系统调用

    # 输出换行
    la a1, NEWLINE                # 加载换行字符的地址
    li a0, 4                      # 字符串长度（换行字符为1个字节）
    ecall                         # 执行系统调用

    addi t2, t2, 2                # t2 指向下一个数据
    addi t1, t1, 1                # 索引加 1
    li t5, 5                      # 判断是否处理完 5 个数据
    bne t1, t5, print_data        # 如果没处理完，继续输出

    # 排序数据（冒泡排序）
    la t2, DATABUF                # t2 指向 DATABUF
    addi t2, t2, 2                # 跳过前 2 个字节，指向数据开始的位置
    li t0, 5                      # 外层循环计数器

outer_loop:
    li t1, 0                      # 内层循环计数器
    li t6, 0                      # 用于记录是否进行了交换

inner_loop:
    lh t3, 0(t2)                  # 加载当前值
    lh t4, 2(t2)                  # 加载下一个值
     
    # 比较并交换
    blt t3, t4, no_swap           # 如果 t3 < t4，不交换
    sh t4, 0(t2)                  # 交换
    sh t3, 2(t2)
    li t6, 1                      # 记录有交换发生

no_swap:
    addi t2, t2, 2                # 移动到下一个数据
    addi t1, t1, 1                # 内层计数器加 1
    li t5, 4                      # 处理4次比较
    blt t1, t5, inner_loop        # 如果还没处理完，继续内层循环

    # 判断外层循环是否继续
    addi t0, t0, -1               # 外层计数器减 1
    bgtz t0, outer_loop           # 如果外层计数器大于 0，继续外层循环

    # 输出排序后的数据
    li t1, 0                      # 索引清零
    la t2, DATABUF                # t2 指向 DATABUF
    addi t2, t2, 2                # 跳过前 2 个字节，指向数据开始的位置

print_sorted_data:
    # 输出换行
    la a1, NEWLINE                # 加载换行字符的地址
    li a0, 4                      # 字符串长度（换行字符为1个字节）
    ecall                         # 执行系统调用
    
    lh t4, 0(t2)                  # 从 DATABUF 加载 16 位无符号数
    # 输出当前数值
    li a0, 1                       # sys_write 的功能码
    mv a1, t4                      # 将数值移动到 a1
    ecall                         # 执行系统调用

    addi t2, t2, 2                # t2 指向下一个数据
    addi t1, t1, 1                # 索引加 1
    li t5, 5                      # 判断是否处理完 5 个数据
    bne t1, t5, print_sorted_data  # 如果没处理完，继续输出

    # 调用 exit 系统调用结束程序
    li a0, 10                     # exit 系统调用号
    ecall
