
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

    li      $t1, 1              # $t1 = kết quả (khởi tạo result = 1)

fact_loop:
    blez    $t0, print_result   # Nếu n <= 0, thoát vòng lặp và in kết quả

    # result = result * n
    mult    $t1, $t0            # Nhân $t1 với $t0, kết quả lưu ở (hi, lo)
    mflo    $t1                 # Lấy phần 32-bit thấp từ thanh ghi lo gán lại vào $t1
    
    addi    $t0, $t0, -1        # n = n - 1
    j       fact_loop           # Lặp lại


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