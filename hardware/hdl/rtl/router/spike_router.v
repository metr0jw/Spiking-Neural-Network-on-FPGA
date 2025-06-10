//-----------------------------------------------------------------------------
// Title         : Spike Router Module
// Project       : PYNQ-Z2 SNN Accelerator
// File          : spike_router.v
// Author        : Jiwoon Lee (@metr0jw)
// Organization  : Kwangwoon University, Seoul, South Korea
// Description   : Routes spikes between neurons with configurable connectivity
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module spike_router #(
    parameter NUM_NEURONS       = 64,
    parameter MAX_FANOUT        = 32,      // Max connections per neuron
    parameter WEIGHT_WIDTH      = 8,
    parameter NEURON_ID_WIDTH   = $clog2(NUM_NEURONS),
    parameter DELAY_WIDTH       = 8,
    parameter FIFO_DEPTH        = 256
)(
    input  wire                         clk,
    input  wire                         rst_n,
    
    // Input spike interface from neurons
    input  wire                         s_spike_valid,
    input  wire [NEURON_ID_WIDTH-1:0]  s_spike_neuron_id,
    output wire                         s_spike_ready,
    
    // Output spike interface to synapses
    output wire                         m_spike_valid,
    output wire [NEURON_ID_WIDTH-1:0]  m_spike_dest_id,
    output wire [WEIGHT_WIDTH-1:0]     m_spike_weight,
    output wire                         m_spike_exc_inh,
    input  wire                         m_spike_ready,
    
    // Configuration interface (from AXI)
    input  wire                         config_we,
    input  wire [31:0]                 config_addr,
    input  wire [31:0]                 config_data,
    output reg  [31:0]                 config_readdata,
    
    // Status
    output wire [31:0]                 routed_spike_count,
    output wire                        router_busy,
    output wire                        fifo_overflow
);

    // State machine states
    localparam IDLE         = 3'd0;
    localparam FETCH_CONN   = 3'd1;
    localparam CHECK_DELAY  = 3'd2;
    localparam ROUTE_SPIKE  = 3'd3;
    localparam NEXT_CONN    = 3'd4;
    
    reg [2:0] state, next_state;
    
    // Connection memory structure
    // Format: [valid(1), exc/inh(1), weight(8), delay(8), dest_id(6)] = 24 bits
    (* ram_style = "block" *)
    reg [23:0] conn_memory [0:(NUM_NEURONS * MAX_FANOUT)-1];
    
    // Connection count per neuron
    reg [7:0] conn_count [0:NUM_NEURONS-1];
    
    // Spike event FIFO
    wire fifo_wr_en, fifo_rd_en;
    wire fifo_empty, fifo_full;
    wire [NEURON_ID_WIDTH-1:0] fifo_spike_id;
    wire [31:0] fifo_timestamp;
    reg [31:0] current_time;
    
    // Processing registers
    reg [NEURON_ID_WIDTH-1:0] current_neuron;
    reg [7:0] conn_index;
    reg [23:0] current_conn;
    reg [31:0] spike_timestamp;
    
    // Output registers
    reg out_valid;
    reg [NEURON_ID_WIDTH-1:0] out_dest_id;
    reg [WEIGHT_WIDTH-1:0] out_weight;
    reg out_exc_inh;
    
    // Statistics
    reg [31:0] spike_counter;
    reg overflow_flag;
    
    //-------------------------------------------------------------------------
    // Input spike FIFO
    //-------------------------------------------------------------------------
    fifo #(
        .DATA_WIDTH(NEURON_ID_WIDTH + 32),
        .DEPTH(FIFO_DEPTH)
    ) spike_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(s_spike_valid && s_spike_ready),
        .wr_data({current_time, s_spike_neuron_id}),
        .full(fifo_full),
        .rd_en(fifo_rd_en),
        .rd_data({fifo_timestamp, fifo_spike_id}),
        .empty(fifo_empty),
        .overflow(fifo_overflow)
    );
    
    assign s_spike_ready = !fifo_full;
    assign fifo_rd_en = (state == IDLE) && !fifo_empty;
    
    // Global timestamp counter
    always @(posedge clk) begin
        if (!rst_n)
            current_time <= 32'd0;
        else
            current_time <= current_time + 1'b1;
    end
    
    //-------------------------------------------------------------------------
    // State machine
    //-------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (!fifo_empty)
                    next_state = FETCH_CONN;
            end
            
            FETCH_CONN: begin
                next_state = CHECK_DELAY;
            end
            
            CHECK_DELAY: begin
                if (current_conn[23] && // valid connection
                    ((current_time - spike_timestamp) >= current_conn[13:6])) // delay expired
                    next_state = ROUTE_SPIKE;
                else
                    next_state = NEXT_CONN;
            end
            
            ROUTE_SPIKE: begin
                if (m_spike_ready)
                    next_state = NEXT_CONN;
            end
            
            NEXT_CONN: begin
                if (conn_index >= conn_count[current_neuron])
                    next_state = IDLE;
                else
                    next_state = FETCH_CONN;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    //-------------------------------------------------------------------------
    // Connection processing
    //-------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            current_neuron <= 0;
            conn_index <= 0;
            current_conn <= 0;
            spike_timestamp <= 0;
            out_valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    if (!fifo_empty) begin
                        current_neuron <= fifo_spike_id;
                        spike_timestamp <= fifo_timestamp;
                        conn_index <= 0;
                    end
                end
                
                FETCH_CONN: begin
                    current_conn <= conn_memory[current_neuron * MAX_FANOUT + conn_index];
                end
                
                ROUTE_SPIKE: begin
                    if (!out_valid || m_spike_ready) begin
                        out_valid <= 1'b1;
                        out_dest_id <= current_conn[5:0];
                        out_weight <= current_conn[21:14];
                        out_exc_inh <= current_conn[22];
                        spike_counter <= spike_counter + 1'b1;
                    end
                end
                
                NEXT_CONN: begin
                    out_valid <= 1'b0;
                    conn_index <= conn_index + 1'b1;
                end
            endcase
        end
    end
    
    // Output assignments
    assign m_spike_valid = out_valid;
    assign m_spike_dest_id = out_dest_id;
    assign m_spike_weight = out_weight;
    assign m_spike_exc_inh = out_exc_inh;
    
    //-------------------------------------------------------------------------
    // Configuration interface
    //-------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            // Initialize connection counts
            for (integer i = 0; i < NUM_NEURONS; i = i + 1) begin
                conn_count[i] <= 8'd0;
            end
            spike_counter <= 32'd0;
        end else if (config_we) begin
            case (config_addr[31:24])
                8'h00: begin // Write connection
                    conn_memory[config_addr[15:0]] <= config_data[23:0];
                end
                8'h01: begin // Write connection count
                    conn_count[config_addr[7:0]] <= config_data[7:0];
                end
                8'h02: begin // Reset statistics
                    if (config_data[0])
                        spike_counter <= 32'd0;
                end
            endcase
        end
    end
    
    // Configuration read
    always @(*) begin
        config_readdata = 32'd0;
        case (config_addr[31:24])
            8'h00: config_readdata = {8'd0, conn_memory[config_addr[15:0]]};
            8'h01: config_readdata = {24'd0, conn_count[config_addr[7:0]]};
            8'h10: config_readdata = spike_counter;
            8'h11: config_readdata = {31'd0, fifo_overflow};
            default: config_readdata = 32'hDEADBEEF;
        endcase
    end
    
    // Status outputs
    assign routed_spike_count = spike_counter;
    assign router_busy = (state != IDLE) || !fifo_empty;

endmodule
