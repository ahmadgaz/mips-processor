main: addi $t0, $zero, 1
      sll  $t0, $t0, 31           # t0 = 0x80000000
      srl  $t1, $t0, 31           # 1
      srl  $t2, $t0, 1            # 0x40000000
halt: sll  $zero, $zero, 0        # PC = 0x10
      j    halt
      sll  $zero, $zero, 0
