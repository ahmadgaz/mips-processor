# -----------------------------
# Config
# -----------------------------
set TEST_DIR  "../sim/tests"
set MEMFILE   "imem.hex"

set OUTDIR "lint"
file mkdir $OUTDIR
cd $OUTDIR

# -----------------------------
# Collect all .hex in sim/tests sorted
# -----------------------------
set hex_files [lsort [glob -nocomplain -directory $TEST_DIR *.hex]]

if {[llength $hex_files] == 0} {
  puts "ERROR: No .hex files found in $TEST_DIR"
  exit 2
}


set hex [lindex $hex_files 0]
puts "Found 1 test in $TEST_DIR: $hex"
file copy -force $hex $MEMFILE

# -----------------------------
# Create project in-memory
# -----------------------------
create_project -in_memory -part xc7a35tcpg236-1

proc findFiles { baseDir pattern } {
  set all_files {}
  set contents [glob -nocomplain -directory $baseDir *]
  foreach item $contents {
    if {[file isdirectory $item]} {
      lappend all_files {*}[findFiles $item $pattern]
    }
  }
  lappend all_files {*}[glob -nocomplain -directory $baseDir -types f $pattern]
  return $all_files
}

set pkg_files [lsort [findFiles "../pkg" "*.sv"]]
set rtl_files [lsort [findFiles "../rtl" "*.sv"]]
read_verilog -sv {*}$pkg_files {*}$rtl_files

# -----------------------------
# Run synth
# -----------------------------
set err ""
set rc [catch { synth_design -rtl -top mips_soc } err]
if {$rc != 0} {
  puts stderr "\nLINT FAILED: synth_design threw error:\n$err"
  exit 1
}

set msgs [get_messages -severity WARNING CRITICAL_WARNING ERROR]
if {[llength $msgs] > 0} {
  puts stderr "\nLINT FAILED: found [llength $msgs] WARNING/CRITICAL_WARNING/ERROR message(s)"
  puts "---- messages ----"
  foreach m $msgs {
    puts stderr [get_property MESSAGE_TEXT $m]
  }
  puts "------------------"
  exit 1
}

puts "\nLINT PASSED"
exit 0
