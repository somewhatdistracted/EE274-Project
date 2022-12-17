
module rans_encoder
#(
    parameter SYMBOL_WIDTH = 4,
    parameter LOG_M = 10, // ideally we make M a power of 2
    parameter CONST_T = 1
)(
    input clk,
    input rst_n,
    input config_en,
    input [SYMBOL_WIDTH-1:0] symbol,
    input [LOG_H-1:0] config_freq,
    input [LOG_H-1:0] config_inv_freq,
    input [LOG_H-1:0] config_cumul,
    output reg [LOG_M-1:0] enc,
    output reg [LOG_M-1:0] enc_len
);
    localparam EM = $exp2(LOG_M);
    localparam LOG_H = LOG_M * $clog2(CONST_T) + 1;

    logic [STATE_WIDTH-1:0] state;
    wire [LOG_M-1:0] shrink_shift_binary_line;
    logic [LOG_M-1:0] shrink_shift;

    logic [LOG_H-1:0] freq;
    logic [LOG_H-1:0] inv_freq;
    logic [LOG_H-1:0] cumul;

    // LUTs for freq[s], freq_inv[s] and cumul[s]
    symbol_lut #(
        .SYMBOL_WIDTH(SYMBOL_WIDTH),
        .SYMBOL_COUNT(NUM_SYMBOLS),
        .OUTPUT_WIDTH(LOG_H)
    ) freq_lut (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(symbol),
        .config_output(config_freq),
        .symbol(symbol),
        .out(freq)
    );

    symbol_lut #(
        .SYMBOL_WIDTH(SYMBOL_WIDTH),
        .SYMBOL_COUNT(NUM_SYMBOLS),
        .OUTPUT_WIDTH(LOG_H)
    ) freq_inv_lut (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(symbol),
        .config_output(config_inv_freq),
        .symbol(symbol),
        .out(inv_freq)
    );

    symbol_lut #(
        .SYMBOL_WIDTH(SYMBOL_WIDTH),
        .SYMBOL_COUNT(NUM_SYMBOLS),
        .OUTPUT_WIDTH(LOG_M)
    ) cumul_lut (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(symbol),
        .config_output(config_cumul),
        .symbol(symbol),
        .out(cumul)
    );

    // shrink_state parallel finder
    // all the comparator results are stored in binary_line
    genvar i;
    generate
        for (i = 0; i < LOG_M; i++) begin
            assign shrink_shift_binary_line[i] = ((state >> i) < (freq << 1));
        end
    endgenerate

    // arbiter and one-hot decoder 
    always_comb begin
        shrink_shift = 0;
        for (int j = 0; j < LOG_M; j++) begin
            if (shrink_shift_binary_line[j]) begin
                shrink_shift = j;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n && !config_en) begin
            // normal operation
            enc <= state[shrink_shift-1:0];
            enc_len <= shrink_shift;

            // encode step logic
            // NOTE: VERIFY BITLENGTHS
            div <= (state[LOG_H-1:0]*inv_freq)[2*LOG_H-1:LOG_H];
            state <= (div << LOG_M - shrink_shift) + cumul + state - (div >> shrink_shift)*freq;

        end else begin
            // reset
            state = EM;
            enc => 0;
            enc_len => 0;
        end
    end

endmodule
