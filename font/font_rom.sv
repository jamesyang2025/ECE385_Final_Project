module font_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:24999] /* synthesis ram_init_file = "./font/font.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
