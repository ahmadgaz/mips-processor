module down_cnt #(
    parameter int WIDTH = 32
) (
    input clk,
    input en,
    input load_cnt,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
  always @(posedge clk) begin
    if (load_cnt) q <= d;
    else if (en) q <= q - 1;
  end
endmodule
