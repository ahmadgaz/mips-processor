package pipeline_types_pkg;
  typedef struct packed {
    logic [31:0] instr;
    logic [31:0] pc_plus4;
  } id_pipe_t;

  typedef struct packed {
    logic        we_reg;
    logic [1:0]  dm2reg;
    logic        we_dm;
    logic [1:0]  rf_awd_src;
    logic [2:0]  alu_ctrl;
    logic        alu_src;
    logic [1:0]  reg_dst;
    logic        hilo_we;
    logic [31:0] rd1_rf;
    logic [31:0] rd2_rf;
    logic [31:0] sext_imm;
    logic [4:0]  rs;
    logic [4:0]  rt;
    logic [4:0]  rd;
    logic [4:0]  shamt;
    logic [31:0] pc_plus4;
  } exe_pipe_t;

  typedef struct packed {
    logic [31:0] alu_out;
    logic [31:0] lowd_rf;
    logic [31:0] hiwd_rf;
    logic [4:0]  rf_wa;
    logic        we_reg;
    logic [1:0]  dm2reg;
    logic        we_dm;
    logic [1:0]  rf_awd_src;
    logic [31:0] wd_dm;
    logic [31:0] pc_plus4;
  } mem_pipe_t;

  typedef struct packed {
    logic [31:0] rd_dm;
    logic [31:0] awd_rf;
    logic        we_reg;
    logic [1:0]  dm2reg;
    logic [1:0]  rf_wa;
    logic [31:0] pc_plus4;
  } wb_pipe_t;
endpackage
