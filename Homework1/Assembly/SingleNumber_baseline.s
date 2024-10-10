       .data
    # Test Case 1: nums = [2, 2, 3, 2]
    nums1:
        .word 2, 2, 3, 2
    nums1_size:
        .word 4

    # Test Case 2: nums = [0, 1, 0, 1, 0, 1, 99]
    nums2:
        .word 0, 1, 0, 1, 0, 1, 99
    nums2_size:
        .word 7

    # Test Case 3: nums = [-2, -2, -2, -5]
    nums3:
        .word -2, -2, -2, -5
    nums3_size:
        .word 4

    result_str:
        .asciz "Result: "
    newline_str:
        .asciz "\n"
    int_buffer:
        .zero 12                      # Allocate and zero-initialize 12 bytes

        .text
        .globl main

    main:
        # Test Case 1
        la a0, nums1          # Load address of nums1 array
        lw a1, nums1_size     # Load size of nums1 array
        jal ra, singleNumber  # Call singleNumber(nums1, size)
        mv a2, a0             # Move result to a2 for printing
        la a0, result_str     # Load address of result string
        jal ra, print_result  # Print result

        # Test Case 2
        la a0, nums2
        lw a1, nums2_size
        jal ra, singleNumber
        mv a2, a0
        la a0, result_str
        jal ra, print_result

        # Test Case 3
        la a0, nums3
        lw a1, nums3_size
        jal ra, singleNumber
        mv a2, a0
        la a0, result_str
        jal ra, print_result

        # Exit program
        li a0, 0              # Exit code 0
        li a7, 93             # ECALL for exit
        ecall

    # int singleNumber(int* nums, int numsSize)
    singleNumber:
        addi sp, sp, -24      # Allocate stack space
        sw ra, 20(sp)         # Save return address
        sw s0, 16(sp)         # Save s0
        sw s1, 12(sp)         # Save s1
        sw s2, 8(sp)          # Save s2
        sw s3, 4(sp)          # Save s3
        sw s4, 0(sp)          # Save s4

        mv s0, a0             # s0 = nums (int* nums)
        mv s1, a1             # s1 = numsSize (int numsSize)
        li a0, 0              # a0 = result = 0
        li s2, 0              # s2 = i = 0 (bit index)

    singleNumber_outer_loop:
        li t0, 32             # t0 = 32 (number of bits)
        bge s2, t0, singleNumber_end_outer_loop  # if i >= 32, exit loop

        # Initialize count = 0
        li s3, 0              # s3 = count = 0
        li s4, 0              # s4 = j = 0

    singleNumber_inner_loop:
        bge s4, s1, singleNumber_end_inner_loop  # if j >= numsSize, exit inner loop

        # Load nums[j]
        slli t1, s4, 2        # t1 = j * 4 (word size)
        add t1, s0, t1        # t1 = &nums[j]
        lw t2, 0(t1)          # t2 = nums[j]

        # Check if nums[j] & (1U << i)
        li t3, 1
        sll t3, t3, s2        # t3 = 1U << i
        and t4, t2, t3        # t4 = nums[j] & (1U << i)
        beqz t4, singleNumber_skip_increment  # if zero, skip increment

        # count = (count + 1) % 3
        addi s3, s3, 1        # count++
        li t5, 3
        blt s3, t5, singleNumber_skip_reset  # if count < 3, skip reset
        li s3, 0              # count = 0

    singleNumber_skip_reset:
        # Continue to next iteration

    singleNumber_skip_increment:
        addi s4, s4, 1        # j++
        jal zero, singleNumber_inner_loop

    singleNumber_end_inner_loop:
        # if count != 0
        beqz s3, singleNumber_skip_bit_set  # if count == 0, skip setting bit

        # result |= (1U << i)
        li t6, 1
        sll t6, t6, s2        # t6 = 1U << i
        or a0, a0, t6         # result |= t6

    singleNumber_skip_bit_set:
        addi s2, s2, 1        # i++
        jal zero, singleNumber_outer_loop

    singleNumber_end_outer_loop:
        # Result is in a0
        # Restore registers and stack
        lw s4, 0(sp)
        lw s3, 4(sp)
        lw s2, 8(sp)
        lw s1, 12(sp)
        lw s0, 16(sp)
        lw ra, 20(sp)
        addi sp, sp, 24
        ret

    # Simplified print_result function for Ripes simulator
    print_result:
        addi sp, sp, -8       # Allocate stack space
        sw ra, 4(sp)          # Save return address
        sw a0, 0(sp)          # Save a0 (address of result_str)

        # Print "Result: "
        mv a0, a0             # a0 already contains address of result_str
        li a7, 4              # ECALL for print string
        ecall

        # Print integer in a2
        mv a0, a2             # Move result to a0
        jal ra, print_int     # Call print_int

        # Print newline
        la a0, newline_str
        li a7, 4
        ecall

        # Restore registers and stack
        lw a0, 0(sp)          # Restore a0
        lw ra, 4(sp)          # Restore ra
        addi sp, sp, 8
        ret

    # Corrected print_int function
    print_int:
        # Convert integer to string and print
        # Handle negative numbers
        addi sp, sp, -36         # Adjust stack size for additional registers
        sw ra, 32(sp)
        sw t0, 28(sp)
        sw t1, 24(sp)
        sw t2, 20(sp)
        sw t3, 16(sp)
        sw t4, 12(sp)
        sw t5, 8(sp)
        sw a4, 4(sp)             # Save a4
        sw a5, 0(sp)             # Save a5

        mv t0, a0                # t0 = number
        la t1, int_buffer        # t1 = address of int_buffer

        # Clear the buffer
        li t2, 12                # t2 = buffer size
        li t3, 0                 # t3 = zero
        mv a5, t1                # a5 = buffer pointer
    clear_buffer_loop:
        beqz t2, clear_buffer_done
        sb t3, 0(a5)
        addi a5, a5, 1
        addi t2, t2, -1
        jal zero, clear_buffer_loop
    clear_buffer_done:
        # Reset t1 to end of buffer
        la t1, int_buffer        # t1 = address of int_buffer
        addi t1, t1, 11          # t1 points to int_buffer + 11 (one before end)

        li t2, 48                # t2 = ASCII code for '0'
        li t3, 0                 # t3 = sign flag
        li a4, 10                # a4 = 10

        # Check if number is zero
        beq t0, zero, print_int_zero

        # Check if number is negative
        blt t0, zero, print_int_negative

    print_int_loop:
        # t4 = t0 / 10 (quotient)
        # t5 = t0 % 10 (remainder)

        # Initialize t4 = 0 (quotient), t5 = t0 (remainder)
        mv t5, t0                # t5 = t0 (remainder)
        li t4, 0                 # t4 = 0 (quotient)

    print_int_divide_loop:
        blt t5, a4, print_int_divide_end
        sub t5, t5, a4           # t5 -= 10
        addi t4, t4, 1           # t4 += 1
        jal zero, print_int_divide_loop
    print_int_divide_end:
        # Now t4 is quotient, t5 is remainder

        # Convert remainder to character
        add t6, t5, t2           # t6 = t5 + '0'
        sb t6, 0(t1)             # Store character at t1
        addi t1, t1, -1          # t1 -= 1

        # Update t0 to quotient
        mv t0, t4                # t0 = t4

        # If t0 != 0, continue loop
        bnez t0, print_int_loop

        # After loop, check for sign
        beqz t3, print_int_print  # If not negative, proceed to print

        # Add '-' sign
        li t6, 45                # '-'
        sb t6, 0(t1)
        addi t1, t1, -1

    print_int_print:
        addi t1, t1, 1           # Adjust t1 to point to the start of string
        # Print the number string
        mv a0, t1                # a0 = pointer to start of string
        li a7, 4
        ecall

        # Restore registers and stack
        lw a5, 0(sp)             # Restore a5
        lw a4, 4(sp)             # Restore a4
        lw t5, 8(sp)
        lw t4, 12(sp)
        lw t3, 16(sp)
        lw t2, 20(sp)
        lw t1, 24(sp)
        lw t0, 28(sp)
        lw ra, 32(sp)
        addi sp, sp, 36
        ret

    print_int_negative:
        li t3, 1               # Set sign flag
        neg t0, t0             # t0 = -t0
        jal zero, print_int_loop

    print_int_zero:
        # Handle zero
        li t6, 48              # '0'
        sb t6, 0(t1)
        addi t1, t1, -1
        jal zero, print_int_print
