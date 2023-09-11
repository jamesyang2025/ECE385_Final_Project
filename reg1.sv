module reg_3 ( input						Clk, Reset, Load,
					input	[2:0]				D,
					output logic [2:0]			Data_Out);
					//output logic 					end_game);
					
		always_ff @ (posedge Clk or posedge Reset)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					begin
						Data_Out <= 3'b111;
						//end_game <= 1'b0;
					end
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
				begin
					Data_Out <= 3'b000;
					//if(D == 3'b000)
						//end_game <= 1'b1;
				end
		end
		
endmodule

module reg_1 ( input						Clk, Reset, Load,
					input				D,
					output logic			Data_Out);
					
		always_ff @ (posedge Clk or posedge Reset)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 1'b0;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data_Out <= D;
		end
		
endmodule

module reg_life ( input						Clk, Reset, Load,
					input				D,
					output logic			Data_Out);
					
		always_ff @ (posedge Clk or posedge Reset)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 1'b1;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data_Out <= 1'b0;
		end
		
endmodule




module reg_10 ( input						Clk, Reset, Load,
					input	[9:0]			D,
					output logic			[9:0] Data_Out);
					
		always_ff @ (posedge Clk or posedge Reset)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 10'h0;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data_Out <= D;
		end
		
endmodule




module reg_start ( input						Clk, Reset, Load,
					input				D,
					output logic			Data_Out);
					
		always_ff @ (posedge Clk or posedge Reset)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 1'b1;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load == 1'b1)
					Data_Out <= 1'b0;
		end
		
endmodule
