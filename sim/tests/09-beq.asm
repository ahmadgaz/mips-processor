main:   addi $t0, $zero, 5
        addi $t1, $zero, 5
        addi $t2, $zero, 1
        beq  $t0, $t1, taken
        addi $t2, $t2, 1          # should be skipped if branch taken
taken:  addi $t3, $zero, 0x007B   # 123
halt:   sll  $zero, $zero, 0      # PC = 0x18
        j    halt
        sll  $zero, $zero, 0
