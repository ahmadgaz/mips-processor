# -----------------------------
# Config
# -----------------------------
set OUTDIR "lint"
file mkdir $OUTDIR
cd $OUTDIR

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
synth_design -rtl -top mips_soc
puts "RTL lint completed successfully."
exit 0
