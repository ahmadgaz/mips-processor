module mips_fpga (
    input  wire       clk,
    input  wire       rst,
    input  wire [5:0] switches,
    output wire       factErr,
    output wire       dispSe,
    output wire [3:0] LEDSEL,
    output wire [7:0] LEDOUT
);
  wire [15:0] reg_hex;
  wire        clk_sec;
  wire        clk_5KHz;

  wire [ 7:0] digit0;
  wire [ 7:0] digit1;
  wire [ 7:0] digit2;
  wire [ 7:0] digit3;

  wire [31:0] pc_current;
  wire [31:0] instr;
  wire [31:0] alu_out;
  wire [31:0] wd_dm;
  wire [31:0] rd_dm;
  wire [31:0] dispData;
  wire [31:0] gpo1;
  wire [31:0] gpo2;
  assign factErr = gpo1[0];

  clk_gen clk_gen (
      .clk100MHz(clk),
      .rst      (rst),
      .clk_4sec (clk_sec),
      .clk_5KHz (clk_5KHz)
  );

  mips_soc dut (
      .clk       (clk_5KHz),
      .rst       (rst),
      .gpi1      ({27'd0, switches[4:0]}),
      .gpi2      (gpo1),
      .pc_current(pc_current),
      .instr     (instr),
      .alu_out   (alu_out),
      .wd_dm     (wd_dm),
      .rd_dm     (rd_dm),
      .gpo1      (gpo1),
      .gpo2      (gpo2)
  );

  mux2 #(16) reg_hex_mux (
      .sel(gpo1[4]),
      .a  (gpo2[15:0]),
      .b  (gpo2[31:16]),
      .y  (reg_hex)
  );

  hex_to_7seg hex3 (
      .HEX(reg_hex[15:12]),
      .s  (digit3)
  );

  hex_to_7seg hex2 (
      .HEX(reg_hex[11:8]),
      .s  (digit2)
  );

  hex_to_7seg hex1 (
      .HEX(reg_hex[7:4]),
      .s  (digit1)
  );

  hex_to_7seg hex0 (
      .HEX(reg_hex[3:0]),
      .s  (digit0)
  );

  led_mux led_mux (
      .clk   (clk_5KHz),
      .rst   (rst),
      .LED3  (digit3),
      .LED2  (digit2),
      .LED1  (digit1),
      .LED0  (digit0),
      .LEDSEL(LEDSEL),
      .LEDOUT(LEDOUT)
  );
endmodule
