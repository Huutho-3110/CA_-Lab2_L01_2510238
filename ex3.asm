
.data
    array:      .space  40              # Cấp phát 40 bytes cho mảng 10 số nguyên (10 * 4)
    prompt:     .asciiz "Please insert a element: "
    msg_val:    .asciiz "Second largest value is "
    msg_idx:    .asciiz ", found in index "
    comma:      .asciiz ", "
    newline:    .asciiz "\n"

.text
.globl main

main:
    la      $s0, array          # $s0 = Địa chỉ cơ sở của mảng
    li      $s1, 10             # $s1 = Kích thước mảng (10)

    li      $t0, 0              # index = 0
input_loop:
    bge     $t0, $s1, find_max_pass
    
    li      $v0, 4
    la      $a0, prompt
    syscall

    li      $v0, 5
    syscall
    
    sll     $t1, $t0, 2         # offset = index * 4
    add     $t1, $s0, $t1       # địa chỉ = base + offset
    sw      $v0, 0($t1)         # array[index] = input
    
    addi    $t0, $t0, 1         # index++
    j       input_loop


find_max_pass:
    lw      $s2, 0($s0)         # $s2 = max (khởi tạo bằng phần tử đầu tiên, array[0])
    li      $t0, 1              # index = 1
    
find_max_loop:
    bge     $t0, $s1, find_second_max_pass
    
    sll     $t1, $t0, 2
    add     $t1, $s0, $t1
    lw      $t2, 0($t1)         # $t2 = array[index]
    
    ble     $t2, $s2, skip_max  # Nếu array[index] <= max, bỏ qua
    move    $s2, $t2            # max = array[index]
    
skip_max:
    addi    $t0, $t0, 1
    j       find_max_loop

find_second_max_pass:
    li      $s3, 0x80000000     # $s3 = second_max (khởi tạo bằng INT_MIN = -2147483648)
    li      $t0, 0              # index = 0
    
find_smax_loop:
    bge     $t0, $s1, print_result
    
    sll     $t1, $t0, 2
    add     $t1, $s0, $t1
    lw      $t2, 0($t1)         # $t2 = array[index]
    
    bge     $t2, $s2, skip_smax # Bỏ qua nếu phần tử >= max (tức là bằng max)
    ble     $t2, $s3, skip_smax # Bỏ qua nếu phần tử <= second_max
    
    move    $s3, $t2            # second_max = array[index]
    
skip_smax:
    addi    $t0, $t0, 1
    j       find_smax_loop

    # ---------------------------------------------------------
    # 4. IN KẾT QUẢ
    # ---------------------------------------------------------
print_result:
    # In "Second largest value is "
    li      $v0, 4
    la      $a0, msg_val
    syscall
    
    # In giá trị second_max
    li      $v0, 1
    move    $a0, $s3
    syscall
    
    # In ", found in index "
    li      $v0, 4
    la      $a0, msg_idx
    syscall

    # Duyệt mảng lần cuối để in các chỉ số
    li      $s4, 1              # cờ first_match = 1 (để xử lý dấu phẩy)
    li      $t0, 0              # index = 0
    
print_idx_loop:
    bge     $t0, $s1, end_program
    
    sll     $t1, $t0, 2
    add     $t1, $s0, $t1
    lw      $t2, 0($t1)         # $t2 = array[index]
    
    bne     $t2, $s3, skip_print # Nếu không bằng second_max thì bỏ qua
    
    # Nếu là chỉ số đầu tiên tìm thấy, không in dấu phẩy
    beq     $s4, 1, print_index
    
    # Nếu không phải đầu tiên, in dấu phẩy trước
    li      $v0, 4
    la      $a0, comma
    syscall
    
print_index:
    li      $s4, 0              # Đặt lại cờ first_match = 0
    li      $v0, 1
    move    $a0, $t0            # In index
    syscall
    
skip_print:
    addi    $t0, $t0, 1
    j       print_idx_loop

end_program:
    li      $v0, 4
    la      $a0, newline
    syscall

    li      $v0, 10
    syscall