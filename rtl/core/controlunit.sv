module controlunit (
    // Main decoder signals
    input  wire [5:0] opcode,
    output wire       we_reg,
    output wire [1:0] reg_dst,
    output wire       alu_src,
    output wire       branch,
    output wire       we_dm,
    output wire [1:0] dm2reg,
    output wire       jump,

    // Auxillary decoder signals
    input  wire [5:0] funct,
    output wire [2:0] alu_ctrl,
    output wire [1:0] rf_awd_src,
    output wire       hilo_we,
    output wire       j_src
);
  wire [1:0] alu_op;

  maindec md (
      .opcode (opcode),
      .we_reg (we_reg),
      .reg_dst(reg_dst),
      .alu_src(alu_src),
      .branch (branch),
      .we_dm  (we_dm),
      .dm2reg (dm2reg),
      .alu_op (alu_op),
      .jump   (jump)
  );

  auxdec ad (
      .alu_op    (alu_op),
      .funct     (funct),
      .alu_ctrl  (alu_ctrl),
      .rf_awd_src(rf_awd_src),
      .hilo_we   (hilo_we),
      .j_src     (j_src)
  );
endmodule

