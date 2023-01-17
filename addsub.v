module addsub
(
	input	[7:0]	dataa,
	input	[7:0]	datab,
	input			add_sub,	  // if this is 1, add; else subtract
	output	[8:0]	result
);

	assign result = (add_sub == 1) ? dataa + datab :
					dataa - datab;
endmodule
