module bit_extender_1to8(x, y);
    input           x;	// 1 bit input x
    output  [7:0]   y;	// 8 bit output y
    
    assign y = {7{x}};
endmodule

module bit_extender_1to8_2(x1, x2, y1, y2);
    input           x1, x2;	// 1 bit input x1, x2
    output  [7:0]   y1, y2;	// 8 bit output y1, y2
    
    bit_extender_1to8 U0_bit_extender_1to8(.x(x1), .y(y1));
    bit_extender_1to8 U1_bit_extender_1to8(.x(x2), .y(y2));
endmodule

module bit_extender_1to8_4(
    x1, x2, x3, x4,
    y1, y2, y3, y4
    );
    input           x1, x2, x3, x4;	// 1 bit input x1, x2, x3, x4
    output  [7:0]   y1, y2, y3, y4;	// 8 bit output y1, y2, y3, y4
    
    bit_extender_1to8_2 U0_bit_extender_1to8_2(.x1(x1), .x2(x2), .y1(y1), .y2(y2));
    bit_extender_1to8_2 U1_bit_extender_1to8_2(.x1(x3), .x2(x4), .y1(y3), .y2(y4));
endmodule

module bit_extender_1to8_8(
    x1, x2, x3, x4, x5, x6, x7, x8,
    y1, y2, y3, y4, y5, y6, y7, y8
    );
    input           x1, x2, x3, x4, x5, x6, x7, x8;	// 1 bit input x1, x2, x3, x4, x5, x6, x7, x8
    output  [7:0]   y1, y2, y3, y4, y5, y6, y7, y8;	// 8 bit output y1, y2, y3, y4, y5, y6, y7, y8
    
    bit_extender_1to8_4 U0_bit_extender_1to8_4(.x1(x1), .x2(x2), .x3(x3), .x4(x4), .y1(y1), .y2(y2), .y3(y3), .y4(y4));
    bit_extender_1to8_4 U1_bit_extender_1to8_4(.x1(x5), .x2(x6), .x3(x7), .x4(x8), .y1(y5), .y2(y6), .y3(y7), .y4(y8));
endmodule

module bit_extender_1to8_16(
    x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16,
    y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16
    );
    input           x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16;	// 1 bit input x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16
    output  [7:0]   y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16;	// 8 bit output y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16
    
    bit_extender_1to8_8 U0_bit_extender_1to8_8(.x1(x1), .x2(x2), .x3(x3), .x4(x4), .x5(x5), .x6(x6), .x7(x7), .x8(x8), .y1(y1), .y2(y2), .y3(y3), .y4(y4), .y5(y5), .y6(y6), .y7(y7), .y8(y8));
    bit_extender_1to8_8 U1_bit_extender_1to8_8(.x1(x9), .x2(x10), .x3(x11), .x4(x12), .x5(x13), .x6(x14), .x7(x15), .x8(x16), .y1(y9), .y2(y10), .y3(y11), .y4(y12), .y5(y13), .y6(y14), .y7(y15), .y8(y16));
endmodule

module bit_extender_1to8_32(
    x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32,
    y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16, y17, y18, y19, y20, y21, y22, y23, y24, y25, y26, y27, y28, y29, y30, y31, y32
    );
    input           x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32;	// 1 bit input x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32
    output  [7:0]   y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16, y17, y18, y19, y20, y21, y22, y23, y24, y25, y26, y27, y28, y29, y30, y31, y32;

    bit_extender_1to8_16 U0_bit_extender_1to8_16(.x1(x1), .x2(x2), .x3(x3), .x4(x4), .x5(x5), .x6(x6), .x7(x7), .x8(x8), .x9(x9), .x10(x10), .x11(x11), .x12(x12), .x13(x13), .x14(x14), .x15(x15), .x16(x16), .y1(y1), .y2(y2), .y3(y3), .y4(y4), .y5(y5), .y6(y6), .y7(y7), .y8(y8), .y9(y9), .y10(y10), .y11(y11), .y12(y12), .y13(y13), .y14(y14), .y15(y15), .y16(y16));
    bit_extender_1to8_16 U1_bit_extender_1to8_16(.x1(x17), .x2(x18), .x3(x19), .x4(x20), .x5(x21), .x6(x22), .x7(x23), .x8(x24), .x9(x25), .x10(x26), .x11(x27), .x12(x28), .x13(x29), .x14(x30), .x15(x31), .x16(x32), .y1(y17), .y2(y18), .y3(y19), .y4(y20), .y5(y21), .y6(y22), .y7(y23), .y8(y24), .y9(y25), .y10(y26), .y11(y27), .y12(y28), .y13(y29), .y14(y30), .y15(y31), .y16(y32));
