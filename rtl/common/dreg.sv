module dreg #(
    parameter int WIDTH = 32
) (
    input wire clk,
    input wire rst,
    input wire clr,
    input wire en,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
  always @(posedge clk) begin
    if (rst) q <= 0;
    else if (clr && en) q <= 0;
    else if (en) q <= d;
  end
endmodule
