module cla4(a, b, ci, s, co);
	input	[3:0]	a, b;
	input			ci;
	output	[3:0]	s;
	output			co;
	
	wire	[3:0]	c;
	
	// 4-bit CLA
	// Output: 4-bit S
	fa_v2 U0_fa (.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]));
	fa_v2 U1_fa	(.a(a[1]), .b(b[1]), .ci(c[0]), .s(s[1]));
	fa_v2 U2_fa	(.a(a[2]), .b(b[2]), .ci(c[1]), .s(s[2]));
	fa_v2 U3_fa	(.a(a[3]), .b(b[3]), .ci(c[2]), .s(s[3]));
	
	// Calculate each Carry value with using clb4 module
	clb4 	U4_clb4 	(.a(a), .b(b), .ci(ci), .c1(c[0]), .c2(c[1]), .c3(c[2]), .co(co));
endmodule

module cla8(a, b, ci, s, co);
	input	[7:0]	a, b; // 8 bit inputs
	input 			ci;	// 1 bit carry in
	output	[7:0]	s;		// 8 bit output sum
	output			co; 	// 1 bit output carry out
	
	wire			c1;
	
	// 8 Bit CLA implementation using 4-bit CLA
	cla4 U0_cla4(.a(a[3:0]), .b(b[3:0]), .ci(ci), .s(s[3:0]), .co(c1));
	cla4 U1_cla4(.a(a[7:4]), .b(b[7:4]), .ci(c1), .s(s[7:4]), .co(co));
endmodule

module cla16(a, b, ci, s, co);
	input	[15:0]	a, b;
	input			ci;
	output	[15:0]	s;
	output			co;
	
	wire			c1, c2;
	
	// 16 Bit CLA implementation using 8-bit CLA
	cla8 U0_cla8(.a(a[7:0]), .b(b[7:0]), .ci(ci), .s(s[7:0]), .co(c1));
	cla8 U1_cla8(.a(a[15:8]), .b(b[15:8]), .ci(c1), .s(s[15:8]), .co(co));
endmodule

module cla16_8(a, b, c, d, e, f, g, h, ci, s, co);
    input	[15:0]	a, b, c, d, e, f, g, h;
    input			ci;
    output	[15:0]	s;
    output			co;
    
    wire	        c1, c2, c3, c4, c5, c6, c7;
    wire    [15:0]  s1, s2, s3, s4, s5, s6, s7;

	// 16 Bit CLA implementation using 16-bit CLAs
	cla16 U0_cla16(.a(a), .b(b), .ci(ci), .s(s1), .co(c1));
	cla16 U1_cla16(.a(c), .b(d), .ci(c1), .s(s2), .co(c2));
	cla16 U2_cla16(.a(e), .b(f), .ci(c2), .s(s3), .co(c3));
	cla16 U3_cla16(.a(g), .b(h), .ci(c3), .s(s4), .co(c4));

	cla16 U4_cla16(.a(s1), .b(s2), .ci(c4), .s(s5), .co(c5));
	cla16 U5_cla16(.a(s3), .b(s4), .ci(c5), .s(s6), .co(c6));
	
	cla16 U6_cla16(.a(s5), .b(s6), .ci(c6), .s(s7), .co(c7));

	cla16 U7_cla16(.a(s7), .b(16'b0), .ci(c7), .s(s), .co(co));

endmodule
