
################################################################
# This is a generated script based on design: top
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source top_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

if { ![info exists NGPIO] } {
    puts "Defaulting to 24 GPIO pins"
    set NGPIO 24
}


# CHANGE DESIGN NAME HERE
set design_name top

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell n_gpio } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set RX [ create_bd_intf_port -mode Slave -vlnv adapteva.com:interface:eLink_rtl:1.0 RX ]
  set TX [ create_bd_intf_port -mode Master -vlnv adapteva.com:interface:eLink_rtl:1.0 TX ]

  # Create ports
  set CCLK_N [ create_bd_port -dir O CCLK_N ]
  set CCLK_P [ create_bd_port -dir O CCLK_P ]
  set DSP_RESET_N [ create_bd_port -dir O -from 0 -to 0 DSP_RESET_N ]
  set GPIO_N [ create_bd_port -dir IO -from [expr {$n_gpio - 1}] -to 0 GPIO_N ]
  set GPIO_P [ create_bd_port -dir IO -from [expr {$n_gpio - 1}] -to 0 GPIO_P ]
  set I2C_SCL [ create_bd_port -dir IO I2C_SCL ]
  set I2C_SDA [ create_bd_port -dir IO I2C_SDA ]

  # Create instance: dummy_parallella_io_0, and set properties
  set dummy_parallella_io_0 [ create_bd_cell -type ip -vlnv k88k:user:dummy_parallella_io:1.0 dummy_parallella_io_0 ]
  set_property -dict [ list \
CONFIG.NUM_GPIO_PAIRS "$n_gpio" \
 ] $dummy_parallella_io_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_EN_CLK3_PORT {1} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD1_SD1_IO {MIO 10 .. 15} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {.434} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {.398} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {.410} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {.455} \
CONFIG.PCW_UIPARAM_DDR_CL {9} \
CONFIG.PCW_UIPARAM_DDR_CWL {9.00} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {8192 MBits} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {.315} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {.391} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {.374} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {.271} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {32 Bits} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {400} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_UIPARAM_DDR_T_FAW {50} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {40} \
CONFIG.PCW_UIPARAM_DDR_T_RC {60} \
CONFIG.PCW_UIPARAM_DDR_T_RCD {9} \
CONFIG.PCW_UIPARAM_DDR_T_RP {9} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USE_M_AXI_GP0 {0} \
CONFIG.PCW_USE_M_AXI_GP1 {0} \
CONFIG.PCW_USE_S_AXI_HP1 {0} \
 ] $processing_system7_0

  # Create interface connections
  connect_bd_intf_net -intf_net RX_1 [get_bd_intf_ports RX] [get_bd_intf_pins dummy_parallella_io_0/RX]
  connect_bd_intf_net -intf_net dummy_parallella_io_0_TX [get_bd_intf_ports TX] [get_bd_intf_pins dummy_parallella_io_0/TX]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_GPIO_0 [get_bd_intf_pins dummy_parallella_io_0/GPIO] [get_bd_intf_pins processing_system7_0/GPIO_0]
  connect_bd_intf_net -intf_net processing_system7_0_IIC_0 [get_bd_intf_pins dummy_parallella_io_0/I2C] [get_bd_intf_pins processing_system7_0/IIC_0]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports GPIO_P] [get_bd_pins dummy_parallella_io_0/GPIO_P]
  connect_bd_net -net Net1 [get_bd_ports GPIO_N] [get_bd_pins dummy_parallella_io_0/GPIO_N]
  connect_bd_net -net Net2 [get_bd_ports I2C_SDA] [get_bd_pins dummy_parallella_io_0/I2C_SDA]
  connect_bd_net -net Net3 [get_bd_ports I2C_SCL] [get_bd_pins dummy_parallella_io_0/I2C_SCL]
  connect_bd_net -net dummy_parallella_io_0_CCLK_N [get_bd_ports CCLK_N] [get_bd_pins dummy_parallella_io_0/CCLK_N]
  connect_bd_net -net dummy_parallella_io_0_CCLK_P [get_bd_ports CCLK_P] [get_bd_pins dummy_parallella_io_0/CCLK_P]
  connect_bd_net -net dummy_parallella_io_0_DSP_RESET_N [get_bd_ports DSP_RESET_N] [get_bd_pins dummy_parallella_io_0/DSP_RESET_N]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port RX -pg 1 -y 360 -defaultsOSRD
preplace port DDR -pg 1 -y 70 -defaultsOSRD
preplace port CCLK_N -pg 1 -y 350 -defaultsOSRD
preplace port I2C_SDA -pg 1 -y 430 -defaultsOSRD
preplace port CCLK_P -pg 1 -y 330 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 90 -defaultsOSRD
preplace port TX -pg 1 -y 310 -defaultsOSRD
preplace port I2C_SCL -pg 1 -y 450 -defaultsOSRD
preplace portBus GPIO_N -pg 1 -y 410 -defaultsOSRD
preplace portBus GPIO_P -pg 1 -y 390 -defaultsOSRD
preplace portBus DSP_RESET_N -pg 1 -y 370 -defaultsOSRD
preplace inst dummy_parallella_io_0 -pg 1 -lvl 2 -y 380 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 2 -y 180 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 1 -y 130 -defaultsOSRD
preplace netloc processing_system7_0_DDR 1 1 2 NJ 70 NJ
preplace netloc RX_1 1 0 2 NJ 360 NJ
preplace netloc dummy_parallella_io_0_DSP_RESET_N 1 2 1 NJ
preplace netloc dummy_parallella_io_0_CCLK_N 1 2 1 NJ
preplace netloc processing_system7_0_FCLK_RESET0_N 1 1 1 280
preplace netloc processing_system7_0_IIC_0 1 1 1 260
preplace netloc dummy_parallella_io_0_CCLK_P 1 2 1 NJ
preplace netloc dummy_parallella_io_0_TX 1 2 1 NJ
preplace netloc processing_system7_0_FIXED_IO 1 1 2 NJ 90 NJ
preplace netloc processing_system7_0_GPIO_0 1 1 1 270
preplace netloc Net1 1 2 1 N
preplace netloc Net 1 2 1 N
preplace netloc processing_system7_0_FCLK_CLK0 1 1 1 250
preplace netloc Net2 1 2 1 NJ
preplace netloc Net3 1 2 1 NJ
levelinfo -pg 1 -50 110 470 660 -top 0 -bot 500
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design "" $NGPIO


