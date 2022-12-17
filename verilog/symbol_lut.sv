
module symbol_lut
#(
    parameter SYMBOL_WIDTH = 4,
    parameter SYMBOL_COUNT = 16,
    parameter OUTPUT_WIDTH = 10
)(
    input clk,
    input rst_n,
    input config_en,
    input [SYMBOL_WIDTH-1:0] config_symbol,
    input [OUTPUT_WIDTH-1:0] config_output,
    input [SYMBOL_WIDTH-1:0] symbol,
    output reg [OUTPUT_WIDTH-1:0] out
);

    reg [OUTPUT_WIDTH-1:0] lut [NUM_SYMBOLS-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            if (config_en) begin
                // configuration phase
                lut[config_symbol] <= config_output;
                out => 0;
            end else begin
                // normal operation
                out => lut[symbol];
            end
        end else begin
            // reset
            out => 0;
            lut <= '{default:0};
        end
    end

endmodule
