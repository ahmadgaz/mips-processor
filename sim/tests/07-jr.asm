main:   addi $t1, $zero, 0x1234
        addi $t0, $zero, target
        jr   $t0
        sll  $zero, $zero, 0      # (safe slot)
        addi $t1, $t1, 1          # should be skipped
target: addi $t2, $zero, 0x2222
halt:   sll  $zero, $zero, 0      # PC = 0x18
        j    halt
        sll  $zero, $zero, 0
