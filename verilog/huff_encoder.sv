
module huff_encoder
#(
    parameter SYMBOL_WIDTH = 4,
    parameter ENC_MAX_WIDTH = 4,
    parameter ENC_MAX_LEN_WIDTH = 2,
    parameter OUTPUT_BLOCK_SIZE = 8,
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
    output reg [ENC_MAX_LEN_WIDTH*PARALLELIZATION-1:0] enc_len_out
);

    logic wire [ENC_MAX_WIDTH-1:0] enc_out_preserialization [PARALLELIZATION-1:0];
    logic wire [ENC_MAX_WIDTH*PARALLELIZATION-1:0] enc_out_serial [PARALLELIZATION-1:0];
    wire [ENC_MAX_LEN_WIDTH-1:0] enc_out_ps_len [PARALLELIZATION-1:0];
    wire [ENC_MAX_LEN_WIDTH-1:0] enc_len_out_serial [PARALLELIZATION-1:0];

    // Generate blocks. These blocks enable the parallel instantiations of
    // multiple encoder atoms.
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

    // This code block collapses the parallel encodings into one serialized
    // encoding block. It does so by iteratively building the collective length
    // value as well as the actual output encoding.
    assign enc_len_out_serial[0] = enc_out_ps_len[0];
    assign enc_out_serial[0] = enc_out_preserialization[0];
    genvar j;
    generate
        for (j = 1; j < PARALLELIZATION; j++) begin
            assign enc_len_out_serial[j] = enc_len_out_serial[j-1] + enc_out_ps_len[j+1];
            assign enc_out_serial[k] = enc_out_serial[k-1] + (enc_out_preserialization[k] << enc_len_out_serial[k-1]);
        end
    endgenerate

    // always block to register the output and enable resetting.
    always_ff @(posedge clk) begin
        if (rst_n) begin
            // normal operation
            enc_out <= enc_out_serial[PARALLELIZATION-1];
            enc_len_out <= enc_len_out_serial[PARALLELIZATION-2];
        end else begin
            // reset
            enc_out <= 0;
            enc_len_out <= 0;
        end
    end

endmodule
