
.data
    array:      .word   0, 0, 0, 0, 0       # Khai báo mảng 5 phần tử nguyên (5 words)
    prompt:     .asciiz "Enter element: "
    msg_out:    .asciiz "Result array: "
    space:      .asciiz " "
    newline:    .asciiz "\n"

.text
.globl main

main:
    la      $s0, array          # $s0 = Địa chỉ cơ sở của mảng
    li      $s1, 5              # $s1 = Kích thước mảng (n = 5)
    li      $t0, 0              # $t0 = index i = 0

input_loop:
    bge     $t0, $s1, process_array # Nếu i >= 5, chuyển sang bước xử lý

    li      $v0, 4
    la      $a0, prompt
    syscall

    li      $v0, 5
    syscall


    sll     $t1, $t0, 2         # $t1 = i * 4
    add     $t1, $s0, $t1       
    sw      $v0, 0($t1)         

    addi    $t0, $t0, 1        
    j       input_loop

process_array:
 
    # In thông báo xuất mảng
    li      $v0, 4
    la      $a0, newline
    syscall
    
    li      $v0, 4
    la      $a0, msg_out
    syscall

    li      $t0, 0              # Reset index i = 0

process_loop:
    bge     $t0, $s1, exit_program  # Nếu i >= 5, thoát vòng lặp

    # Lấy giá trị array[i]
    sll     $t1, $t0, 2         # offset = i * 4
    add     $t1, $s0, $t1     
    lw      $t2, 0($t1)         

    # Kiểm tra chia hết cho 4
    andi    $t3, $t2, 3         # Lấy 2 bit cuối ($t3 = array[i] % 4)
    beq     $t3, $zero, print_elem  # Nếu $t3 == 0 (chia hết cho 4), nhảy tới in

    # YÊU CẦU 3: Cập nhật thành bội của 4 gần nhất (ưu tiên làm tròn xuống)
    # Công thức: num = ((num + 1) >> 2) << 2
    addi    $t2, $t2, 1         # Cộng thêm 1 để dịch điểm cân bằng (giải quyết 34->32 thay vì 36)
    sra     $t2, $t2, 2         # Shift right arithmetic 2 bit (Chia 4 lấy phần nguyên làm tròn xuống)
    sll     $t2, $t2, 2         # Shift left logical 2 bit (Nhân lại cho 4)
    
    # Lưu lại vào mảng (tuân thủ nguyên tắc thay đổi trên bộ nhớ)
    sw      $t2, 0($t1)

print_elem:
    # YÊU CẦU 4: In phần tử ra terminal
    li      $v0, 1
    move    $a0, $t2            # Đưa giá trị cần in vào $a0
    syscall

    # In khoảng trắng
    li      $v0, 4
    la      $a0, space
    syscall

    addi    $t0, $t0, 1         # i++
    j       process_loop

exit_program:
    # In ký tự xuống dòng kết thúc
    li      $v0, 4
    la      $a0, newline
    syscall

    # Kết thúc chương trình (Syscall 10)
    li      $v0, 10
    syscall