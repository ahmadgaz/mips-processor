module pipeline (
    input wire clk,
    input wire rst,

    // -----------------------
    // Data inputs
    // -----------------------
    input wire [31:0] instr,
    input wire [31:0] pc_plus4,
    input wire [31:0] rd1_rf,
    input wire [31:0] rd2_rf,
    input wire [31:0] sext_imm,
    input wire [31:0] wd_rf,
    input wire [31:0] alu_out,
    input wire [31:0] lowd_rf,
    input wire [31:0] hiwd_rf,
    input wire [ 4:0] rf_wa,
    input wire [31:0] rd_dm,
    input wire [31:0] awd_rf,

    // -----------------------
    // Control inputs
    // -----------------------
    input wire       we_reg,
    input wire [1:0] dm2reg,
    input wire       we_dm,
    input wire [1:0] rf_awd_src,
    input wire [2:0] alu_ctrl,
    input wire       alu_src,
    input wire [1:0] reg_dst,
    input wire       hilo_we,
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
  wire [63:0] id_next, id_current;
  wire [160:0] exe_next, exe_current;
  wire [170:0] mem_next, mem_current;
  wire [103:0] wb_next, wb_current;

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
  assign id_next = {
    instr,  // 32b
    pc_plus4  // 32b
  };
  assign {instrd, pc_plus4d} = id_current;
  assign cmp_out = rd1_rfd == rd2_rfd;
  assign pc_src = branch && cmp_out;

  dreg #(64) id (
      .d  (id_next),
      .en (~stall_d),
      .clr(jump | j_src | pc_src),
      .rst(rst),
      .clk(clk),
      .q  (id_current)
  );
  mux2 #(32) rd1_rf_mux (
      .a  (rd1_rf),
      .b  (alu_outm),
      .sel(forward_ad),
      .y  (rd1_rfd)
  );
  mux2 #(32) rd2_rf_mux (
      .a  (rd2_rf),
      .b  (alu_outm),
      .sel(forward_bd),
      .y  (rd2_rfd)
  );

  // ------------------------
  // Execute stage
  // ------------------------
  assign exe_next = {
    we_reg,  // 1b
    dm2reg,  // 2b
    we_dm,  // 1b
    rf_awd_src,  // 2b
    alu_ctrl,  // 3b
    alu_src,  // 1b
    reg_dst,  // 2b
    hilo_we,  // 1b
    rd1_rfd,  // 32b
    rd2_rfd,  // 32b
    sext_imm,  // 32b
    instrd[25:21],  // 5b
    instrd[20:16],  // 5b
    instrd[15:11],  // 5b
    instrd[10:6],  // 5b
    pc_plus4d  // 32b
  };
  assign {
    we_rege,
    dm2rege,
    we_dme,
    rf_awd_srce,
    alu_ctrle,
    alu_srce,
    reg_dste,
    hilo_wee,
    rd1_rfe,
    rd2_rfe,
    sext_imme,
    rse,
    rte,
    rde,
    shamte,
    pc_plus4e
  } = exe_current;

  dreg #(161) exe (
      .d  (exe_next),
      .en (1'b1),
      .clr(flush_e),
      .rst(rst),
      .clk(clk),
      .q  (exe_current)
  );
  mux3 #(32) rd1_rfe_mux (
      .a  (rd1_rfe),
      .b  (wd_rf),
      .c  (alu_outm),
      .sel(forward_ae),
      .y  (alu_pae)
  );
  mux3 #(32) rd2_rfe_mux (
      .a  (rd2_rfe),
      .b  (wd_rf),
      .c  (alu_outm),
      .sel(forward_be),
      .y  (wd_dme)
  );

  // ------------------------
  // Memory stage
  // ------------------------
  assign mem_next = {
    alu_out,  // 32b
    lowd_rf,  // 32b
    hiwd_rf,  // 32b
    rf_wa,  // 5b
    we_rege,  // 1b
    dm2rege,  // 2b
    we_dme,  // 1b
    rf_awd_srce,  // 2b
    wd_dme,  // 32b
    pc_plus4m  // 32b
  };
  assign {
    alu_outm,
    lowd_rfm,
    hiwd_rfm,
    rf_wam,
    we_regm,
    dm2regm,
    we_dmm,
    rf_awd_srcm,
    wd_dmm,
    pc_plus4m
  } = mem_current;

  dreg #(171) mem (
      .d  (mem_next),
      .en (1'b1),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .q  (mem_current)
  );

  // ------------------------
  // Writeback stage
  // ------------------------
  assign wb_next = {
    rd_dm,  // 32b
    awd_rf,  // 32b
    we_regm,  // 1b
    dm2regm,  // 2b
    rf_wam,  // 5b
    pc_plus4e  // 32b
  };
  assign {rd_dmw, awd_rfw, we_regw, dm2regw, rf_waw, pc_plus4w} = wb_current;
  dreg #(104) wb (
      .d  (wb_next),
      .en (1'b1),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .q  (wb_current)
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
