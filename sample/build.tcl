set origin_dir [file dirname [info script]]

variable script_file
set script_file "build.tcl"

set BD "my_mult_axi_lite"
set MODEL 7020

# Help information for this script
proc help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--name <project name>\] Set project name \n"
  puts "\[--7010\]                Generate project for 7010 model\n"
  puts "\[--7020\]                Generate project for 7020 model\n"
  puts "\[--empty\]               Do not include sample custom ip\n"
  puts "\[--help\]                Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < [llength $::argv]} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--name"       { incr i; set PROJECT_NAME [lindex $::argv $i] }
      "--bd"         { incr i; set BD           [lindex $::argv $i] }
      "--help"       { help }
      "--7010"       { set MODEL 7010  }
      "--7020"       { set MODEL 7020  }
      "--empty"      { set BD "empty" }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

source $origin_dir/proj_funcs.tcl

mk_proj $PROJECT_NAME $MODEL

# Optionally add to block design
if { [string equal $BD "my_mult_axi_lite"] } {add_my_mult_axislite "" }
if { [string equal $BD "dma_loopback"    ] } {add_axi_dma_loopback "" }

# re-generate the wrapper
set design_name [get_bd_designs]
make_wrapper -force -files [get_files $design_name.bd] -top -import
