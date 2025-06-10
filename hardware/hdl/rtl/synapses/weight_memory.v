//-----------------------------------------------------------------------------
// Title         : Weight Memory with Configurable Storage
// Project       : PYNQ-Z2 SNN Accelerator
// File          : weight_memory.v
// Author        : Jiwoon Lee (@metr0jw)
// Organization  : Kwangwoon University, Seoul, South Korea
// Description   : Parameterized weight storage using BRAM or distributed RAM
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module weight_memory #(
    parameter NUM_WEIGHTS   = 4096,    // Total number of weights
    parameter WEIGHT_WIDTH  = 9,       // Bits per weight (8 + sign)
    parameter ADDR_WIDTH    = $clog2(NUM_WEIGHTS),
    parameter USE_BRAM      = 1,       // 1: BRAM, 0: Distributed RAM
    parameter INIT_FILE     = ""       // Memory initialization file
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Read port
    input  wire                     read_en,
    input  wire [ADDR_WIDTH-1:0]    read_addr,
    output reg  [WEIGHT_WIDTH-1:0]  read_data,
    output reg                      read_valid,
    
    // Write port
    input  wire                     write_en,
    input  wire [ADDR_WIDTH-1:0]    write_addr,
    input  wire [WEIGHT_WIDTH-1:0]  write_data,
    
    // Status
    output wire                     mem_busy
);

    // Memory array
    generate
        if (USE_BRAM) begin : bram_storage
            // Use Xilinx Block RAM primitive for PYNQ-Z2
            (* ram_style = "block" *)
            reg [WEIGHT_WIDTH-1:0] bram_array [0:NUM_WEIGHTS-1];
            
            // Initialize memory if file provided
            initial begin
                if (INIT_FILE != "") begin
                    $readmemh(INIT_FILE, bram_array);
                end else begin
                    integer i;
                    for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
                        bram_array[i] = 0;
                    end
                end
            end
            
            // Read port - 1 cycle latency
            always @(posedge clk) begin
                if (!rst_n) begin
                    read_data <= 0;
                    read_valid <= 1'b0;
                end else begin
                    if (read_en) begin
                        read_data <= bram_array[read_addr];
                        read_valid <= 1'b1;
                    end else begin
                        read_valid <= 1'b0;
                    end
                end
            end
            
            // Write port
            always @(posedge clk) begin
                if (write_en) begin
                    bram_array[write_addr] <= write_data;
                end
            end
            
        end else begin : distributed_storage
            // Use distributed RAM for smaller arrays
            (* ram_style = "distributed" *)
            reg [WEIGHT_WIDTH-1:0] dist_ram_array [0:NUM_WEIGHTS-1];
            
            // Initialize memory
            initial begin
                if (INIT_FILE != "") begin
                    $readmemh(INIT_FILE, dist_ram_array);
                end else begin
                    integer i;
                    for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
                        dist_ram_array[i] = 0;
                    end
                end
            end
            
            // Read port - combinational for distributed RAM
            always @(posedge clk) begin
                if (!rst_n) begin
                    read_data <= 0;
                    read_valid <= 1'b0;
                end else begin
                    if (read_en) begin
                        read_data <= dist_ram_array[read_addr];
                        read_valid <= 1'b1;
                    end else begin
                        read_valid <= 1'b0;
                    end
                end
            end
            
            // Write port
            always @(posedge clk) begin
                if (write_en) begin
                    dist_ram_array[write_addr] <= write_data;
                end
            end
        end
    endgenerate
    
    // Memory busy signal (for potential multi-cycle operations)
    assign mem_busy = 1'b0;  // Single-cycle operation
    
    // Optional: Add memory statistics
    reg [31:0] write_count;
    reg [31:0] read_count;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            write_count <= 32'd0;
            read_count <= 32'd0;
        end else begin
            if (write_en) write_count <= write_count + 1'b1;
            if (read_en) read_count <= read_count + 1'b1;
        end
    end

endmodule
