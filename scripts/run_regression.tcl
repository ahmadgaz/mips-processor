# -----------------------------
# Configuration
# -----------------------------
set TEST_DIR  "sim/tests"
set MEMFILE   "sim/imem.hex"

# Fail fast if any test fails
set failed 0

# -----------------------------
# Collect tests: all .hex in sim/tests, sorted
# -----------------------------
set hex_files [lsort [glob -nocomplain -directory $TEST_DIR *.hex]]

if {[llength $hex_files] == 0} {
  puts "ERROR: No .hex files found in $TEST_DIR"
  exit 2
}

puts "Found [llength $hex_files] test(s) in $TEST_DIR"

# -----------------------------
# Create project (in-memory)
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

set pkg_files [lsort [findFiles "pkg" "*.sv"]]
set rtl_files [lsort [findFiles "rtl" "*.sv"]]
exec xvlog -sv -work work {*}$pkg_files {*}$rtl_files sim/tb_mips_soc.sv

# -----------------------------
# Regression loop
# -----------------------------
foreach hex $hex_files {

  # Base name without extension, e.g. 00-add
  set base [file rootname [file tail $hex]]
  set exp  [file join $TEST_DIR "${base}.exp"]

  puts "\n====================================="
  puts " Running test: $base"
  puts "   PROG: $hex"
  puts "   EXP : $exp"
  puts "====================================="

  if {![file exists $exp]} {
    puts "(E) MISSING EXPECT FILE: $exp"
    set failed 1
    break
  }

  # Copy program into memfile (RTL-compatible)
  file copy -force $hex $MEMFILE

  # Elaborate (unique sim snapshot per test)
  set snapshot "sim_${base}"
  exec xelab tb_mips_soc -debug typical -s $snapshot

  # Run simulation
  set result ""
  set rc [catch {
    exec xsim $snapshot -runall \
      -testplusarg "EXPECT=$exp" \
      -testplusarg "VERBOSE=1" \
      -testplusarg "WAVES=1"
  } result]

  # Detect failure (catch nonzero OR look for FATAL)
  if {$rc != 0 || [string match "*FATAL*" $result]} {
    puts "(E) TEST FAILED: $base"
    puts "---- xsim output ----"
    puts $result
    puts "---------------------"
    set failed 1
    break
  } else {
    puts "(S) TEST PASSED: $base"
  }
}

# -----------------------------
# Final result
# -----------------------------
if {$failed} {
  puts "\nREGRESSION FAILED"
  exit 1
} else {
  puts "\nREGRESSION PASSED"
  exit 0
}
