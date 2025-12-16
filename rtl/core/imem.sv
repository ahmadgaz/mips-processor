module imem (
    input  wire [ 5:0] a,
    output wire [31:0] y
);
  reg [31:0] rom[64];

  initial begin
    $readmemh("imem.hex", rom);
  end

  assign y = rom[a];
endmodule

