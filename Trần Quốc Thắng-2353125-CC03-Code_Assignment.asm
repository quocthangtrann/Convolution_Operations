.data
    input_file:	.asciiz		"/Users/leuyentran/Downloads/Test_cases 2/test_10.txt"
    output_file:	.asciiz		"output_matrix_test_10.txt"
    descriptor:  	.word   	4

    n: 	         	.space  	4	
    m:			.space		4
    p: 	         	.space  	4	
    s:			.space		4
    image:		.space		900
    kernel:		.space		64

    answer:		.space		900
    answer_size:	.space		4
    
    buffer:      	.space  	1024	
    temp:		.space		1024			
    char:        	.space  	1
    space:		.asciiz		" "
    newline:        	.asciiz 	"\n"
.text
    # Open "input_matrix.txt"
    addi $v0, $zero, 13 
    la $a0, input_file         		
    addi $a1, $zero, 0           
    syscall
    sw 	$v0, descriptor
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, n
    
    jal read_float
    cvt.w.s $f0, $f0 # float -> int 
    mfc1 $t0, $f0
    sw $t0, m
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, p
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, s
    
    jal read_image
    jal read_kernel
    
    # Close "input_matrix.txt"
    addi $v0, $zero, 16    
    la $a0, descriptor
    lw $a0, 0($a0)
    syscall
    
    jal convolution
    
    # Open "ouput_matrix.txt"
    addi $v0, $zero, 13 
    la $a0, output_file         		
    addi $a1, $zero, 1 	          
    addi $a2, $zero, 0  
    syscall
    sw $v0, descriptor
    
    la $s0, answer
    la $t0, answer_size
    lw $t0, 0($t0)
    addi $t1, $zero, 0
    main_loop_1:
    	beq $t1, $t0, main_end_loop_1
    	
    	addi $t2, $zero, 0
    	main_loop_2:
    	    beq $t2, $t0, main_end_loop_2
    	    
    	    mul $t3, $t1, $t0
    	    add $t3, $t3, $t2
    	    mul $t3, $t3, 4
    	    add $t3, $s0, $t3
    	    lwc1 $f0, 0($t3)
    	    
    	    jal write_float
    	    
    	    addi $v0, $zero, 15
    	    la $a0, descriptor
    	    lw $a0, 0($a0)
    	    la $a1, space
    	    addi $a2, $zero, 1
    	    syscall
    	    
    	    addi $t2, $t2, 1
    	    j main_loop_2
    	main_end_loop_2:
    	
    	addi $v0, $zero, 15
	la $a0, descriptor
	lw $a0, 0($a0)
	la $a1, newline
	addi $a2, $zero, 1
	syscall
    	
    	addi $t1, $t1, 1
    	j main_loop_1
    main_end_loop_1:
    
    # Close "ouput_matrix.txt"
    addi $v0, $zero, 16    
    la $a0, descriptor 
    lw $a0, 0($a0)
    syscall
    
    # end program
    addi $v0, $zero, 10
    syscall

