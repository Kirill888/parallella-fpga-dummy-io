set ::orig_dir [file normalize [file dirname [info script]]]

source "$orig_dir/bd_funcs.tcl"



proc mk_proj { name {model 7010} {out_dir .} } {
    set base_dir        [file normalize $::orig_dir/.. ]
    set ip_repo_dir     [file normalize "$base_dir/ip_repo"]
    set constraints_dir [file normalize "$base_dir/constraints"]
    set design_name "top"

    puts "mk_proj: $name $model"
    puts "IP: $ip_repo_dir"
    puts "Constraints: $constraints_dir"

    if { $model == 7020 } {
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

    # Create project
    create_project $name $out_dir/$name

    # Set project properties
    set obj [get_projects $name]
    set_property "default_lib" "xil_defaultlib" $obj
    set_property "part" "$PART" $obj
    set_property "sim.ip.auto_export_scripts" "1" $obj

    # Create 'sources_1' fileset (if not found)
    if {[string equal [get_filesets -quiet sources_1] ""]} {
	create_fileset -srcset sources_1
    }

    # Set IP repository paths
    set obj [get_filesets sources_1]
    set_property "ip_repo_paths" "[file normalize $ip_repo_dir]" $obj

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
	set file [file normalize "$constraints_dir/$cf"]
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

    create_empty_design "" $NGPIO

    # Generate the wrapper
    set design_name [get_bd_designs]
    make_wrapper -files [get_files $design_name.bd] -top -import

    # Set 'sources_1' fileset properties
    set obj [get_filesets sources_1]
    set_property "top" "${design_name}_wrapper" $obj
}
