module regfile (
    input  wire        clk,
    input  wire        we,
    input  wire [ 4:0] ra1,
    input  wire [ 4:0] ra2,
    input  wire [ 4:0] ra3,
    input  wire [ 4:0] wa,
    input  wire [31:0] wd,
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    output wire [31:0] rd3,
    input  wire        rst
);
  reg [31:0] rf[32];
  integer i;

  // Write port (negedge to avoid WB/ID clash)
  always @(negedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] <= 32'b0;
      rf[29] <= 32'h100; // $sp
    end
    else if (we && wa != 0) begin
      rf[wa] <= wd;
    end
  end

  assign rd1 = (ra1 == 0) ? 0 : rf[ra1];
  assign rd2 = (ra2 == 0) ? 0 : rf[ra2];
  assign rd3 = (ra3 == 0) ? 0 : rf[ra3];
endmodule

