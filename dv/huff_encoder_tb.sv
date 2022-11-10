module huff_encoder_tb
#(
    parameter SYMBOL_WIDTH = 4,
    parameter ENC_MAX_WIDTH = 4,
    parameter ENC_MAX_LEN_WIDTH = 2,
    parameter NUM_SYMBOLS = 16,
    parameter PARALLELIZATION = 4
);

    reg clk,
    reg rst_n,
    reg config_en,
    reg [SYMBOL_WIDTH*PARALLELIZATION-1:0] symbols_in,
    reg [ENC_MAX_WIDTH-1:0] config_enc,
    reg [ENC_MAX_LEN_WIDTH-1:0] config_enc_len,
    reg [NUM_SYMBOLS-1:0] config_select,
    wire [ENC_MAX_WIDTH*PARALLELIZATION-1:0] enc_out,
    wire [ENC_MAX_LEN_WIDTH-1:0] enc_len
    reg [ENC_MAX_WIDTH-1:0] enc_lut [NUM_SYMBOLS-1:0];
    reg [ENC_MAX_LEN_WIDTH-1:0] enc_len_lut [NUM_SYMBOLS-1:0];

    always #10 clk = ~clk;

    // initialize module here
    
    initial begin
        clk <= 0;
        rst_n <= 1;
        config_en <= 0;
        symbols_in <= 0;
        config_enc <= 0;
        config_enc_len <= 0;
        config_select <= 0;

        // reset
        #20 rst_n <= 0;
        #20 rst_n <= 1;

endmodule
