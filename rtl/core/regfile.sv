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

  // Write port
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] <= 32'b0;
      rf[29] <= 32'h100; // $sp
    end
    else if (we && wa != 0) begin
      rf[wa] <= wd;
    end
  end

  // Async reads with write-through bypass (to avoid WB/ID clash)
  always_comb begin
    rd1 = (ra1 == 0) ? 32'b0 : rf[ra1];
    rd2 = (ra2 == 0) ? 32'b0 : rf[ra2];
    rd3 = (ra3 == 0) ? 32'b0 : rf[ra3];

    if (we && (wa != 0) && (wa == ra1)) rd1 = wd;
    if (we && (wa != 0) && (wa == ra2)) rd2 = wd;
    if (we && (wa != 0) && (wa == ra3)) rd3 = wd;
  end
endmodule

