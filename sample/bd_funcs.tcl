proc create_empty_design { parentCell n_gpio } {

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
  set_property -dict [ list CONFIG.NUM_GPIO_PAIRS "$n_gpio" ] $dummy_parallella_io_0

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

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}


proc add_my_mult_axislite { parentCell } {

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

  # Create instance: my_multiplier_0, and set properties
  set my_multiplier_0 [ create_bd_cell -type ip -vlnv kk:user:my_multiplier:1.0 my_multiplier_0 ]

  set processing_system7_0 [get_bd_cells processing_system7_0]
  set_property -dict [ list CONFIG.PCW_USE_M_AXI_GP0 {1} ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {1} ] $processing_system7_0_axi_periph

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins my_multiplier_0/S00_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]

  # Create port connections
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins processing_system7_0_axi_periph/ARESETN]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins my_multiplier_0/s00_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins my_multiplier_0/s00_axi_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK]

  # Create address segments
  create_bd_addr_seg -range 0x1000 -offset 0x70020000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs my_multiplier_0/S00_AXI/S00_AXI_reg] SEG_my_multiplier_0_S00_AXI_reg

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
