module  start_fruit ( input Reset, frame_clk,
               output [9:0]  BallX, BallY, BallS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=0;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=0;      // Step size on the Y axis

    assign Ball_Size = 100;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
      Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
		Ball_X_Motion <= 10'd0; //Ball_X_Step;
		Ball_Y_Pos <= Ball_Y_Center;
		Ball_X_Pos <= Ball_X_Center;	
	end	
	assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;

endmodule
