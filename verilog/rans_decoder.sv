
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
    input [SYMBOL_WIDTH-1:0] symbol,
    output reg [ENC_MAX_WIDTH-1:0] enc,
    output reg [ENC_MAX_LEN_WIDTH-1:0] enc_len
);
    localparam EM = $exp2(LOG_M);
    localparam LOG_H = LOG_M * $clog2(CONST_T) + 1;

    logic [STATE_WIDTH-1:0] state;

    // LUTs for freq[s], freq_inv[s] and cumul[s]
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
        .symbol(),
        .out()
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
        .symbol(),
        .out()
    );

    always_ff @(posedge clk) begin
        if (rst_n && !config_en) begin
            // normal operation
            
            // decode step logic
            state <= (state >> LOG_M)*freq + state[LOG_M-1:0] - cumul;

            // expand state logic
            // NOTE: VERIFY BITLENGTHS

        end else begin
            // reset
            state <= 0;
            enc <= 0;
            enc_len <= 0;
        end
    end

endmodule
