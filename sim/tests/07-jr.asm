main: addi $t1, $zero, 5        # t1 = 5
      jal  subr                 # call subroutine
      sll  $zero, $zero, 0      # safe slot (NOP)
      addi $t1, $t1, 1          # executes after return -> t1 = 6
      j    halt
      sll  $zero, $zero, 0
subr: addi $t2, $zero, 7        # t2 = 7
      jr   $ra                  # return (THIS is what we're testing)
      sll  $zero, $zero, 0      # safe slot (NOP)
halt: sll  $zero, $zero, 0      # PC = 0x24
      j    halt
      sll  $zero, $zero, 0