endmodule

module bit_extender_1_to_8_64(
    x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31,
    x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59, x60, x61, x62, x63, x64,
    y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16, y17, y18, y19, y20, y21, y22, y23, y24, y25, y26, y27, y28, y29, y30, y31,
    y32, y33, y34, y35, y36, y37, y38, y39, y40, y41, y42, y43, y44, y45, y46, y47, y48, y49, y50, y51, y52, y53, y54, y55, y56, y57, y58, y59, y60, y61, y62, y63, y64
    );
    input           x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31,
                    x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59, x60, x61, x62, x63, x64;	// 1 bit input x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59, x60, x61, x62, x63, x64
    output  [7:0]   y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16, y17, y18, y19, y20, y21, y22, y23, y24, y25, y26, y27, y28, y29, y30, y31,
                    y32, y33, y34, y35, y36, y37, y38, y39, y40, y41, y42, y43, y44, y45, y46, y47, y48, y49, y50, y51, y52, y53, y54, y55, y56, y57, y58, y59, y60, y61, y62, y63, y64;	// 8 bit output y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16, y17, y18, y19, y20, y21, y22, y23, y24, y25, y26, y27, y28, y29, y30, y31, y32, y33, y34, y35, y36, y37, y38, y39, y40, y41, y42, y43, y44, y45, y46, y47, y48, y49, y50, y51, y52, y53, y54, y55, y56, y57, y58, y59, y60, y61, y62, y63, y64

    bit_extender_1to8_32 U1_bit_extender_1to8_32(.x1(x1), .x2(x2), .x3(x3), .x4(x4), .x5(x5), .x6(x6), .x7(x7), .x8(x8), .x9(x9), .x10(x10), .x11(x11), .x12(x12), .x13(x13), .x14(x14), .x15(x15), .x16(x16), .x17(x17), .x18(x18), .x19(x19), .x20(x20), .x21(x21), .x22(x22), .x23(x23), .x24(x24), .x25(x25), .x26(x26), .x27(x27), .x28(x28), .x29(x29), .x30(x30), .x31(x31), .x32(x32), .y1(y1), .y2(y2), .y3(y3), .y4(y4), .y5(y5), .y6(y6), .y7(y7), .y8(y8), .y9(y9), .y10(y10), .y11(y11), .y12(y12), .y13(y13), .y14(y14), .y15(y15), .y16(y16), .y17(y17), .y18(y18), .y19(y19), .y20(y20), .y21(y21), .y22(y22), .y23(y23), .y24(y24), .y25(y25), .y26(y26), .y27(y27), .y28(y28), .y29(y29), .y30(y30), .y31(y31), .y32(y32));
    bit_extender_1to8_32 U2_bit_extender_1to8_32(.x1(x33), .x2(x34), .x3(x35), .x4(x36), .x5(x37), .x6(x38), .x7(x39), .x8(x40), .x9(x41), .x10(x42), .x11(x43), .x12(x44), .x13(x45), .x14(x46), .x15(x47), .x16(x48), .x17(x49), .x18(x50), .x19(x51), .x20(x52), .x21(x53), .x22(x54), .x23(x55), .x24(x56), .x25(x57), .x26(x58), .x27(x59), .x28(x60), .x29(x61), .x30(x62), .x31(x63), .x32(x64), .y1(y33), .y2(y34), .y3(y35), .y4(y36), .y5(y37), .y6(y38), .y7(y39), .y8(y40), .y9(y41), .y10(y42), .y11(y43), .y12(y44), .y13(y45), .y14(y46), .y15(y47), .y16(y48), .y17(y49), .y18(y50), .y19(y51), .y20(y52), .y21(y53), .y22(y54), .y23(y55), .y24(y56), .y25(y57), .y26(y58), .y27(y59), .y28(y60), .y29(y61), .y30(y62), .y31(y63), .y32(y64));
endmodule
