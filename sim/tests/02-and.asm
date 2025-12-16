main: addi $t0, $zero, 0x0F0F
      sll  $t0, $t0, 16
      addi $t0, $t0, 0x0F0F       # t0 = 0x0F0F0F0F
      addi $t1, $zero, 0x00FF
      sll  $t1, $t1, 16
      addi $t1, $t1, 0x00FF       # t1 = 0x00FF00FF
      and  $t2, $t0, $t1          # t2 = 0x000F000F
halt: sll  $zero, $zero, 0        # PC = 0x1C
      j    halt
      sll  $zero, $zero, 0
