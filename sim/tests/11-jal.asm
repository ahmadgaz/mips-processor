main: addi $t0, $zero, 0
      jal  func
      addi $t0, $t0, 1          # executed after return
      j    done
      sll  $zero, $zero, 0
func: addi $t1, $zero, 0x0055
      jr   $ra
      sll  $zero, $zero, 0
done: sll  $zero, $zero, 0
halt: sll  $zero, $zero, 0      # PC = 0x24
      j    halt
      sll  $zero, $zero, 0
