.data
# Test Case 1: nums = [2, 2, 3, 2], expected result: 3
nums1:
    .word 2, 2, 3, 2
nums1_size:
    .word 4
nums1_expected:
    .word 3

# Test Case 2: nums = [0, 1, 0, 1, 0, 1, 99], expected result: 99
nums2:
    .word 0, 1, 0, 1, 0, 1, 99
nums2_size:
    .word 7
nums2_expected:
    .word 99

# Test Case 3: nums = [-2, -2, -2, -5], expected result: -5
nums3:
    .word -2, -2, -2, -5
nums3_size:
    .word 4
nums3_expected:
    .word -5

# Arrays of Test Cases
test_cases:
    .word nums1
    .word nums2
    .word nums3

test_cases_size:
    .word 4
    .word 7
    .word 4

expected_results:
    .word 3
    .word 99
    .word -5

num_test_cases:
    .word 3

correct_msg:
    .asciz "correct\n"

wrong_msg_prefix:
    .asciz "wrong at test case "

newline:
    .asciz "\n"

int_buffer:
    .zero 12                      # Allocate and zero-initialize 12 bytes

.text
.globl main

main:
    # Initialize registers
    la s0, test_cases        # s0 = base address of test_cases array
    la s1, test_cases_size   # s1 = base address of test_cases_size array
    la s2, expected_results  # s2 = base address of expected_results array
    lw s3, num_test_cases    # s3 = number of test cases
    li s4, 0                 # s4 = test index

loop_test_cases:
    beq  s4, s3, end_program  # If test index equals number of test cases, end program

    slli t0, s4, 2           # t0 = s4(index) * 4 (word offset)
    add  t1, s0, t0          # t1 = &test_cases[s4(index)]
    lw   a0, 0(t1)           # a0 = test_cases[s4] 

    add  t2, s1, t0          # t2 = &test_cases_size[s4]
    lw   a1, 0(t2)           # a1 = test_cases_size[s4]
    addi sp, sp , -4
    sw   t0, 0(sp)           # Save t0 (word offset)
    jal  ra, singleNumber    # singleNumber(nums, size)
    mv   t1, a0              # t1 = result
    lw   t0, 0(sp)           # Restore t0 
    addi sp, sp , 4

    add  t2, s2, t0          # t2 = &expected_results[s4]
    lw   t2, 0(t2)            # t2 = expected_results[s4]

    bne  t1, t2, report_error # If result != expected result, report_error

    # result == expected result, print "correct"
    la a0, correct_msg
    li a7, 4                 # ECALL 4: print string
    ecall
    j next_test_case

report_error:
    # Print "wrong at test case "
    la a0, wrong_msg_prefix
    li a7, 4                 # ECALL 4: print string
    ecall

    #(0-based)
    mv a0, s4                # a0 = s4
    li a7, 1                 # ECALL 1: print integer
    ecall
    # Print newline
    la a0, newline
    li a7, 4                 # ECALL 4: newline
    ecall

next_test_case:
    addi s4, s4, 1           # s4++
    j loop_test_cases        # Loop to next test case

end_program:
    li a7, 10                # ECALL 10: exit program
    ecall

# int singleNumber(int* nums, int numsSize)
singleNumber:
    addi sp, sp, -40          # Allocate stack space
    sw ra, 36(sp)             # Save return address
    sw s0, 32(sp)             # Save s0
    sw s1, 28(sp)             # Save s1
    sw s2, 24(sp)             # Save s2
    sw s3, 20(sp)             # Save s3
    sw s4, 16(sp)             # Save s4
    sw s5, 12(sp)             # Save s5
    sw s6, 8(sp)              # Save s6
    sw s7, 4(sp)              # Save s7
    sw s8, 0(sp)              # Save s8

    mv s0, a0                 # s0 = nums (int* nums)
    mv s1, a1                 # s1 = numsSize (int numsSize)
    li s8, 0                  # s8 = result = 0

    # Initialize min_leading_zeros = 32
    li s3, 32                 # s3 = min_leading_zeros = 32
    li s4, 0                  # s4 = i = 0

find_min_leading_zeros_loop:
    bge s4, s1, end_min_leading_zeros_loop

    # Load nums[i]
    slli t0, s4, 2            # t0 = i * 4
    add  t0, s0, t0           # t0 = &nums[i]
    lw   t1, 0(t0)            # t1 = nums[i]

    bnez t1, process_non_zero

    addi s4, s4, 1            # i++
    j find_min_leading_zeros_loop

process_non_zero:
    # Call my_clz((uint32_t)nums[i])
    mv  a0, t1                # a0 = nums[i]
    jal ra, my_clz            # Call my_clz
    mv  t2, a0                # t2 = leading_zeros

    blt t2, s3, update_min_leading_zeros
    j skip_update_min_leading_zeros

update_min_leading_zeros:
    mv s3, t2                 # min_leading_zeros = leading_zeros

skip_update_min_leading_zeros:
    addi s4, s4, 1            # i++
    j find_min_leading_zeros_loop

