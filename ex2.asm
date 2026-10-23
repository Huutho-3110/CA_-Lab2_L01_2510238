

.data
    prompt_a:   .asciiz "a = "
    prompt_b:   .asciiz "b = "
    err_msg:    .asciiz "Error: Input must be a positive integer! Please try again.\n"
    gcd_str:    .asciiz "GCD="
    lcm_str:    .asciiz ", LCM="
    newline:    .asciiz "\n"

.text
.globl main

main:

input_a:
    li      $v0, 4
    la      $a0, prompt_a
    syscall

    li      $v0, 5
    syscall
    move    $s0, $v0            # Lưu a vào $s0
    
    blez    $s0, invalid_a      # Nếu a <= 0, báo lỗi và nhập lại
    j       input_b             # Nếu hợp lệ, nhảy sang nhập b

invalid_a:
    li      $v0, 4
    la      $a0, err_msg
    syscall
    j       input_a

input_b:
    li      $v0, 4
    la      $a0, prompt_b
    syscall

    li      $v0, 5
    syscall
    move    $s1, $v0            # Lưu b vào $s1
    
    blez    $s1, invalid_b      # Nếu b <= 0, báo lỗi và nhập lại
    j       calculate           # Nếu hợp lệ, tiến hành tính toán

invalid_b:
    li      $v0, 4
    la      $a0, err_msg
    syscall
    j       input_b

calculate:

    move    $a0, $s0            # Truyền tham số thứ nhất: a
    move    $a1, $s1            # Truyền tham số thứ hai: b
    jal     gcd                 # Gọi hàm gcd, kết quả trả về sẽ nằm ở $v0
    
    move    $s2, $v0            # Lưu kết quả GCD vào $s2


    mult    $s0, $s1            # a * b
    mflo    $t0                 # $t0 = phần thấp (32-bit) của kết quả nhân
    div     $t0, $s2            # $t0 / GCD
    mflo    $s3                 # $s3 = LCM

    # In "GCD="
    li      $v0, 4
    la      $a0, gcd_str
    syscall

    # In giá trị GCD
    li      $v0, 1
    move    $a0, $s2
    syscall

    # In ", LCM="
    li      $v0, 4
    la      $a0, lcm_str
    syscall

    # In giá trị LCM
    li      $v0, 1
    move    $a0, $s3
    syscall

    # In newline và kết thúc
    li      $v0, 4
    la      $a0, newline
    syscall

    li      $v0, 10
    syscall


gcd:
    # Base case (Điểm dừng đệ quy): Nếu b == 0, return a
    bnez    $a1, gcd_recurse    # Nếu b != 0, nhảy tới phần đệ quy
    move    $v0, $a0            # Nếu b == 0, GCD = a ($v0 = a)
    jr      $ra                 # Return

gcd_recurse:
    # --- Stack Prologue ---
    addi    $sp, $sp, -4        # Cấp phát 4 bytes trên Stack
    sw      $ra, 0($sp)         # Lưu thanh ghi $ra (Return Address)

    # --- Tính a % b ---
    div     $a0, $a1            # a / b
    mfhi    $t0                 # $t0 = phần dư (a % b)

    # --- Chuẩn bị tham số cho lệnh gọi đệ quy gcd(b, a % b) ---
    move    $a0, $a1            # Tham số mới thứ 1 = b (cũ)
    move    $a1, $t0            # Tham số mới thứ 2 = a % b

    jal     gcd                 # Gọi đệ quy gcd(b, a % b)

    # --- Stack Epilogue ---
    lw      $ra, 0($sp)         # Khôi phục thanh ghi $ra từ Stack
    addi    $sp, $sp, 4         # Giải phóng 4 bytes khỏi Stack
    
    jr      $ra                 # Return (giá trị $v0 đã được gán ở Base case và truyền ngược lên)