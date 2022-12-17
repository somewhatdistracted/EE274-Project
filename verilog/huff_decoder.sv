
module huff_decoder
#(
    parameter SYMBOL_WIDTH = 4,
    parameter ENC_MAX_WIDTH = 4,
    parameter ENC_MAX_LEN_WIDTH = 2,
    parameter NUM_SYMBOLS = 16,
    parameter RELATIVE_PARALELLIZATION = 2, // relative parallelization of the encoder to decoder
)(
    input clk,
    input rst_n,
    input config_en,
    input [SYMBOL_WIDTH-1:0] symbol,
    input [ENC_MAX_WIDTH:0] config_enc,
    input [SYMBOL_WIDTH:0] config_symbol,
    output reg [SYMBOL_WIDTH-1:0] decoded_symbol
);

    reg [ENC_MAX_WIDTH:0] state;
    reg [RELATIVE_PARALLELIZATION-1:0] symbol_cnt;
    reg [SYMBOL_WIDTH-1:0] decoded_symbols [RELATIVE_PARALLELIZATION-1:0];
    wire [SYMBOL_WIDTH:0] symbol_match;

    symbol_lut #(
        .SYMBOL_WIDTH(ENC_MAX_WIDTH+1),
        .SYMBOL_COUNT(MAX_STATES),
        .OUTPUT_WIDTH(SYMBOL_WIDTH+1)
    ) lut (
        .clk(clk),
        .rst_n(rst_n),
        .config_en(config_en),
        .config_symbol(config_enc),
        .config_output(config_symbol),
        .symbol(state)
        .out(symbol_match)
    );

    always_ff @(*) begin
        if (rst_n == 1'b1) begin
            if (state) begin
                if (symbol_match[0]) begin
                    // matched a symbol, reset state and copy over symbol
                    decoded_symbols[symbol_cnt] <= symbol_match[SYMBOL_WIDTH:1];
                    decoded_symbol <= symbol_match[SYMBOL_WIDTH:1];
                    state <= 1;
                    symbol_cnt <= symbol_cnt + 1;
                end
            end else begin
                // state was 0, meaning FSM reset.
                state => 1;
            end
        end else begin
            state => 0;
            decoded_symbols => 0;
            symbol_cnt => 0;
        end
    end

endmodule
