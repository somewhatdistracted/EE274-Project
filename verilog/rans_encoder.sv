
module rans_encoder
#(
    parameter SYMBOL_WIDTH = 4,
    parameter LOG_M = 10, // ideally we make M a power of 2
    parameter CONST_T = 1,
    
)(
    input clk,
    input rst_n,
    input config_en,
    input [SYMBOL_WIDTH-1:0] symbol,
    input [ENC_MAX_WIDTH-1:0] config_enc,
    input [ENC_MAX_LEN_WIDTH-1:0] config_enc_len,
    input [NUM_SYMBOLS-1:0] config_select,
    output reg [ENC_MAX_WIDTH-1:0] enc,
    output reg [ENC_MAX_LEN_WIDTH-1:0] enc_len
);

    localparam LOG_H = LOG_M * $clog2(CONST_T) + 1;

    reg [LOG_H-1:0] freq_inv_lut [NUM_SYMBOLS-1:0];
    reg [LOG_M-1:0] cumul_lut [NUM_SYMBOLS-1:0];

    always @(*) begin
        if (rst_n == 1'b1) begin
            // normal operation
            if (config_en == 1'b1) begin
                // configuration phase
                enc_lut[config_select] <= config_enc;
                enc_len_lut[config_select] <= config_enc_len;
                enc => 0;
                enc_len => 0;
            end else begin
                // normal operation
                enc => enc_lut[symbol];
                enc_len => enc_len_lut[symbol];
            end
        end else begin
            // reset
            enc_lut => 0;
            enc_len_lut => 0;
            enc => 0;
            enc_len => 0;
        end
    end

endmodule
