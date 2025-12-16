main: addi $t0, $zero, 20
      addi $t1, $zero, 7
      sub  $t2, $t0, $t1        # 13
      sub  $t3, $t1, $t0        # -13 = 0xFFFFFFF3
halt: sll  $zero, $zero, 0      # PC = 0x10
      j    halt
      sll  $zero, $zero, 0
