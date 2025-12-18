main: addi $t0, $zero, 0x0F0F
      sw   $t0, 0($zero)
      lw   $t1, 0($zero)
halt: sll  $zero, $zero, 0    # PC = 0x10
      j    halt
      sll  $zero, $zero, 0
