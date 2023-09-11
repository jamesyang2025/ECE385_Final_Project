module over_rom (
	input logic clock,
	input logic [15:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:59999] /* synthesis ram_init_file = "./over/over.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
