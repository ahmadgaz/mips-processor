module imem (
    input  wire [ 5:0] a,
    output wire [31:0] y
);
  reg [31:0] rom[64];
  string memfile;

  initial begin
    if (!$value$plusargs("MEMFILE=%s", memfile)) begin
      $fatal(1, "[IMEM] Must include +MEMFILE argument");
    end
    $readmemh(memfile, rom);
  end

  assign y = rom[a];
endmodule

