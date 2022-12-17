
module rans_decoder
#(
    parameter SYMBOL_WIDTH = 4,
    parameter LOG_M = 10, // ideally we make M a power of 2
    parameter CONST_T = 1,
    parameter BIN_PARALLELISM = 8
)(
    input clk,
    input rst_n,
    input config_en,
    input [SYMBOL_WIDTH-1:0] config_symbol,
    input [LOG_H-1:0] config_freq,
    input [LOG_M-1:0] config_cumul,
    input [LOG_M-1:0] partial_enc,
    output reg [SYMBOL_WIDTH-1:0] symbol,
    output reg [ENC_MAX_LEN_WIDTH-1:0] enc_len
);
    localparam EM = $exp2(LOG_M);
    localparam LOG_H = LOG_M * $clog2(CONST_T) + 1;
    localparam P_WIDTH = $clog2(BIN_PARALLELISM);

    logic [STATE_WIDTH-1:0] state;
    logic [LOG_M-1:0] cumul_array [NUM_SYMBOLS-1:0];
    logic search_one_hot [BIN_PARALLELISM-1:0];
    logic [P_WIDTH-1:0] depth;
    logic [P_WIDTH-1:0] search_found;

    // LUTs for freq[s], cumul[s], and cumul_rev[cumul]
    symbol_lut #(
        .SYMBOL_WIDTH(SYMBOL_WIDTH),
        .SYMBOL_COUNT(NUM_SYMBOLS),
        .OUTPUT_WIDTH(LOG_H)
    ) freq_lut (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(),
        .config_output(),
        .symbol(symbol),
        .out(freq)
    );

    symbol_lut #(
        .SYMBOL_WIDTH(SYMBOL_WIDTH),
        .SYMBOL_COUNT(NUM_SYMBOLS),
        .OUTPUT_WIDTH(LOG_M)
    ) cumul_lut (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(),
        .config_output(),
        .symbol(symbol),
        .out(cumul)
    );

    symbol_lut #(
        .SYMBOL_WIDTH(LOG_M),
        .SYMBOL_COUNT(NUM_SYMBOLS),
        .OUTPUT_WIDTH(SYMBOL_WIDTH)
    ) cumul_rev (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(),
        .config_output(),
        .symbol(match),
        .out(symbol)
    );

    always_comb begin
        for (int i = 0; i < BIN_PARALLELISM; i++) begin
            search_one_hot[i] = cumul_array[i << depth] > state[LOG_M-1:0];
        end
        search_found = 0;
        for (int i = 0; i < BIN_PARALLELISM; i++) begin
            if (search_one_hot[i]) begin
                search_found = i
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n && !config_en) begin
            if (state) begin
                // normal operation
                
                // decode step logic
                state <= (state >> LOG_M)*freq + state[LOG_M-1:0] - cumul;

                // expand state logic
                // NOTE: VERIFY BITLENGTHS
            end else begin
                // state just reset, copy in partial state
                state <= partial_enc;

        end else begin
            // reset
            state <= 0;
            enc <= 0;
            enc_len <= 0;
        end
    end

endmodule
