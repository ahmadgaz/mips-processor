main: addi $t0, $zero, -1
      sll  $t0, $t0, 16           # t0 = 0xFFFF0000
      addi $t1, $zero, 1
      sll  $t1, $t1, 16           # t1 = 0x00010000
      multu $t0, $t1
      mfhi  $t2                   # 0x0000FFFF
      mflo  $t3                   # 0x00000000
halt: sll  $zero, $zero, 0        # PC = 0x1c
      j    halt
      sll  $zero, $zero, 0
