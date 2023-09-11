//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}= restart_game || ~ (KEY[0]);

	//Our A/D converter is only 12 bit
	/*assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	*/
	
	assign VGA_R = Red;
	assign VGA_B = Blue;
	assign VGA_G = Green; 
	
	lab62soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode)
		
	 );


//instantiate a vga_controller, ball, and color_mapper here with the ports.
logic [7:0] BKG_R, BKG_G, BKG_B;
logic slice0, slice1, slice2, sliced0, sliced1, sliced2, startslice, startsliced, resetf0, resetf1, resetf2, lives, livesupdate, LD_SLICE0, LD_SLICE1, LD_SLICE2, start_cut, start_screen, throw_fruit, end_screen, offstage0, offstage1, offstage2, scoreupdate;

vga_controller vga(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));
ball b0(.Reset(Reset_h), .frame_clk(VGA_VS), .BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig), .keycode(keycode));
color_mapper colormap( .BallX(ballxsig), .BallY(ballysig), .Ball_size(ballsizesig), .DrawX(drawxsig), .DrawY(drawysig), 
								.Red(Red), .Green(Green), .Blue(Blue),.BKG_R(BKG_R),.BKG_G(BKG_G),.BKG_B(BKG_B), .START_R(START_R), .START_G(START_G), .START_B(START_B),
								.Clk(VGA_clk), .Reset(Reset_h),
								.startX(startxsig), .startY(startysig), .startS(startsizesig),
								.f0X(fruit0xsig), .f0Y(fruit0ysig), .f0S(fruit0sizesig),
								.f1X(fruit1xsig), .f1Y(fruit1ysig), .f1S(fruit1sizesig),
								.f2X(fruit2xsig), .f2Y(fruit2ysig), .f2S(fruit2sizesig),
								.offstage0(offstage0), .offstage1(offstage1), .offstage2(offstage2),
								.HEART_R0(HEART_R2), .HEART_G0(HEART_G2), .HEART_B0(HEART_B2), .HEART_R1(HEART_R1), .HEART_G1(HEART_G1), .HEART_B1(HEART_B1), .HEART_R2(HEART_R0), .HEART_G2(HEART_G0), .HEART_B2(HEART_B0),
								.OVER_R(OVER_R), .OVER_G(OVER_G),.OVER_B(OVER_B), .WATER_R(WATER_R), .WATER_G(WATER_G), .WATER_B(WATER_B), 
								.score(total), .newscore(newscore),
								
								.lives(lives), .newlives(newlives),
								
								.slice0(slice0), .slice1(slice1), .slice2(slice2),
								.sliced0(sliced0), .sliced1(sliced1), .sliced2(sliced2),
								.startslice(startslice), .startsliced(startsliced),
								.resetf0(resetf0), .resetf1(resetf1), .resetf2(resetf2), .restart_game(restart_game),
								.start_cut(start_cut), .start_screen(start_screen), .throw_fruit(throw_fruit), .end_screen(1'b1)  // FSM signals
								);
// Draw ROM modules
logic [3:0] START_R, START_G,START_B, HEART_R0, HEART_G0, HEART_B0, HEART_R1, HEART_G1, HEART_B1, HEART_R2, HEART_G2, HEART_B2;
fruitninja_example fne( .DrawX(drawxsig), .DrawY(drawysig), .vga_clk(VGA_Clk), .blank(blank), .red(BKG_R), .green(BKG_G), .blue(BKG_B));
ogfruitninja_example starttext( .DrawX(drawxsig), .DrawY(drawysig), .vga_clk(VGA_Clk), .blank(blank), .red(START_R), .green(START_G), .blue(START_B));
heart_example heart1( .DrawX(drawxsig - 108), .DrawY(drawysig - 157), .vga_clk(VGA_Clk), .blank(blank), .red(HEART_R0), .green(HEART_G0), .blue(HEART_B0));
heart_example heart2( .DrawX(drawxsig - 183), .DrawY(drawysig - 154), .vga_clk(VGA_Clk), .blank(blank), .red(HEART_R1), .green(HEART_G1), .blue(HEART_B1));
heart_example heart3( .DrawX(drawxsig - 258), .DrawY(drawysig - 151), .vga_clk(VGA_Clk), .blank(blank), .red(HEART_R2), .green(HEART_G2), .blue(HEART_B2));
logic[3:0] OVER_R, OVER_G, OVER_B, WATER_R, WATER_G, WATER_B, FONT_R, FONT_G, FONT_B;
over_example over0( .DrawX(drawxsig + 218), .DrawY(drawysig), .vga_clk(VGA_Clk), .blank(blank), .red(OVER_R), .green(OVER_G), .blue(OVER_B));
watermelon_example ( .DrawX(drawxsig + 84), .DrawY(drawysig + 156), .vga_clk(VGA_Clk), .blank(blank), .red(WATER_R), .green(WATER_G), .blue(WATER_B));
font_example( .DrawX(drawxsig), .DrawY(drawysig), .vga_clk(VGA_Clk), .blank(blank), .red(FONT_R), .green(FONT_G), .blue(FONT_B));

// Registers
reg_1 start_sliced(.Clk(VGA_Clk), .Reset(Reset_h), .Load(1'b1), .D(startsliced), .Data_Out(startslice));
reg_1 f0_sliced(.Clk(VGA_Clk), .Reset(resetf0), .Load(1'b1), .D(sliced0), .Data_Out(slice0));
reg_1 f1_sliced(.Clk(VGA_Clk), .Reset(resetf1), .Load(1'b1), .D(sliced1), .Data_Out(slice1));
reg_1 f2_sliced(.Clk(VGA_Clk), .Reset(resetf2), .Load(1'b1), .D(sliced2), .Data_Out(slice2));

// FSM Registers
reg_start startstate(.Clk(VGA_Clk), .Reset(Reset_h), .Load(startsliced), .D(1'b0), .Data_Out(start_screen));
reg_1 throwfruitstate(.Clk(VGA_Clk), .Reset(Reset_h || lives == 3'b000), .Load(~start_screen && lives != 3'b000), .D(1'b1), .Data_Out(throw_fruit));
reg_1 endgamestate(.Clk(VGA_Clk), .Reset(Reset_h), .Load(~throw_fruit && ~start_screen), .D(1'b1), .Data_Out(end_game));

// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
//assign lives = 3'b011;
logic end_game, newlives, restart_game;
reg_3 l1(.Clk(VGA_Clk), .Reset(Reset_h), .Load(newlives == 3'b000), .D(newlives), .Data_Out(lives));  // newlives = 3'b000, Reset_h
/*
reg_1 l1(.Clk(VGA_Clk), .Reset(~throw_fruit), .Load(1'b1), .D(), .Data_Out(newlife1));
reg_1 l2(.Clk(VGA_Clk), .Reset(~throw_fruit), .Load(1'b1), .D(), .Data_Out(newlife2));
reg_1 l3(.Clk(VGA_Clk), .Reset(~throw_fruit), .Load(1'b1), .D(), .Data_Out(newlife3));
assign lives = {newlife3, newlife2 , newlife1}
*/
logic [9:0] total, newscore;
reg_10 score(.Clk(Clk), .Reset(start_screen && ~throw_fruit), .Load(1'b1), .D(newscore), .Data_Out(total));
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------


// Balls Logic
logic [9:0] fruit0xsig, fruit0ysig, fruit0sizesig;
logic [9:0] fruit1xsig, fruit1ysig, fruit1sizesig;
logic [9:0] fruit2xsig, fruit2ysig, fruit2sizesig;
logic [9:0] fruit3xsig, fruit3ysig, fruit3sizesig;
logic [9:0] startxsig, startysig, startsizesig;
start_fruit sf(.Reset(Reset_h), .frame_clk(VGA_VS), .BallX(startxsig), .BallY(startysig), .BallS(startsizesig));
fruit f0(.Reset(resetf0 && throw_fruit || start_screen), .frame_clk(VGA_VS),.xStart(10'd140), .increment(10'd7), .xincrement(10'd1), .negate(1'b0), .fruitX(fruit0xsig), .fruitY(fruit0ysig), .fruitS(fruit0sizesig), .offstage(offstage0));
fruit f1(.Reset(resetf1 && throw_fruit || start_screen), .frame_clk(VGA_VS),.xStart(10'd240), .increment(10'd6), .xincrement(10'd1), .negate(1'b1),.fruitX(fruit1xsig), .fruitY(fruit1ysig), .fruitS(fruit1sizesig), .offstage(offstage1));
fruit f2(.Reset(resetf2 && throw_fruit || start_screen), .frame_clk(VGA_VS),.xStart(10'd500), .increment(10'd9), .xincrement(10'd2), .negate(1'b1),.fruitX(fruit2xsig), .fruitY(fruit2ysig), .fruitS(fruit2sizesig), .offstage(offstage2));
//fruit f3(.Reset(resetf3), .frame_clk(VGA_VS),.xStart(10'd465), .increment(10'd2), .fruitX(fruit3xsig), .fruitY(fruit3ysig), .fruitS(fruit3sizesig).offstage(offstage3));
//fruit f4(.Reset(resetf4), .frame_clk(VGA_VS),.xStart(10'd85), .increment(10'd4), .fruitX(fruit4xsig), .fruitY(fruit4ysig), .fruitS(fruit4sizesig).offstage(offstage4));



endmodule