read_float:
    # Read a string from file and convert to float and store in f0
    # Use: a0, a1, a2, v0, t0, t1, t2, t3, f1, f2
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $a2, 0($sp)
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f1 # Convert floating point register value to integer
    sw $t0, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f2
    sw $t0, 0($sp)
    # Handle
    mtc1 $zero, $f0	# result
    addi $t0, $zero, 0 	# neg flag
    addi $t1, $zero, 0 	# decimal part flag
    addi $t2, $zero, 10
    sw $t2, -88($fp)
    lwc1 $f1, -88($fp)
    cvt.s.w $f1, $f1	
    
    # read char in file
    read_float_loop_1:
    	addi $v0, $zero, 14
	la  $a0, descriptor
	lw $a0, 0($a0)
	la $a1, char   
	addi $a2, $zero, 1 # read 1 char
	syscall
	
	lb $t2, char
	beq $t2, ' ', read_float_end_loop_1
	beq $t2, '\n', read_float_end_loop_1
	beq $t2, '\0', read_float_end_loop_1
	beq $t2, '\r', read_float_end_loop_1
	
	bne $t2, '-', read_float_loop_1_end_check_neg
	addi $t0, $t0, 1
	j read_float_loop_1
	
	read_float_loop_1_end_check_neg:
	bne $t2, '.', read_float_loop_1_end_check_frac
	addi $t1, $t1, 1
	j read_float_loop_1
	
	read_float_loop_1_end_check_frac:
	sub $t2, $t2, '0' # Convert numeric characters to numeric values
	sw $t2, -88($fp)
    	lwc1 $f2, -88($fp)
    	cvt.s.w $f2, $f2 # Load value from stack into $f2
    	# Decimal handling
	beq $t1, 0, read_float_loop_1_handle_dec
	div.s $f2, $f2, $f1
	add.s $f0, $f0, $f2
	addi $t3, $zero, 10
	sw $t3, -88($fp)
    	lwc1 $f2, -88($fp)
    	cvt.s.w $f2, $f2
	mul.s $f1, $f1, $f2
	j read_float_loop_1
	
	read_float_loop_1_handle_dec:
    	mul.s $f0, $f0, $f1
    	add.s $f0, $f0, $f2
    	
    	j read_float_loop_1
    
    read_float_end_loop_1:
    
    beqz $t0, read_float_end_handle_neg
    addi $t2, $zero, -1
    sw $t2, -88($fp)
    lwc1 $f2, -88($fp)
    cvt.s.w $f2, $f2
    mul.s $f0, $f0, $f2
    read_float_end_handle_neg:
   
     # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f2
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
read_image:
    # Read nxn value from file and store into image
    # Use: a0, s0, s1, t0, t1, t2, t3, t4, f0
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f0
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Hanlde
    la $a0, image
    la $t0, n
    lw $t0, 0($t0)
    la $t1, p
    lw $t1, 0($t1)
    mul $t1, $t1, 2
    add $t0, $t0, $t1
    mul $t0, $t0, 4
    add $t0, $a0, $t0
    read_image_loop_1:
    	beq $t0, $a0, read_image_end_loop_1
    	
    	addi $t0, $t0, -4
    	sw $zero, 0($t0)
    	
    	j read_image_loop_1
    
    
    read_image_end_loop_1:
    
    la $a0, image
    la $t0, n
    lw $t0, 0($t0)
    la $s0, p
    lw $s0, 0($s0)
    addi $s1, $s0, 0
    mul $s0, $s0, 2
    add $s0, $t0, $s0
    addi $t1, $zero, 0
    read_image_loop_2:
        beq $t1, $t0, read_image_end_loop_2 # t1 chi so hang hien tai, t0 la kich thuoc gom padding 
        
        addi $t2, $zero, 0 # t2 chi so cot hien tai
        read_image_loop_3:
            beq $t2, $t0, read_image_end_loop_3
            
            add $t3, $t1, $s1 # s1 la padding
            mul $t3, $t3, $s0 # s0 la kich thuoc thuc te => t3 la offset theo hang
            add $t3, $t3, $t2 # tinh tong so phan tu tinh den hien tai => dia chi hien tai
            add $t3, $t3, $s1 # cong padding cot s1 vao t3
            mul $t3, $t3, 4 # chuyen sang dia chi bo nho
            add $t3, $a0, $t3 # tinh dia chi thuc te hien tai
            
            jal read_float
    	    mfc1 $t4, $f0
    	    sw $t4, 0($t3) #ghi gia tri
            
            addi $t2, $t2, 1
            j read_image_loop_3
        read_image_end_loop_3:
        
        addi $t1, $t1, 1
        j read_image_loop_2
    read_image_end_loop_2:
    
    sw $s0, n #luu kich thuc da padding
    
    # Restore registers
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
read_kernel:
    # Read mxm value from file and store into kernel
    # Use: a0, t0, t1, t2, t3, t4, f0
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f0
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # Handle
    la $a0, kernel
    lw $t0, m
    addi $t1, $zero, 0
    read_kernel_loop_1:
    	beq $t1, $t0, read_kernel_end_loop_1
    	    
    	    addi $t2, $zero, 0
    	    read_kernel_loop_2:
    	        beq $t2, $t0, read_kernel_end_loop_2
    	        
    	        mul $t3, $t1, $t0
    	        add $t3, $t3, $t2
    	        mul $t3, $t3, 4
    	        add $t3, $a0, $t3
    	        
    	        jal read_float
    	        mfc1 $t4, $f0
    	        sw $t4, 0($t3)
    	        
    	    	addi $t2, $t2, 1
    	    	j read_kernel_loop_2
    	    read_kernel_end_loop_2:
    	addi $t1, $t1, 1
    	j read_kernel_loop_1
    read_kernel_end_loop_1:
    
    # Restore registers
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ___________________________________________________________________________________________
convolution:
    # Calc convolution
    # Use: a0, a1, a2, t0, t1, t2, t3, t4, t5, t6, t7, f0, f1, f2
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $a2, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4
    sw $t5, 0($sp)
    addi $sp, $sp, -4
    sw $t6, 0($sp)
    addi $sp, $sp, -4
    sw $t7, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f0
    sw $t0, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f1
    sw $t0, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f2
    sw $t0, 0($sp)
   
     # Handle
    # answer_size: [(n - m) / s] + 1
    la $a0, image
    la $a1, kernel
    la $a2, answer
    la $t0, n # t0 luu n
    lw $t0, 0($t0)
    la $t1, m # t1 luu m
    lw $t1, 0($t1)
    la $t3, s
    lw $t3, 0($t3) #t3 luu s 
    sub $t2, $t0, $t1 # tinh su chenh lech 2 ma tran
    div $t2, $t3 # tinh toan so luong steps de xu ly
    mflo $t2
    addi $t2, $t2, 1
    sw $t2, answer_size
    
    addi $t4, $zero, 0 # luu hang hien tai cua answer
    
    # loop1: duyet hang cua answer
    # loop2: duyet cot cua answer
    # loop3: duyet hang kernel
    # loop4: duyet cot kernel va tinh phep chap
    
    convolution_loop_1:
    	beq $t4, $t2, convolution_end_loop_1 #t2 la kich thuoc answer, t4 la so hang hien tai trong answer
    	
    	addi $t5, $zero, 0 #t5 la cot trong answer
    	convolution_loop_2:
    	    beq $t5, $t2, convolution_end_loop_2
    	    
    	    	addi $t6, $zero, 0 # t6 so hang hien tai cua kernel
    	    	mtc1 $zero, $f0 # khoi tao tong tich chap hien tai
    	    	convolution_loop_3:
    	    	    beq $t6, $t1, convolution_end_loop_3 # t1 la kich thuoc ma tran
    	    	    	
    	    	    	addi $t7, $zero, 0 # t7 so cot hien tai cua kernel
    	    	    	convolution_loop_4:
    	    	    	    beq $t7, $t1, convolution_end_loop_4
    	    	    	    # tinh toan dia chi phan tu trong image vaf kernel va thuc hien phep nhan cong
    	    	    	    # tinh dia chi phan tu trong image
    	    	    	    mul $s0, $t4, $t3
    	    	    	    add $s0, $s0, $t6
    	    	    	    mul $s1, $t5, $t3
    	    	    	    add $s1, $s1, $t7
    	    	    	    
    	    	    	    mul $s0, $s0, $t0
    	    	    	    add $s0, $s0, $s1
    	    	    	    mul $s0, $s0, 4
    	    	    	    add $s0, $a0, $s0
    	    	    	    
    	    	    	    lwc1 $f1, 0($s0) # luu gia tri image
    	    	    	    
    	    	    	    # tinh dia chi phan tu trong kernel
    	    	    	    mul $s1, $t6, $t1
    	    	    	    add $s1, $s1, $t7
    	    	    	    mul $s1, $s1, 4
    	    	    	    add $s1, $a1, $s1
    	    	    	    lwc1 $f2, 0($s1) # luu gia tri kernel
    	    	    	    
    	    	    	    # thuc hien phep tinh
    	    	    	    mul.s $f1, $f1, $f2
    	    	    	    add.s $f0, $f0, $f1 # cong don vao tong
    	    	    	    
    	    	    	    addi $t7, $t7, 1
    	    	    	    j convolution_loop_4
    	    	    	convolution_end_loop_4:
    	    	    	
    	    	    addi $t6, $t6, 1
    	    	    j convolution_loop_3
    	    	convolution_end_loop_3:
    	    	# luu vao answer
    	    	mul $t6, $t4, $t2
    	    	add $t6, $t6, $t5
    	    	mul $t6, $t6, 4
    	    	add $t6, $a2, $t6 # cong vao dia chi bat dau cua answer
    	    	mfc1 $t7, $f0
		sw $t7, 0($t6)
    	    
    	    addi $t5, $t5, 1
    	    j convolution_loop_2
    	convolution_end_loop_2:
    	
    	addi $t4, $t4, 1
    	j convolution_loop_1
    convolution_end_loop_1:
    # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f2
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t7, 0($sp)
    addi $sp, $sp, 4
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
write_float:
    # write float value stored in f0 to file
    # Use: a0, a1, a2, v0, t0, t1, t2, t3, t4, f0, f1
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $a2, 0($sp)
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f0
    sw $t0, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f1
    sw $t0, 0($sp)
    # Handle
    la $a0, buffer
    addi $t0, $zero, 0
    
    addi $t1, $zero, 10000
    sw $t1, -88($fp)
    lwc1 $f1, -88($fp)
    cvt.s.w $f1, $f1
    mul.s $f0, $f0, $f1
    round.w.s $f0, $f0
    mfc1 $t1, $f0
    
    addi $t4, $zero, 0
    blt $t1, $zero, write_float_check_neg
    j write_float_end_check_neg
    write_float_check_neg:
	addi $t4, $zero, 1	# Negative flag
    	mul $t1, $t1, -1
    write_float_end_check_neg:
    
    addi $t2, $zero, 10000
    div $t1, $t2
    mflo $t1
    mfhi $t2
    
    write_float_loop_dec:
        addi $t3, $zero, 10
        div $t1, $t3
        mflo $t1
        mfhi $t3
        
        addi $t3, $t3, '0'
        addi $sp, $sp, -1
        sb $t3, 0($sp)
        addi $t0, $t0, 1
        
        bnez $t1, write_float_loop_dec
       
    beqz $t4, write_float_end_hande_neg
    addi $sp, $sp, -1
    addi $t3, $zero, '-'
    sb $t3, 0($sp)
    addi $t0, $t0, 1
    write_float_end_hande_neg:
    
    add $t3, $zero, $t0
    write_float_loop_rev:
       	beqz $t3, write_float_end_loop_rev
    	lb $t4, 0($sp)
    	addi $sp, $sp, 1
    	sb $t4, 0($a0)
    	addi $a0, $a0, 1
    	addi $t3, $t3, -1
    	
    	j write_float_loop_rev
    write_float_end_loop_rev:
    
    addi $t3, $zero, '.'
    sb $t3, 0($a0)
    addi $a0, $a0, 1
    addi $t0, $t0, 1
    
    addi $t1, $zero, 4
    write_float_loop_frac:
        addi $t3, $zero, 10
        div $t2, $t3
        mflo $t2
        mfhi $t3
        
        addi $t3, $t3, '0'
        addi $sp, $sp, -1
        sb $t3, 0($sp)
        addi $t1, $t1, -1
        
        bnez $t1, write_float_loop_frac
        
    addi $t3, $zero, 4
    write_float_loop_frac_rev:
       	beqz $t3, write_float_end_loop_frac_rev
    	lb $t4, 0($sp)
    	addi $sp, $sp, 1
    	sb $t4, 0($a0)
    	addi $a0, $a0, 1
    	addi $t0, $t0, 1
    	addi $t3, $t3, -1
    	
    	j write_float_loop_frac_rev
    write_float_end_loop_frac_rev:
    
    # Write buffer to file
    addi $v0, $zero, 15
    la $a0, descriptor
    lw $a0, 0($a0)
    la $a1, buffer
    add $a2, $zero, $t0
    syscall
    
    # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
