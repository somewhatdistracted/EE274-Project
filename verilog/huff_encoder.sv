
module huff_encoder
#(
    parameter SYMBOL_WIDTH = 4,
    parameter ENC_MAX_WIDTH = 4,
    parameter ENC_MAX_LEN_WIDTH = 2,
    parameter NUM_SYMBOLS = 16,
    parameter PARALLELIZATION = 4
)(
    input clk,
    input rst_n,
    input config_en,
    input [SYMBOL_WIDTH*PARALLELIZATION-1:0] symbols_in,
    input [ENC_MAX_WIDTH-1:0] config_enc,
    input [ENC_MAX_LEN_WIDTH-1:0] config_enc_len,
    input [NUM_SYMBOLS-1:0] config_select,
    output reg [ENC_MAX_WIDTH*PARALLELIZATION-1:0] enc_out,
    output reg [ENC_MAX_LEN_WIDTH-1:0] enc_len
);

    /*
    reg [ENC_MAX_WIDTH-1:0] enc_lut [NUM_SYMBOLS-1:0];
    reg [ENC_MAX_LEN_WIDTH-1:0] enc_len_lut [NUM_SYMBOLS-1:0];

    always @(*) begin
        if (rst_n == 1'b1) begin
            if (config_en == 1'b1) begin
                enc_lut[config_select] <= config_enc;
                enc_len_lut[config_select] <= config_enc_len;
                enc => 0;
                enc_len => 0;
            end else begin
                enc => enc_lut[symbol];
                enc_len => enc_len_lut[symbol];
            end
        end else begin
            enc_lut => 0;
            enc_len_lut => 0;
            enc => 0;
            enc_len => 0;
        end
    end
    */

    reg [ENC_MAX_WIDTH-1:0] enc_out_preserialization [PARALLELIZATION-1:0];
    reg [ENC_MAX_LEN_WIDTH-1:0] enc_out_ps_len [PARALLELIZATION-1:0];

    genvar i;
    generate
        for (i = 0; i < PARALLELIZATION; i++) begin : enc_atoms
            huff_encoder_atom #(
                .SYMBOL_WIDTH(SYMBOL_WIDTH),
                .ENC_MAX_WIDTH(ENC_MAX_WIDTH),
                .ENC_MAX_LEN_WIDTH(ENC_MAX_LEN_WIDTH),
                .NUM_SYMBOLS(NUM_SYMBOLS)
            ) enc_atom (
                .clk(clk),
                .rst_n(rst_n),
                .config_en(config_en),
                .symbol(symbols_in[((i+1)*SYMBOL_WIDTH)-1:(i*SYMBOL_WIDTH)]),
                .config_enc(config_enc),
                .config_enc_len(config_enc_len),
                .config_select(config_select),
                .enc(enc_out_preserialization[i]),
                .enc_len(enc_out_ps_len[i])
            );
        end
    endgenerate

endmodule
