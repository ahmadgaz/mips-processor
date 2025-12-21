module dmem (
    input  wire        clk,
    input  wire        we,
    input  wire [ 5:0] a,
    input  wire [31:0] d,
    output wire [31:0] q,
    input  wire        rst
);
  reg [31:0] ram[64];
  integer i;

  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        ram[i] = 32'hFFFFFFFF;
    end
    else if (we) begin
      ram[a] <= d;
    end
  end

  assign q = ram[a];
endmodule

