module FSM(  input logic         Clk, Reset,
				input logic 	start_cut,
				input [2:0] lives, 
				output logic start_screen, throw_fruit, end_screen
);
enum logic [2:0]{ Halted, game_start, game_over} State, Next_state;
always_ff @ (posedge Clk)
begin
	if (Reset)
		State <= Halted;
	else
		State <= Next_state;
end
always_comb
begin
	Next_state = State;
	
	unique case(State)
		Halted : 
			if (start_cut)
				Next_state = game_start;
		game_start :
			if(lives == 2'b0)
				Next_state = game_over;
		game_over :
			Next_state = Halted;
		endcase
	
	case(State)
	Halted:
		begin
			start_screen = 1'b1;
			end_screen = 1'b0;
			throw_fruit = 1'b0;
		end
	game_start:
		begin
			start_screen = 1'b0;
			end_screen = 1'b0;
			throw_fruit = 1'b1;
		end
	game_over:
		begin
			start_screen = 1'b0;
			end_screen = 1'b1;
			throw_fruit = 1'b0;
		end
	endcase
end
endmodule
