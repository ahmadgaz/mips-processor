`timescale 1ns / 1ps

module tb_mips_soc;
  reg         clk;
  reg         rst;


  reg  [31:0] gpi1;
  wire [31:0] gpo1;
  wire [31:0] gpo2;
  wire [31:0] pc_current;
  wire [31:0] instr;
  wire [31:0] alu_out;
  wire [31:0] wd_dm;
  wire [31:0] rd_dm;
  wire        we_dm;

  mips_soc dut (
      .clk       (clk),
      .rst       (rst),
      .ra3       (5'b0),
      .gpi1      (gpi1),
      .gpi2      (gpo1),
      .pc_current(pc_current),
      .instr     (instr),
      .alu_out   (alu_out),
      .wd_dm     (wd_dm),
      .rd_dm     (rd_dm),
      .gpo1      (gpo1),
      .gpo2      (gpo2),
      .rd3       (),
      .we_dm     ()
  );

  initial begin
    clk = 1'b0;
  end

  always #5 clk = ~clk;

  initial begin
    rst  = 1'b1;
    gpi1 = 3;

    #40;
    rst = 1'b0;
  end

  always @(posedge clk) begin
    $stop;
    $strobe("%8t rst=%b we_dm=%b pc=%h instr=%h alu=%h wd_dm=%h rd_dm=%h", $time, rst, we_dm,
            pc_current, instr, alu_out, wd_dm, rd_dm);
    // Example stop condition if you want to break at a specific PC
    if (pc_current === 32'h00000100) begin
      $display("Reached PC 0x00000100 at time %0t, stopping.", $time);
      $stop;
    end
  end

  always @(pc_current or rst) begin
    if (!rst && (^pc_current === 1'bx)) begin
      $display("PC went X at time %0t, finishing simulation.", $time);
      $finish;
    end
  end

endmodule
