.data
    prompt:     .asciiz "Enter a non-negative integer: "
    err_msg:    .asciiz "A factorial for your number can not be found."
    newline:    .asciiz "\n"

.text
.globl main

main:

    li      $v0, 4
    la      $a0, prompt
    syscall

    # Đọc số nguyên từ người dùng
    li      $v0, 5
    syscall
    move    $t0, $v0            # $t0 = n (số người dùng nhập)

    # Kiểm tra số âm
    bltz    $t0, print_error    # Nếu n < 0, nhảy tới print_error

    move    $a0, $t0            # Truyền tham số: n
    jal     fact                # Gọi hàm đệ quy fact(n), kết quả trả về ở $v0
    move    $t1, $v0            # $t1 = n!

print_result:
    # In kết quả giai thừa
    li      $v0, 1
    move    $a0, $t1
    syscall
    j       exit_program        # Nhảy tới kết thúc để bỏ qua phần báo lỗi

print_error:
    # In câu báo lỗi theo đúng yêu cầu đề bài
    li      $v0, 4
    la      $a0, err_msg
    syscall

exit_program:
    # In ký tự xuống dòng
    li      $v0, 4
    la      $a0, newline
    syscall

    # Kết thúc chương trình
    li      $v0, 10
    syscall


fact:
    # Base case (Điểm dừng đệ quy): Nếu n <= 0 (tức n == 0), return 1
    bgtz    $a0, fact_recurse   # Nếu n > 0, nhảy tới phần đệ quy
    li      $v0, 1              # 0! = 1
    jr      $ra                 # Return

fact_recurse:
    # --- Stack Prologue ---
    addi    $sp, $sp, -8        # Cấp phát 8 bytes trên Stack
    sw      $ra, 4($sp)         # Lưu thanh ghi $ra (Return Address)
    sw      $a0, 0($sp)         # Lưu n hiện tại

    # --- Gọi đệ quy fact(n - 1) ---
    addi    $a0, $a0, -1        # Tham số mới = n - 1
    jal     fact                # $v0 = (n - 1)!

    # --- Stack Epilogue ---
    lw      $a0, 0($sp)         # Khôi phục n
    lw      $ra, 4($sp)         # Khôi phục thanh ghi $ra từ Stack
    addi    $sp, $sp, 8         # Giải phóng 8 bytes khỏi Stack

    # --- n! = n * (n - 1)! ---
    mult    $v0, $a0            # (n - 1)! * n
    mflo    $v0                 # Lấy phần 32-bit thấp của tích
    jr      $ra                 # Return n!