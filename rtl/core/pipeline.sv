import pipeline_types_pkg::*;

module pipeline (
    input wire clk,
    input wire rst,

    // -----------------------
    // Data inputs
    // -----------------------
    input wire [31:0] awd_rf,
    input wire [31:0] rd_dm,
    input wire [ 4:0] rf_wa,
    input wire [31:0] hiwd_rf,
    input wire [31:0] lowd_rf,
    input wire [31:0] alu_out,
    input wire [31:0] wd_rf,
    input wire [31:0] sext_imm,
    input wire [31:0] rd2_rf,
    input wire [31:0] rd1_rf,
    input wire [31:0] pc_plus4,
    input wire [31:0] instr,

    // -----------------------
    // Control inputs
    // -----------------------
    input wire       hilo_we,
    input wire [1:0] reg_dst,
    input wire       alu_src,
    input wire [2:0] alu_ctrl,
    input wire [1:0] rf_awd_src,
    input wire       we_dm,
    input wire [1:0] dm2reg,
    input wire       we_reg,
    input wire       jump,
    input wire       j_src,
    input wire       branch,

    // -----------------------
    // Hazard inputs
    // -----------------------
    input wire       stall_d,
    input wire       forward_ad,
    input wire       forward_bd,
    input wire       flush_e,
    input wire [1:0] forward_ae,
    input wire [1:0] forward_be,

    // -----------------------
    // Decode stage outputs
    // -----------------------
    // Data
    output wire [31:0] instrd,
    output wire [31:0] pc_plus4d,
    output wire [31:0] rd1_rfd,
    // Control
    output wire pc_src,

    // -----------------------
    // Execute stage outputs
    // -----------------------
    // Data
    output wire [31:0] sext_imme,
    output wire [ 4:0] rse,
    output wire [ 4:0] rte,
    output wire [ 4:0] rde,
    output wire [ 4:0] shamte,
    output wire [31:0] alu_pae,
    output wire [31:0] wd_dme,
    // Control
    output wire        we_rege,
    output wire [ 1:0] dm2rege,
    output wire [ 2:0] alu_ctrle,
    output wire        alu_srce,
    output wire [ 1:0] reg_dste,
    output wire        hilo_wee,

    // -----------------------
    // Memory stage outputs
    // -----------------------
    // Data
    output wire [31:0] alu_outm,
    output wire [31:0] lowd_rfm,
    output wire [31:0] hiwd_rfm,
    output wire [ 4:0] rf_wam,
    output wire [31:0] wd_dmm,
    // Control
    output wire        we_regm,
    output wire [ 1:0] dm2regm,
    output wire        we_dmm,
    output wire [ 1:0] rf_awd_srcm,

    // -----------------------
    // Writeback stage outputs
    // -----------------------
    // Data
    output wire [31:0] rd_dmw,
    output wire [31:0] awd_rfw,
    output wire [ 4:0] rf_waw,
    output wire [31:0] pc_plus4w,
    // Control
    output wire        we_regw,
    output wire [ 1:0] dm2regw
);
  id_pipe_t id_next, id_current;
  exe_pipe_t exe_next, exe_current;
  mem_pipe_t mem_next, mem_current;
  wb_pipe_t wb_next, wb_current;

  logic [$bits(id_pipe_t)-1:0] id_next_flat, id_current_flat;
  logic [$bits(exe_pipe_t)-1:0] exe_next_flat, exe_current_flat;
  logic [$bits(mem_pipe_t)-1:0] mem_next_flat, mem_current_flat;
  logic [$bits(wb_pipe_t)-1:0] wb_next_flat, wb_current_flat;

  wire        we_dme;
  wire [31:0] rd2_rfd;
  wire        cmp_out;
  wire [ 1:0] rf_awd_srce;
  wire [31:0] pc_plus4e;
  wire [31:0] rd1_rfe;
  wire [31:0] rd2_rfe;
  wire [31:0] pc_plus4m;

  // ------------------------
  // Decode stage
  // ------------------------
  always_comb begin
    id_next.instr    = instr;  // 32b
    id_next.pc_plus4 = pc_plus4;  // 32b
  end
  assign instrd    = id_current.instr;
  assign pc_plus4d = id_current.pc_plus4;
  assign cmp_out   = rd1_rfd == rd2_rfd;
  assign pc_src    = branch && cmp_out;

  assign id_next_flat = id_next;
  assign id_current   = id_current_flat;

  dreg #($bits(
      id_pipe_t
  )) id (
      .en (!stall_d),
      .rst(rst),
      .clr(jump | j_src | pc_src),
      .clk(clk),
      .d  (id_next_flat),
      .q  (id_current_flat)
  );
  mux2 #(32) rd1_rf_mux (
      .sel(forward_ad),
      .a  (rd1_rf),
      .b  (alu_outm),
      .y  (rd1_rfd)
  );
  mux2 #(32) rd2_rf_mux (
      .sel(forward_bd),
      .a  (rd2_rf),
      .b  (alu_outm),
      .y  (rd2_rfd)
  );

  // ------------------------
  // Execute stage
  // ------------------------
  always_comb begin
    exe_next.we_reg     = we_reg;  // 1b
    exe_next.dm2reg     = dm2reg;  // 2b
    exe_next.we_dm      = we_dm;  // 1b
    exe_next.rf_awd_src = rf_awd_src;  // 2b
    exe_next.alu_ctrl   = alu_ctrl;  // 3b
    exe_next.alu_src    = alu_src;  // 1b
    exe_next.reg_dst    = reg_dst;  // 2b
    exe_next.hilo_we    = hilo_we;  // 1b
    exe_next.sext_imm   = sext_imm;  // 32b
    exe_next.rd1_rf     = rd1_rfd;  // 32b
    exe_next.rd2_rf     = rd2_rfd;  // 32b
    exe_next.rs         = instrd[25:21];  // 5b
    exe_next.rt         = instrd[20:16];  // 5b
    exe_next.rd         = instrd[15:11];  // 5b
    exe_next.shamt      = instrd[10:6];  // 5b
    exe_next.pc_plus4   = pc_plus4d;  // 32b
  end
  assign we_rege     = exe_current.we_reg;
  assign dm2rege     = exe_current.dm2reg;
  assign we_dme      = exe_current.we_dm;
  assign rf_awd_srce = exe_current.rf_awd_src;
  assign alu_ctrle   = exe_current.alu_ctrl;
  assign alu_srce    = exe_current.alu_src;
  assign reg_dste    = exe_current.reg_dst;
  assign hilo_wee    = exe_current.hilo_we;
  assign sext_imme   = exe_current.sext_imm;
  assign rd1_rfe     = exe_current.rd1_rf;
  assign rd2_rfe     = exe_current.rd2_rf;
  assign rse         = exe_current.rs;
  assign rte         = exe_current.rt;
  assign rde         = exe_current.rd;
  assign shamte      = exe_current.shamt;
  assign pc_plus4e   = exe_current.pc_plus4;

  assign exe_next_flat = exe_next;
  assign exe_current   = exe_current_flat;

  dreg #($bits(
      exe_pipe_t
  )) exe (
      .en (1'b1),
      .rst(rst),
      .clr(flush_e),
      .clk(clk),
      .d  (exe_next_flat),
      .q  (exe_current_flat)
  );
  mux3 #(32) rd1_rfe_mux (
      .sel(forward_ae),
      .a  (rd1_rfe),
      .b  (wd_rf),
      .c  (alu_outm),
      .y  (alu_pae)
  );
  mux3 #(32) rd2_rfe_mux (
      .sel(forward_be),
      .a  (rd2_rfe),
      .b  (wd_rf),
      .c  (alu_outm),
      .y  (wd_dme)
  );

  // ------------------------
  // Memory stage
  // ------------------------
  always_comb begin
    mem_next.alu_out    = alu_out;  // 32b
    mem_next.lowd_rf    = lowd_rf;  // 32b
    mem_next.hiwd_rf    = hiwd_rf;  // 32b
    mem_next.rf_wa      = rf_wa;  // 5b
    mem_next.we_reg     = we_rege;  // 1b
    mem_next.dm2reg     = dm2rege;  // 2b
    mem_next.we_dm      = we_dme;  // 1b
    mem_next.rf_awd_src = rf_awd_srce;  // 2b
    mem_next.pc_plus4   = pc_plus4e;  // 32b
    mem_next.wd_dm      = wd_dme;  // 32b
  end
  assign alu_outm    = mem_current.alu_out;
  assign lowd_rfm    = mem_current.lowd_rf;
  assign hiwd_rfm    = mem_current.hiwd_rf;
  assign rf_wam      = mem_current.rf_wa;
  assign we_regm     = mem_current.we_reg;
  assign dm2regm     = mem_current.dm2reg;
  assign we_dmm      = mem_current.we_dm;
  assign rf_awd_srcm = mem_current.rf_awd_src;
  assign wd_dmm      = mem_current.wd_dm;
  assign pc_plus4m   = mem_current.pc_plus4;

  assign mem_next_flat = mem_next;
  assign mem_current   = mem_current_flat;

  dreg #($bits(
      mem_pipe_t
  )) mem (
      .en (1'b1),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .d  (mem_next_flat),
      .q  (mem_current_flat)
  );

  // ------------------------
  // Writeback stage
  // ------------------------
  always_comb begin
    wb_next.rd_dm    = rd_dm;  // 32b
    wb_next.awd_rf   = awd_rf;  // 32b
    wb_next.we_reg   = we_regm;  // 1b
    wb_next.dm2reg   = dm2regm;  // 2b
    wb_next.rf_wa    = rf_wam;  // 5b
    wb_next.pc_plus4 = pc_plus4m;  // 32b
  end
  assign rd_dmw    = wb_current.rd_dm;
  assign awd_rfw   = wb_current.awd_rf;
  assign we_regw   = wb_current.we_reg;
  assign dm2regw   = wb_current.dm2reg;
  assign rf_waw    = wb_current.rf_wa;
  assign pc_plus4w = wb_current.pc_plus4;

  assign wb_next_flat = wb_next;
  assign wb_current   = wb_current_flat;

  dreg #($bits(
      wb_pipe_t
  )) wb (
      .en (1'b1),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .d  (wb_next_flat),
      .q  (wb_current_flat)
  );


`ifndef SYNTHESIS
  always @(rst) begin
    $display("%t: pipeline rst=%b", $time, rst);
  end
  always @(jump) begin
    $display("%t: pipeline jump=%b", $time, jump);
  end
  always @(j_src) begin
    $display("%t: pipeline j_src=%b", $time, j_src);
  end
  always @(pc_src) begin
    $display("%t: pipeline pc_src=%b", $time, pc_src);
  end
  always @(rst | jump | j_src | pc_src) begin
    $display("%t: id dreg instance rst=%b", $time, rst | jump | j_src | pc_src);
  end
`endif
endmodule
