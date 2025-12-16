main: addi $t0, $zero, 7
      addi $t1, $zero, 5
      add  $t2, $t0, $t1        # 12
      addi $t3, $zero, -3       # 0xFFFFFFFD
      add  $t4, $t3, $t1        # 2
halt: sll  $zero, $zero, 0      # PC = 0x14
      j    halt
      sll  $zero, $zero, 0
