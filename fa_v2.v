module fa_v2(a, b, ci, s); 
	input	a, b, ci;	// 1 bit input a, b, ci
	output	s;			// 1 bit output y
	wire	w0;				// 1 bit inne rwire w0
	
	_xor2 U0_xor2(.a(a), .b(b), .y(w0));
	_xor2 U1_xor2(.a(w0), .b(ci), .y(s));
	
	// This code is similar to fa.v,
	// there's no Carry out.
endmodule
