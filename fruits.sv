module  fruit ( input Reset, frame_clk,
					//input [7:0] keycode,
					input [9:0] xStart, 
					input [10:0] increment,
					input [10:0] xincrement,
					input negate,
					output offstage,
               output [9:0]  fruitX, fruitY, fruitS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    //parameter [9:0] Ball_X_Center=160;  // Center position on the X axis: 320   NOT NEEDED
    parameter [9:0] Ball_Y_Center=500;  // Center position on the Y axis: 240
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=80;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=600;     // Bottommost point on the Y axis: 479 --------------- MAX FRUIT HEIGHT
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    //parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis: 1
	//logic [9:0] Ball_Y_Step = increment;
    assign Ball_Size = 15;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= (~ (increment) + 1'b1); //Ball_Y_Step: 10'd1;
				if(negate == 1'b1)
					Ball_X_Motion <= (~ (xincrement) + 1'b1); //Ball_X_Step;
				else
					Ball_X_Motion <= xincrement;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= xStart;//Ball_X_Center
				offstage <= 1'b0;
        end
           
        else 
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					begin
					  Ball_Y_Motion <= (~ (increment) + 1'b1);  // 2's complement.
					  Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);
						Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
					end
				 else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
				 begin
					  Ball_Y_Motion <= increment;
					  Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);
						Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
					end
				 else 
				 begin
						Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
						Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);
						Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				end
				if(Ball_Y_Pos > 560)
					offstage <= 1'b1;
				else
					offstage <= 1'b0;
			end
		end
	 assign fruitX = Ball_X_Pos;
    assign fruitY = Ball_Y_Pos;
    assign fruitS = Ball_Size;
endmodule
