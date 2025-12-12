module datapath (
    input wire clk,
    input wire rst,

    // -----------------------
    // Data inputs
    // -----------------------
    input wire [31:0] awd_rfw,
    input wire [31:0] rd_dmw,
    input wire [ 4:0] rte,
    input wire [ 4:0] rde,
    input wire [31:0] instrd,
    input wire [ 4:0] ra3,
    input wire [31:0] rd1_rfd,
    input wire [31:0] pc_plus4d,
    input wire [31:0] pc_plus4w,
    input wire [31:0] alu_pae,
    input wire [31:0] wd_dme,
    input wire [31:0] sext_imme,
    input wire [ 4:0] rf_waw,
    input wire [31:0] alu_outm,
    input wire [31:0] hiwd_rfm,
    input wire [31:0] lowd_rfm,
    input wire [ 4:0] shamte,

    // -----------------------
    // Control inputs
    // -----------------------
    input wire       hilo_wee,
    input wire       alu_srce,
    input wire [2:0] alu_ctrle,
    input wire [1:0] rf_awd_srcm,
    input wire [1:0] dm2regw,
    input wire [1:0] reg_dste,
    input wire       we_regw,
    input wire       pc_src,
    input wire       jump,
    input wire       j_src,

    // -----------------------
    // Hazard inputs
    // -----------------------
    input wire stall_f,

    // -----------------------
    // Data outputs
    // -----------------------
    output wire [31:0] lowd_rf,
    output wire [31:0] hiwd_rf,
    output wire [31:0] alu_out,
    output wire [31:0] awd_rf,
    output wire [31:0] wd_rf,
    output wire [ 4:0] rf_wa,
    output wire [31:0] sext_imm,
    output wire [31:0] rd3,
    output wire [31:0] rd2_rf,
    output wire [31:0] rd1_rf,
    output wire [31:0] pc_plus4,
    output wire [31:0] pc_current
);
  wire [63:0] mult_out;
  wire [31:0] alu_pb;
  wire [31:0] ba;
  wire [31:0] bta;
  wire [31:0] jta;
  wire [31:0] pc_pre_jmp;
  wire [31:0] pc_pre_jr;
  wire [31:0] pc_next;

  // Branch address: sign-extended immediate << 2
  assign ba  = {sext_imm[29:0], 2'b0};

  // Jump target address: {PC+4[31:28], instr[25:0], 2'b00}
  assign jta = {pc_plus4d[31:28], instrd[25:0], 2'b0};

  mult #(32) mult (
      .a(alu_pae),
      .b(wd_dme),
      .y(mult_out)
  );

  dreg #(32) lo (
      .en (hilo_wee),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .d  (mult_out[31:0]),
      .q  (lowd_rf)
  );

  dreg #(32) hi (
      .en (hilo_wee),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .d  (mult_out[63:32]),
      .q  (hiwd_rf)
  );

  mux2 #(32) alu_pb_mux (
      .sel(alu_srce),
      .a  (wd_dme),
      .b  (sext_imme),
      .y  (alu_pb)
  );

  alu #(32) alu (
      .op   (alu_ctrle),
      .a    (alu_pae),
      .b    (alu_pb),
      .shamt(shamte),
      .zero (),
      .y    (alu_out)
  );

  mux3 #(32) rf_awd_mux (
      .sel(rf_awd_srcm),
      .a  (alu_outm),
      .b  (hiwd_rfm),
      .c  (lowd_rfm),
      .y  (awd_rf)
  );

  mux3 #(32) rf_mwd_mux (
      .sel(dm2regw),
      .a  (awd_rfw),
      .b  (rd_dmw),
      .c  (pc_plus4w),
      .y  (wd_rf)
  );

  mux3 #(5) rf_wa_mux (
      .sel(reg_dste),
      .a  (rte),
      .b  (rde),
      .c  (5'd31),
      .y  (rf_wa)
  );

  signext #(
      .INWIDTH (16),
      .OUTWIDTH(32)
  ) se (
      .a(instrd[15:0]),
      .y(sext_imm)
  );

  regfile rf (
      .rst(rst),
      .clk(clk),
      .we (we_regw),
      .rd3(rd3),
      .ra1(instrd[25:21]),
      .ra2(instrd[20:16]),
      .ra3(ra3),
      .wa (rf_waw),
      .wd (wd_rf),
      .rd1(rd1_rf),
      .rd2(rd2_rf)
  );

  adder #(32) pc_plus_4 (
      .a(pc_current),
      .b(32'd4),
      .y(pc_plus4)
  );

  adder #(32) pc_plus_br (
      .a(pc_plus4d),
      .b(ba),
      .y(bta)
  );

  mux2 #(32) pc_src_mux (
      .sel(pc_src),
      .a  (pc_plus4),
      .b  (bta),
      .y  (pc_pre_jmp)
  );

  mux2 #(32) pc_jmp_mux (
      .sel(jump),
      .a  (pc_pre_jmp),
      .b  (jta),
      .y  (pc_pre_jr)
  );

  mux2 #(32) pc_jr_mux (
      .sel(j_src),
      .a  (pc_pre_jr),
      .b  (rd1_rfd),
      .y  (pc_next)
  );

  dreg #(32) pc_reg (
      .en (!stall_f),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .d  (pc_next),
      .q  (pc_current)
  );
endmodule