end_min_leading_zeros_loop:
    # Compute max_bit_index = 32 - min_leading_zeros
    li  t0, 32
    sub s5, t0, s3            # s5 = 32 - min_leading_zeros

    # Initialize s4 = 0 (i)
    li  s4, 0                 # s4 = i = 0

singleNumber_outer_loop:
    bge s4, s5, singleNumber_end_outer_loop  # If i >= (32 - min_leading_zeros), exit loop

    # Initialize count = 0 and j = 0
    li s6, 0                  # s6 = count = 0
    li s7, 0                  # s7 = j = 0

singleNumber_inner_loop:
    bge s7, s1, singleNumber_end_inner_loop  # If j >= numsSize, exit inner loop

    # Load nums[j]
    slli t1, s7, 2            # t1 = j * 4
    add  t1, s0, t1           # t1 = &nums[j]
    lw   t2, 0(t1)            # t2 = nums[j]

    # Check nums[j] & (1U << i)
    li  t3, 1
    sll t3, t3, s4            # t3 = 1U << i
    and t4, t2, t3            # t4 = nums[j] & (1U << i)
    beqz t4, singleNumber_skip_increment  # If zero, skip increment

    # count = (count + 1) % 3
    addi s6, s6, 1            # count++
    li t5, 3
    blt s6, t5, singleNumber_skip_reset  # If count < 3, skip reset
    li s6, 0                  # count = 0

singleNumber_skip_reset:
    # Continue to next iteration

singleNumber_skip_increment:
    addi s7, s7, 1            # j++
    j singleNumber_inner_loop

singleNumber_end_inner_loop:
    # If count != 0, set the corresponding bit
    beqz s6, singleNumber_skip_bit_set  # If count == 0, skip setting bit

    # result |= (1U << i)
    li  t6, 1
    sll t6, t6, s4            # t6 = 1U << i
    or s8, s8, t6             # s8 |= t6

singleNumber_skip_bit_set:
    addi s4, s4, 1            # i++
    j singleNumber_outer_loop

singleNumber_end_outer_loop:
    mv a0, s8                 # Move result to a0

    # Restore registers and stack
    lw s8, 0(sp)
    lw s7, 4(sp)
    lw s6, 8(sp)
    lw s5, 12(sp)
    lw s4, 16(sp)
    lw s3, 20(sp)
    lw s2, 24(sp)
    lw s1, 28(sp)
    lw s0, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40
    ret

# int my_clz(uint32_t x)
my_clz:
    addi sp, sp, -8         # Allocate stack space
    sw ra, 4(sp)            # Save return address
    sw s0, 0(sp)            # Save s0

    mv s0, a0               # s0 = x

    # If x == 0, return 32
    beqz s0, return_32

    # If x < 0, return 0
    bltz s0, return_0

    # Begin computation as per the C code

    # x |= (x >> 1)
    srli t0, s0, 1          # t0 = x >> 1
    or   s0, s0, t0         # x |= t0

    # x |= (x >> 2)
    srli t0, s0, 2          # t0 = x >> 2
    or   s0, s0, t0         # x |= t0

    # x |= (x >> 4)
    srli t0, s0, 4          # t0 = x >> 4
    or   s0, s0, t0         # x |= t0

    # x |= (x >> 8)
    srli t0, s0, 8          # t0 = x >> 8
    or   s0, s0, t0         # x |= t0

    # x |= (x >> 16)
    srli t0, s0, 16         # t0 = x >> 16
    or   s0, s0, t0         # x |= t0

    # x -= ((x >> 1) & 0x55555555)
    srli t0, s0, 1          # t0 = x >> 1
    li   t1, 0x55555555     # Load mask 0x55555555
    and  t0, t0, t1         # t0 = (x >> 1) & 0x55555555
    sub  s0, s0, t0         # x -= t0

    # x = ((x >> 2) & 0x33333333) + (x & 0x33333333)
    srli t0, s0, 2          # t0 = x >> 2
    li   t1, 0x33333333     # Load mask 0x33333333
    and  t0, t0, t1         # t0 = (x >> 2) & 0x33333333
    and  t2, s0, t1         # t2 = x & 0x33333333
    add  s0, t0, t2         # x = t0 + t2

    # x = ((x >> 4) + x) & 0x0f0f0f0f
    srli t0, s0, 4          # t0 = x >> 4
    add  s0, s0, t0         # x += t0
    li   t1, 0x0f0f0f0f     # Load mask 0x0f0f0f0f
    and  s0, s0, t1         # x &= 0x0f0f0f0f

    # x += (x >> 8)
    srli t0, s0, 8          # t0 = x >> 8
    add  s0, s0, t0         # x += t0

    # x += (x >> 16)
    srli t0, s0, 16         # t0 = x >> 16
    add  s0, s0, t0         # x += t0

    # Return (32 - (x & 0x3f))
    andi t0, s0, 0x3f       # t0 = x & 0x3f
    li   t1, 32             # t1 = 32
    sub  a0, t1, t0         # a0 = 32 - t0

    # Restore and return
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

return_32:
    li a0, 32               # Return 32
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

return_0:
    li a0, 0                # Return 0
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret
