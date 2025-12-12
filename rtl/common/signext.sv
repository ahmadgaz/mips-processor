module signext #(
    parameter int INWIDTH  = 16,
    parameter int OUTWIDTH = 32
) (
    input  wire [ INWIDTH-1:0] a,
    output wire [OUTWIDTH-1:0] y
);
  localparam int EXTBITS = OUTWIDTH - INWIDTH;
  assign y = {{EXTBITS{a[INWIDTH-1]}}, a};
endmodule

