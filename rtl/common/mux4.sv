module mux4 #(
    parameter int WIDTH = 32
) (
    input  wire [      1:0] sel,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [WIDTH-1:0] c,
    input  wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] y
);
  assign y = (sel == 2'd3) ? d : (sel == 2'd2) ? c : (sel == 2'd1) ? b : a;
endmodule

