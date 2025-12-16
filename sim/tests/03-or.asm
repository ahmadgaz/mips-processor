main: addi $t0, $zero, 0x0F0F
      sll  $t0, $t0, 16
      addi $t0, $t0, 0x0F0F       # 0x0F0F0F0F
      addi $t1, $zero, 0x00FF
      sll  $t1, $t1, 16
      addi $t1, $t1, 0x00FF       # 0x00FF00FF
      or   $t2, $t0, $t1          # 0x0FFF0FFF
halt: sll  $zero, $zero, 0        # PC = 0x1c
      j    halt
      sll  $zero, $zero, 0
