# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [file dirname [info script]]

variable script_file
set script_file "build.tcl"

# CHANGE DESIGN NAME HERE
set design_name top

set BD "my_mult_axi_lite"

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
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
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
      "--origin_dir" { incr i; set origin_dir   [lindex $::argv $i] }
      "--name"       { incr i; set PROJECT_NAME [lindex $::argv $i] }
      "--base"	     { incr i; set BASE         [lindex $::argv $i] }
      "--repo"       { incr i; set IP_REPO      [lindex $::argv $i] }
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

# Custom variable one can override from inside Vivado TCL shell
# before sourcing this script
#
if { ! [info exists BASE           ]} {set BASE            [file normalize "$origin_dir/.."] }
if { ! [info exists MODEL          ]} {set MODEL           7020 }
if { ! [info exists PROJECT_NAME   ]} {set PROJECT_NAME    "my_mult" }
if { ! [info exists GEN_EMPTY      ]} {set GEN_EMPTY       0 }
if { ! [info exists IP_REPO        ]} {set IP_REPO         [file normalize "$BASE/ip_repo"     ]}
if { ! [info exists CONSTRAINTS_DIR]} {set CONSTRAINTS_DIR [file normalize "$BASE/constraints" ]}

puts "ROOT: [file normalize $origin_dir]"
puts "IP_REPO: $IP_REPO"
puts "CONSTRAINTS_DIR: $CONSTRAINTS_DIR"


if { $MODEL == 7020 } {
    puts "Generating for 7020"
    set PART "xc7z020clg400-1"
    set NGPIO 24
    set constraint_files [list parallella_z70x0_loc.xdc parallella_z7020_loc.xdc]
} else {
    puts "Generating for 7010"
    set PART "xc7z010clg400-1"
    set NGPIO 12
    set constraint_files [list parallella_z70x0_loc.xdc]
}
    

set orig_proj_dir "[file normalize "." ]"
# Create project
create_project $PROJECT_NAME ./$PROJECT_NAME

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $PROJECT_NAME]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "$PART" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize $IP_REPO]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

foreach cf $constraint_files {
    # Add/Import constrs file and set constrs file properties
    set file [file normalize "$CONSTRAINTS_DIR/$cf"]
    set file_added [add_files -norecurse -fileset $obj $file]
    set_property "file_type" "XDC" $file_added
    import_files -fileset $obj $file
}

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "${design_name}_wrapper" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part $PART -flow {Vivado Synthesis 2015} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2015" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" "$PART" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part $PART -flow {Vivado Implementation 2015} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2015" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" "$PART" $obj
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]


puts "Generating Block Design"

puts "INFO: Creating <$design_name> in project"
create_bd_design $design_name
puts "INFO: Making design <$design_name> as current_bd_design."
current_bd_design $design_name

source $origin_dir/bd_funcs.tcl

create_empty_design "" $NGPIO

# Create block design
if { [string equal $BD "my_mult_axi_lite"] } {add_my_mult_axislite "" }
if { [string equal $BD "dma_loopback"    ] } {add_axi_dma_loopback "" }

# Generate the wrapper
set design_name [get_bd_designs]
make_wrapper -files [get_files $design_name.bd] -top -import

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" "${design_name}_wrapper" $obj

puts "INFO: Project created:$PROJECT_NAME"
