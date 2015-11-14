`timescale 1ns / 1ps

module dummy_parallella_io(
                           CCLK_P,
                           CCLK_N,

                           DSP_RESET_N,

                           //RX
                           RX_WR_WAIT_P,
                           RX_WR_WAIT_N,
                           RX_RD_WAIT_P,
                           RX_RD_WAIT_N,

                           RX_LCLK_P,
                           RX_LCLK_N,
                           RX_FRAME_P,
                           RX_FRAME_N,
                           RX_DATA_P,
                           RX_DATA_N,

                           //TX
                           TX_LCLK_P,
                           TX_LCLK_N,
                           TX_FRAME_P,
                           TX_FRAME_N,
                           TX_DATA_P,
                           TX_DATA_N,
                           TX_WR_WAIT_P,
                           TX_WR_WAIT_N,
                           TX_RD_WAIT_P,
                           TX_RD_WAIT_N,

                           //GPIO
                           PS_GPIO_I,
                           GPIO_P,
                           GPIO_N,
                           PS_GPIO_O,
                           PS_GPIO_T,

                           I2C_SDA_I,
                           I2C_SCL_I,
                           I2C_SDA,
                           I2C_SCL,
                           I2C_SDA_O,
                           I2C_SDA_T,
                           I2C_SCL_O,
                           I2C_SCL_T
                           );

   parameter  IOSTD_ELINK = "LVDS_25";

   parameter  NUM_GPIO_PAIRS = 24;       // 12 or 24
   parameter  DIFF_GPIO      = 0;        // 0 or 1
   parameter  NUM_PS_SIGS    = 64;


   output                               CCLK_P;
   output                               CCLK_N;

   output [0:0]                         DSP_RESET_N;

   //RX
   output                               RX_WR_WAIT_P;
   output                               RX_WR_WAIT_N;
   output                               RX_RD_WAIT_P;
   output                               RX_RD_WAIT_N;
   input                                RX_LCLK_P;
   input                                RX_LCLK_N;
   input                                RX_FRAME_P;
   input                                RX_FRAME_N;
   input [7:0]                          RX_DATA_P;
   input [7:0]                          RX_DATA_N;

   //TX
   output                               TX_LCLK_P;
   output                               TX_LCLK_N;
   output                               TX_FRAME_P;
   output                               TX_FRAME_N;
   output [7:0]                         TX_DATA_P;
   output [7:0]                         TX_DATA_N;
   input                                TX_WR_WAIT_P;
   input                                TX_WR_WAIT_N;
   input                                TX_RD_WAIT_P;
   input                                TX_RD_WAIT_N;

   //GPIO
   inout [NUM_GPIO_PAIRS-1:0] GPIO_P;
   inout [NUM_GPIO_PAIRS-1:0] GPIO_N;

   output [NUM_PS_SIGS-1:0]  PS_GPIO_I;
   input  [NUM_PS_SIGS-1:0]  PS_GPIO_O;
   input  [NUM_PS_SIGS-1:0]  PS_GPIO_T;


   //I2C
   input  I2C_SDA_O;
   input  I2C_SDA_T;
   output I2C_SDA_I;

   input  I2C_SCL_O;
   input  I2C_SCL_T;
   output I2C_SCL_I;

   inout  I2C_SDA;
   inout  I2C_SCL;


   ////////////////////////////////////////////////////////////////
   //  RESET and clocks
   ////////////////////////////////////////////////////////////////

   assign DSP_RESET_N[0] = 0;


   // CCLK_P|N
   wire                                 cclk;
   assign cclk = 0;

   OBUFDS
     #(.IOSTANDARD (IOSTD_ELINK))
   obufds_cclk_inst
     (.O   (CCLK_P),
      .OB  (CCLK_N),
      .I   (cclk));

   ////////////////////////////////////////////////////////////////
   //  RX part
   ////////////////////////////////////////////////////////////////
   wire                                 rx_wr_wait;
   wire                                 rx_rd_wait;

   wire [7:0]                           rx_data;
   wire                                 rx_frame;

   wire                                 rxlclk_p;


   assign rx_wr_wait = 1'bz;
   assign rx_rd_wait = 1'bz;

   IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_rxdata[0:7]
     (.I     (RX_DATA_P),
      .IB    (RX_DATA_N),
      .O     (rx_data));

   IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_rxframe
     (.I     (RX_FRAME_P),
      .IB    (RX_FRAME_N),
      .O     (rx_frame));

   IBUFGDS
     #(.DIFF_TERM  ("TRUE"),   // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_rxlclk
     (.I          (RX_LCLK_P),
      .IB         (RX_LCLK_N),
      .O          (rxlclk_p));

   OBUFDS
     #(.IOSTANDARD(IOSTD_ELINK),
       .SLEW("SLOW"))
   OBUFDS_RXWRWAIT
     (
      .O(RX_WR_WAIT_P),
      .OB(RX_WR_WAIT_N),
      .I(rx_wr_wait));

   OBUFDS
     #(.IOSTANDARD(IOSTD_ELINK),
       .SLEW("SLOW"))
   OBUFDS_RXRDWAIT
     (
      .O(RX_RD_WAIT_P),
      .OB(RX_RD_WAIT_N),
      .I(rx_rd_wait));



   ////////////////////////////////////////////////////////////////
   //  TX part
   ////////////////////////////////////////////////////////////////

   //############
   //# WIRES
   //############
   wire [7:0]    tx_data;  // High-speed serial data outputs
   wire [7:0]    tx_data_t; // Tristate signal to OBUF's
   wire          tx_frame; // serial frame signal
   wire          tx_lclk;

   wire          tx_wr_wait;


   assign tx_data   = 8'hF;
   assign tx_data_t = 8'hF;
   assign tx_frame  = 0;
   assign tx_lclk   = 1;


   //################################
   //# Output Buffers
   //################################
   OBUFTDS
     #(.IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST"))
   OBUFTDS_txdata [7:0]
     (
      .O   (TX_DATA_P),
      .OB  (TX_DATA_N),
      .I   (tx_data),
      .T   (tx_data_t));

   OBUFDS
     #(.IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST"))
   OBUFDS_txframe
     (
      .O   (TX_FRAME_P),
      .OB  (TX_FRAME_N),
      .I   (tx_frame));

   OBUFDS
     #(.IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST"))
   OBUFDS_lclk
     (
      .O   (TX_LCLK_P),
      .OB  (TX_LCLK_N),
      .I   (tx_lclk));

   //################################
   //# Wait Input Buffers
   //################################

   IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
     (.I     (TX_WR_WAIT_P),
      .IB    (TX_WR_WAIT_N),
      .O     (tx_wr_wait));


   wire xx;
   assign xx = TX_RD_WAIT_N|TX_RD_WAIT_P;
   wire _t;
   just_xor _xor(xx, _t, _t);

   //################################
   //# call elink GPIO module
   //################################
   parallella_gpio_emio
     #(
       .NUM_GPIO_PAIRS (NUM_GPIO_PAIRS),
       .DIFF_GPIO      (DIFF_GPIO     ),
       .NUM_PS_SIGS    (NUM_PS_SIGS   ))
   p_gpio_inst
     (
      .PS_GPIO_I (PS_GPIO_I),
      .GPIO_P    (GPIO_P),
      .GPIO_N    (GPIO_N),
      .PS_GPIO_O (PS_GPIO_O),
      .PS_GPIO_T (PS_GPIO_T));


   //################################
   //# call elink I2C module
   //################################
   parallella_i2c p_i2c
     (.I2C_SDA_O (I2C_SDA_O),
      .I2C_SDA_T (I2C_SDA_T),
      .I2C_SDA_I (I2C_SDA_I),
      .I2C_SCL_O (I2C_SCL_O),
      .I2C_SCL_T (I2C_SCL_T),
      .I2C_SCL_I (I2C_SCL_I),
      .I2C_SDA   (I2C_SDA  ),
      .I2C_SCL   (I2C_SCL  ));



endmodule

module just_xor(input a, input b, output c);
assign c = a^b;
endmodule