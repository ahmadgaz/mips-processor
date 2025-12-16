main: addi $t0, $zero, -1     # -1
      addi $t1, $zero, 1      # 1
      slt  $t2, $t0, $t1      # (-1 < 1) = 1
      slt  $t3, $t1, $t0      # (1 < -1) = 0
halt: sll  $zero, $zero, 0    # PC = 0x10
      j    halt
      sll  $zero, $zero, 0
