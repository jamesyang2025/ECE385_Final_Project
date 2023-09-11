//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
								input logic         Clk, Reset,  //
								//input vga_clk,blank,
								input logic [7:0] BKG_R, BKG_G, BKG_B, //
								input logic [9:0] startX, startY, startS, // not neededd
								input logic start_screen, throw_fruit, end_screen, //
								input logic offstage0, offstage1, offstage2, //
								input logic [7:0] START_R, START_G, START_B, //
								input logic [9:0] f0X, f0Y, f0S, f1X, f1Y, f1S, f2X, f2Y, f2S,  // fruits 0, 1, 2
								input logic [7:0] HEART_R0, HEART_G0, HEART_B0, HEART_R1, HEART_G1, HEART_B1, HEART_R2, HEART_G2, HEART_B2, OVER_R, OVER_G, OVER_B, WATER_R, WATER_G, WATER_B, //
								
								input logic slice0, slice1, slice2, startslice, //
								input logic [2:0] lives, // 
								output logic [2:0] newlives,
								
								input logic [9:0] score,
									output logic [9:0] newscore,
								output logic sliced0, sliced1, sliced2, startsliced, 
								output logic resetf0, resetf1, resetf2,
								output logic start_cut, restart_game,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on, fruit_on0, fruit_on1, fruit_on2, start_on;
	 //logic [7:0] BKG_R, BKG_G, BKG_B;
	 
	 //fruitninja_example fne( .DrawX(drawxsig), .DrawY(drawysig), .vga_clk(vga_clk), .blank(blank), .red(BKG_R), .green(BKG_G), .blue(BKG_B));

 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Size;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 
	 int Distf0X, Distf0Y, Sizef0;
	 assign Distf0X = DrawX - f0X;
    assign Distf0Y = DrawY - f0Y;
    assign Sizef0 = f0S;
	 
	 int Distf1X, Distf1Y, Sizef1;
	 assign Distf1X = DrawX - f1X;
    assign Distf1Y = DrawY - f1Y;
    assign Sizef1 = f1S;
	 
	 int Distf2X, Distf2Y, Sizef2;
	 assign Distf2X = DrawX - f2X;
    assign Distf2Y = DrawY - f2Y;
    assign Sizef2 = f2S;
	 
	 int DistStartX, DistStartY, DistStartS;
	 assign DistStartX = DrawX - startX;
    assign DistStartY = DrawY - startY;
    assign DistStartS = startS;
	 
	 logic cut0, cut1, cut2;
	 always_comb
	 begin
			if(((slice0 == 1'b0 && sliced0 == 1'b1) || (slice1 == 1'b0 && sliced1 == 1'b1) || (slice2 == 1'b0 && sliced2 == 1'b1)) && throw_fruit == 1'b1)
				newscore = score + 1;
			else
				newscore = score;
		end
	 
	 
	 
    always_comb   // ------------------------------------------------ set fruit and mouse signals
    begin:Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
	always_comb
    begin
        if ( ( Distf0X*Distf0X + Distf0Y*Distf0Y) <= (Sizef0 * Sizef0) ) 
            fruit_on0 = 1'b1;
        else 
            fruit_on0 = 1'b0;
     end 
		always_comb
    begin
        if ( ( Distf1X*Distf1X + Distf1Y*Distf1Y) <= (Sizef1 * Sizef1) ) 
            fruit_on1 = 1'b1;
        else 
            fruit_on1 = 1'b0;
     end 
		always_comb
    begin
        if ( ( Distf2X*Distf2X + Distf2Y*Distf2Y) <= (Sizef2 * Sizef2) ) 
            fruit_on2 = 1'b1;
        else 
            fruit_on2 = 1'b0;
     end 
	  always_comb
    begin
        if ( ( DistStartX*DistStartX + DistStartY*DistStartY) <= (DistStartS * DistStartS) ) 
            start_on = 1'b1;
        else 
            start_on = 1'b0;
     end 
	always_comb    // ------------------------------------------------ check if fruit is cut
	begin
		if(fruit_on0 == 1'b1 && ball_on == 1'b1)
			cut0 = 1'b1;
		else
			cut0 = 1'b0;
		if(fruit_on1 == 1'b1 && ball_on == 1'b1)
			cut1 = 1'b1;
		else
			cut1 = 1'b0;
		if(fruit_on2 == 1'b1 && ball_on == 1'b1)
			cut2 = 1'b1;
		else
			cut2 = 1'b0;
	end
	
	//logic start_cut;  // --------------------------------------------- check if game starting fruit is cut
	always_comb
	begin
		if(ball_on == 1'b1 && DrawX > 270 && DrawX < 370 && DrawY > 190 && DrawY < 290)//start_on == 1'b1)
			start_cut = 1'b1;
		else
			start_cut = 1'b0;
	end
	
	always_comb  
	begin
		if(offstage0 == 1'b1)
			resetf0 = 1'b1;
		else
			resetf0 = 1'b0;
		if(offstage1 == 1'b1)
			resetf1 = 1'b1;
		else
			resetf1 = 1'b0;
		if(offstage2 == 1'b1)
			resetf2 = 1'b1;
		else
			resetf2 = 1'b0;
	end
	
	// ---------------------------------------------------------------------------------------------------- START DRAW LOGIC
    always_comb
    begin:RGB_Display
		if (start_screen == 1'b1 && ball_on == 1'b1 && start_cut == 1'b1)                 // ------------------------------------------------ start fruit is cut
        begin 
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = 1'b0;
				sliced1 = 1'b0;
				sliced2 = 1'b0;
				startsliced = 1'b1;
        end  
			else if (start_screen == 1'b1 && (ball_on == 1'b1))                 // ------------------------------------------------ mouse pixels
        begin 
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
        end   
			else if (start_screen == 1'b1 && (start_cut == 1'b1 || startslice == 1'b1))                 // ------------------------------------------------ start fruit is cut
        begin 
            Red = BKG_R;
				Green = BKG_G;
				Blue = BKG_B;
				sliced0 = 1'b0;
				sliced1 = 1'b0;
				sliced2 = 1'b0;
				startsliced = 1'b1;
        end  
        
		  
		  else if (start_screen == 1'b1 && DrawX > 220 && DrawX < 420 && DrawY > 140 && DrawY < 340)                 // ------------------------------------------------ start fruit
        begin 
            /*Red = 8'h00;
            Green = 8'h00;
            Blue = 8'hff;*/
				if((START_R == 8'h00 && START_G == 8'h00 && START_B == 4'hf) || (START_R == 4'hc && START_G == 4'h7 && START_B == 4'h7) || (START_R == 4'h1 && START_G == 8'h1 && START_B == 4'h9) || (START_R == 4'h3 && START_G == 4'h2 && START_B == 4'hd))
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
				end
				else
				begin
					Red = START_R;
					Green = START_G;
					Blue = START_B;
				end
				sliced0 = 1'b0;
				sliced1 = 1'b0;
				sliced2 = 1'b0;
				startsliced = startslice;
        end    
//---------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------
		  else if(throw_fruit == 1'b1)
		  begin
			if(ball_on == 1'b1 && cut0 == 1'b1)
			begin
				Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = 1'b1;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else if(ball_on == 1'b1 && cut1 == 1'b1)
			begin
				Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = slice0;
				sliced1 = 1'b1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			
			else if(ball_on == 1'b1 && cut2 == 1'b1)
			begin
				Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = 1'b1;
				startsliced = startslice;
			end
			else if (ball_on == 1'b1)                 // ------------------------------------------------ mouse pixels
			begin 
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else if (DrawX > 415 && DrawX < 465 && DrawY > 25 && DrawY < 75 && lives > 0)                 // ------------------------------------------------ first life  midpt: (430, 50)
			begin 
				if((HEART_R0 == 4'hf && HEART_G0 == 4'hf && HEART_B0 == 4'hf) || (HEART_R0 == 4'hc && HEART_G0 == 4'hc && HEART_B0 == 4'hc) || (HEART_R0 == 4'ha && HEART_G0 == 4'ha && HEART_B0 == 4'ha) || (HEART_R0 == 4'h8 && HEART_G0 == 4'h8 && HEART_B0 == 4'h8))
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
				end
				else
				begin
					Red = HEART_R0;
					Green = HEART_G0;
					Blue = HEART_B0;
				end
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else if (DrawX > 490 && DrawX < 540 && DrawY > 25 && DrawY < 75 && lives > 0)                 // ------------------------------------------------ second life  midpt: (515, 50)
			begin 
				if((HEART_R1 == 4'hf && HEART_G1 == 4'hf && HEART_B1 == 4'hf) || (HEART_R1 == 4'hc && HEART_G1 == 4'hc && HEART_B1 == 4'hc) || (HEART_R1 == 4'ha && HEART_G1 == 4'ha && HEART_B1 == 4'ha)|| (HEART_R1 == 4'h8 && HEART_G1 == 4'h8 && HEART_B1 == 4'h8))
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
				end
				else
				begin
					Red = HEART_R1;
					Green = HEART_G1;
					Blue = HEART_B1;
				end
            
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else if (DrawX > 565 && DrawX < 615 && DrawY > 25 && DrawY < 75 && lives > 0)                 // ------------------------------------------------ last life   midpt: (590, 50)
			begin 
				if((HEART_R2 == 4'hf && HEART_G2 == 4'hf && HEART_B2 == 4'hf) || (HEART_R2 == 4'hc && HEART_G2 == 4'hc && HEART_B2 == 4'hc) || (HEART_R2 == 4'ha && HEART_G2 == 4'ha && HEART_B2 == 4'ha) || (HEART_R2 == 4'h8 && HEART_G2 == 4'h8 && HEART_B2 == 4'h8))
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
				end
				else
				begin
					Red = HEART_R2;
					Green = HEART_G2;
					Blue = HEART_B2;
				end
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end

			else if(offstage0 == 1'b1)
			begin
				Red = 8'hff;
				Green = 8'h6f;
				Blue = 8'h6f;
				sliced0 = 1'b0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
	//------------------------------------------------------------------------------		
			else if((cut0 == 1'b1 || slice0 == 1'b1) && (cut1 == 1'b0 && slice1 == 1'b0) && (cut2 == 1'b0 && slice2 == 1'b0))    // only fruit 0
			begin 
				if((fruit_on1 == 1'b1)) // ------------------------------------------------ fruit 1 pixels
				begin
					Red = 8'h0;
					Green = 8'hff;
					Blue = 8'hff;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else if((fruit_on2 == 1'b1)) // ------------------------------------------------ fruit 2 pixels
				begin
					Red = 8'h94;
					Green = 8'h3e;
					Blue = 8'ha2;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else
				begin
					if(resetf0 == 1'b1)
					begin
						Red = 8'hff;
						Green = 8'h6f;
						Blue = 8'h6f;
						sliced0 = 1'b0;
						sliced1 = slice1;
						sliced2 = slice2;
						startsliced = startslice;
					end
					else
					begin
						Red = BKG_R;
						Green = BKG_G;
						Blue = BKG_B;
						sliced0 = 1'b1;
						sliced1 = slice1;
						sliced2 = slice2;
						startsliced = startslice;
					end
				end
			end
			else if((cut1 == 1'b1 || slice1 == 1'b1) && (cut2 == 1'b0 && slice2 == 1'b0) && (cut0 == 1'b0 && slice0 == 1'b0))    // only fruit 1
			begin
				if((fruit_on0 == 1'b1)) //&& throw_fruit == 1'b1) // ------------------------------------------------ fruit 0 pixels
				begin
					Red = 8'hff;
					Green = 8'h6f;
					Blue = 8'h6f;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else if((fruit_on2 == 1'b1)) // ------------------------------------------------ fruit 2 pixels
				begin
					Red = 8'h94;
					Green = 8'h3e;
					Blue = 8'ha2;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
					sliced0 = slice0;
					sliced1 = 1'b1;
					sliced2 = slice2;
					startsliced = startslice;
				end
			end
			else if((cut2 == 1'b1 || slice2 == 1'b1) && (cut1 == 1'b0 && slice1 == 1'b0) && (cut0 == 1'b0 && slice0 == 1'b0))    // only fruit 2
			begin
				if((fruit_on0 == 1'b1)) //&& throw_fruit == 1'b1) // ------------------------------------------------ fruit 0 pixels
				begin
					Red = 8'hff;
					Green = 8'h6f;
					Blue = 8'h6f;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else if((fruit_on1 == 1'b1)) // ------------------------------------------------ fruit 1 pixels
				begin
					Red = 8'h0;
					Green = 8'hff;
					Blue = 8'hff;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = 1'b1;
					startsliced = startslice;
				end
			end
			else if((cut0 == 1'b1 || slice0 == 1'b1) && (cut1 == 1'b1 || slice1 == 1'b1) && (cut2 == 1'b0 && slice2 == 1'b0))    // only fruit 0 + fruit 1
			begin 
				if((fruit_on2 == 1'b1)) // ------------------------------------------------ fruit 2 pixels
				begin
					Red = 8'h94;
					Green = 8'h3e;
					Blue = 8'ha2;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
					sliced0 = 1'b1;
					sliced1 = 1'b1;
					sliced2 = slice2;
					startsliced = startslice;
				end
			end
			else if((cut0 == 1'b1 || slice0 == 1'b1) && (cut1 == 1'b0 && slice1 == 1'b0) && (cut2 == 1'b1 || slice2 == 1'b1))    // only fruit 0 + 2
			begin
				if((fruit_on1 == 1'b1)) // ------------------------------------------------ fruit 1 pixels
				begin
					Red = 8'h0;
					Green = 8'hff;
					Blue = 8'hff;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
					sliced0 = 1'b1;
					sliced1 = slice1;
					sliced2 = 1'b1;
					startsliced = startslice;
				end
			end
			else if((cut1 == 1'b1 || slice1 == 1'b1) && (cut0 == 1'b0 && slice0 == 1'b0) && (cut2 == 1'b1 || slice2 == 1'b1))    // only fruit 1 + 2
			begin
				if((fruit_on0 == 1'b1)) //&& throw_fruit == 1'b1) // ------------------------------------------------ fruit 0 pixels
				begin
					Red = 8'hff;
					Green = 8'h6f;
					Blue = 8'h6f;
					sliced0 = slice0;
					sliced1 = slice1;
					sliced2 = slice2;
					startsliced = startslice;// dont care
				end
				else
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
					sliced0 = slice0;
					sliced1 = 1'b1;
					sliced2 = 1'b1;
					startsliced = startslice;
				end
			end
			else if((cut1 == 1'b1 || slice1 == 1'b1) && (cut0 == 1'b1 || slice0 == 1'b1) && (cut2 == 1'b1 || slice2 == 1'b1))    // only fruit 0 + 1 + 2
			begin 
				Red = BKG_R;
				Green = BKG_G;
				Blue = BKG_B;
				sliced0 = 1'b1;
				sliced1 = 1'b1;
				sliced2 = 1'b1;
				startsliced = startslice;
			end
			  
			else if((fruit_on0 == 1'b1)) //&& throw_fruit == 1'b1) // ------------------------------------------------ fruit 0 pixels
			begin
				Red = 8'hff;
				Green = 8'h6f;
				Blue = 8'h6f;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;// dont care
			end
			else if((fruit_on1 == 1'b1)) // ------------------------------------------------ fruit 1 pixels
			begin
				Red = 8'h0;
				Green = 8'hff;
				Blue = 8'hff;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;// dont care
			end
			else if((fruit_on2 == 1'b1)) // ------------------------------------------------ fruit 2 pixels
			begin
				Red = 8'h94;
				Green = 8'h3e;
				Blue = 8'ha2;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;// dont care
			end
			else 
			begin                         // ------------------------------------------------ BACKGROUND
				Red = BKG_R;
				Green = BKG_G;
				Blue = BKG_B;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;  
			end
		  end
	// ----------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------
		else if(lives == 3'b000 && start_screen == 1'b0)
		begin	
			if(ball_on == 1'b1)                
			begin 
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else if(DrawX > 120 && DrawX < 520 && DrawY > 165 && DrawY < 315)
			begin
				if(OVER_R == 4'h0)
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
				end
				else
				begin
					Red = OVER_R;
					Green = OVER_G;
					Blue = OVER_B;
				end
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else if(DrawX > 490 && DrawX < 540 && DrawY > 405 && DrawY < 455)
			begin
				if(WATER_R == 4'h0)
				begin
					Red = BKG_R;
					Green = BKG_G;
					Blue = BKG_B;
				end
				else
				begin
					Red = WATER_R;
					Green = WATER_G;
					Blue = WATER_B;
				end
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;
			end
			else
			begin
				Red = BKG_R;
				Green = BKG_G;
				Blue = BKG_B;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice; 
			end
		end
//--------------------------------------------------------------------------------------------------
        else 
        begin                         // ------------------------------------------------ BACKGROUND
				Red = BKG_R;
				Green = BKG_G;
				Blue = BKG_B;
				sliced0 = slice0;
				sliced1 = slice1;
				sliced2 = slice2;
				startsliced = startslice;  
        end
		  
		 
		 if(start_screen != 1'b1 && (BallX < 0 || BallX > 640 || BallY < 0 || BallY > 480))
		  newlives = 3'b000;
		 else
		  newlives = 3'b111;
		  
		
		/*if(resetf0 == 1'b1 && sliced1 == 1'b0)
			newlives = 3'b000;
		else
			newlives = lives;
		*/
		  
		  
		 if(BallX > 490 && BallX < 540 && BallY > 405 && BallY < 455 && lives == 3'b000 && start_screen == 1'b0)
		  restart_game = 1'b1;
		 else
			restart_game = 1'b0;
		  
		  
		  
		  /*if(DrawX > 490 && DrawX < 540 && DrawY > 405 && DrawY < 455 && ball_on == 1'b1 && lives == 3'b000 && start_screen == 1'b0)
			restart_game = 1'b0;
			else
				restart_game = 1'b0;
			*/
		 /*if(((sliced0 == 1'b1 && resetf0) || (sliced1 == 1'b0 && resetf1 == 1'b1) || (sliced2 == 1'b0 && resetf2 == 1'b1)) &&  throw_fruit == 1'b1)
			newlives = 3'b000;
		 else
			newlives = 3'b011;
			*/
    end 
endmodule
