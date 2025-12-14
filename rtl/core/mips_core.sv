module mips_core (
    input wire        clk,
    input wire        rst,
    input wire [ 4:0] ra3,
    input wire [31:0] instr,
    input wire [31:0] rd_dm,

    output wire [31:0] alu_out,
    output wire [31:0] wd_dm,
    output wire        we_dm,
    output wire [31:0] pc_current,
    output wire [31:0] rd3
);

  wire [31:0] instrd;
  wire        branch;
  wire [ 1:0] reg_dst;
  wire        we_reg;
  wire        alu_src;
  wire [ 1:0] dm2reg;
  wire [ 2:0] alu_ctrl;
  wire [ 1:0] rf_awd_src;
  wire        hilo_we;
  wire        we_dm_cu;
  wire        jump;
  wire        j_src;
  wire [31:0] pc_plus4;
  wire [31:0] rd1_rf;
  wire [31:0] rd2_rf;
  wire [31:0] sext_imm;
  wire [31:0] wd_rf;
  wire [31:0] alu_out_dp;
  wire [31:0] lowd_rf;
  wire [31:0] hiwd_rf;
  wire [ 4:0] rf_wa;
  wire [31:0] awd_rf;
  wire        hilo_wee;
  wire        alu_srce;
  wire [ 2:0] alu_ctrle;
  wire [ 1:0] rf_awd_srcm;
  wire [ 1:0] dm2regw;
  wire [ 1:0] reg_dste;
  wire        we_regw;
  wire        pc_src;
  wire [ 4:0] shamte;
  wire [31:0] lowd_rfm;
  wire [31:0] hiwd_rfm;
  wire [ 4:0] rf_waw;
  wire [31:0] sext_imme;
  wire [31:0] wd_dme;
  wire [31:0] alu_pae;
  wire [31:0] pc_plus4w;
  wire [31:0] pc_plus4d;
  wire [31:0] rd1_rfd;
  wire [ 4:0] rde;
  wire [ 4:0] rte;
  wire [31:0] rd_dmw;
  wire [31:0] awd_rfw;
  wire        stall_f;
  wire [ 1:0] forward_ae;
  wire [ 1:0] forward_be;
  wire        forward_ad;
  wire        forward_bd;
  wire        stall_d;
  wire        flush_e;
  wire [ 4:0] rse;
  wire [ 4:0] rf_wam;
  wire        we_rege;
  wire        we_regm;
  wire [ 1:0] dm2rege;
  wire [ 1:0] dm2regm;

  controlunit cu (
      // Inputs
      .opcode(instrd[31:26]),
      .funct (instrd[5:0]),

      // Outputs
      .branch    (branch),
      .reg_dst   (reg_dst),
      .we_reg    (we_reg),
      .alu_src   (alu_src),
      .dm2reg    (dm2reg),
      .alu_ctrl  (alu_ctrl),
      .rf_awd_src(rf_awd_src),
      .hilo_we   (hilo_we),
      .we_dm     (we_dm_cu),
      .jump      (jump),
      .j_src     (j_src)
  );

  datapath dp (
      // Inputs
      .clk        (clk),
      .rst        (rst),
      .jump       (jump),
      .j_src      (j_src),
      .hilo_wee   (hilo_wee),
      .alu_srce   (alu_srce),
      .alu_ctrle  (alu_ctrle),
      .rf_awd_srcm(rf_awd_srcm),
      .dm2regw    (dm2regw),
      .reg_dste   (reg_dste),
      .we_regw    (we_regw),
      .pc_src     (pc_src),
      .shamte     (shamte),
      .lowd_rfm   (lowd_rfm),
      .hiwd_rfm   (hiwd_rfm),
      .alu_outm   (alu_out),
      .rf_waw     (rf_waw),
      .sext_imme  (sext_imme),
      .wd_dme     (wd_dme),
      .alu_pae    (alu_pae),
      .pc_plus4w  (pc_plus4w),
      .pc_plus4d  (pc_plus4d),
      .rd1_rfd    (rd1_rfd),
      .rde        (rde),
      .rte        (rte),
      .rd_dmw     (rd_dmw),
      .awd_rfw    (awd_rfw),
      .stall_f    (stall_f),
      .targetd    (instrd[25:0]),
      .immd       (instrd[15:0]),
      .ra1d       (instrd[25:21]),
      .ra2d       (instrd[20:16]),
      .ra3        (ra3),

      // Outputs
      .pc_plus4  (pc_plus4),
      .rd1_rf    (rd1_rf),
      .rd2_rf    (rd2_rf),
      .sext_imm  (sext_imm),
      .wd_rf     (wd_rf),
      .alu_out   (alu_out_dp),
      .lowd_rf   (lowd_rf),
      .hiwd_rf   (hiwd_rf),
      .rf_wa     (rf_wa),
      .awd_rf    (awd_rf),
      .pc_current(pc_current),
      .rd3       (rd3)
  );

  hazardunit hu (
      // Outputs
      .stall_f   (stall_f),
      .forward_ae(forward_ae),
      .forward_be(forward_be),
      .forward_ad(forward_ad),
      .forward_bd(forward_bd),
      .stall_d   (stall_d),
      .flush_e   (flush_e),

      // Inputs
      .rf_waw    (rf_waw),
      .we_regw   (we_regw),
      .rse       (rse),
      .rte       (rte),
      .rf_wae    (rf_wa),
      .rf_wam    (rf_wam),
      .we_rege   (we_rege),
      .we_regm   (we_regm),
      .lw_dm2rege(dm2rege[0]),
      .dm2regm   (dm2regm),
      .rsd       (instrd[25:21]),
      .rtd       (instrd[20:16]),
      .branch    (branch),
      .j_src     (j_src)
  );

  pipeline pl (
      // Inputs
      .clk       (clk),
      .rst       (rst),
      .instr     (instr),
      .rd_dm     (rd_dm),
      .branch    (branch),
      .reg_dst   (reg_dst),
      .we_reg    (we_reg),
      .alu_src   (alu_src),
      .dm2reg    (dm2reg),
      .alu_ctrl  (alu_ctrl),
      .rf_awd_src(rf_awd_src),
      .hilo_we   (hilo_we),
      .we_dm     (we_dm_cu),
      .jump      (jump),
      .j_src     (j_src),
      .pc_plus4  (pc_plus4),
      .rd1_rf    (rd1_rf),
      .rd2_rf    (rd2_rf),
      .sext_imm  (sext_imm),
      .wd_rf     (wd_rf),
      .alu_out   (alu_out_dp),
      .lowd_rf   (lowd_rf),
      .hiwd_rf   (hiwd_rf),
      .awd_rf    (awd_rf),
      .rf_wa     (rf_wa),
      .forward_ae(forward_ae),
      .forward_be(forward_be),
      .forward_ad(forward_ad),
      .forward_bd(forward_bd),
      .stall_d   (stall_d),
      .flush_e   (flush_e),

      // Outputs
      .alu_outm   (alu_out),
      .wd_dmm     (wd_dm),
      .we_dmm     (we_dm),
      .instrd     (instrd),
      .hilo_wee   (hilo_wee),
      .alu_srce   (alu_srce),
      .alu_ctrle  (alu_ctrle),
      .rf_awd_srcm(rf_awd_srcm),
      .dm2regw    (dm2regw),
      .reg_dste   (reg_dste),
      .pc_src     (pc_src),
      .shamte     (shamte),
      .lowd_rfm   (lowd_rfm),
      .hiwd_rfm   (hiwd_rfm),
      .sext_imme  (sext_imme),
      .wd_dme     (wd_dme),
      .alu_pae    (alu_pae),
      .pc_plus4w  (pc_plus4w),
      .pc_plus4d  (pc_plus4d),
      .rd1_rfd    (rd1_rfd),
      .rde        (rde),
      .rd_dmw     (rd_dmw),
      .awd_rfw    (awd_rfw),
      .rte        (rte),
      .we_regw    (we_regw),
      .rf_waw     (rf_waw),
      .rse        (rse),
      .rf_wam     (rf_wam),
      .we_rege    (we_rege),
      .we_regm    (we_regm),
      .dm2regm    (dm2regm),
      .dm2rege    (dm2rege)
  );
endmodule
