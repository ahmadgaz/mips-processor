main:   addi $t0, $zero, 1
        j    target
        addi $t0, $zero, 2        # should be skipped
target: addi $t1, $zero, 3
halt:   sll  $zero, $zero, 0      # PC = 0x10
        j    halt
        sll  $zero, $zero, 0
