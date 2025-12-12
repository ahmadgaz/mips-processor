module hazardunit (
    input wire [4:0] rse,
    input wire [4:0] rte,
    input wire [4:0] rf_wae,
    input wire [4:0] rf_wam,
    input wire [4:0] rf_waw,
    input wire       we_rege,
    input wire       we_regm,
    input wire       we_regw,
    input wire       lw_dm2rege,
    input wire [1:0] dm2regm,
    input wire [ 4:0] rsd,
    input wire [ 4:0] rtd,
    input wire        branch,
    input wire        j_src,

    output wire       stall_f,
    output wire [1:0] forward_ae,
    output wire [1:0] forward_be,
    output wire       forward_ad,
    output wire       forward_bd,
    output wire       stall_d,
    output wire       flush_e
);
  assign forward_ae =  // EX stage needs forwarding from MEM and WB
      ((rse != 5'd0) && (rse == rf_wam) && we_regm) ? 2'b10 :  // Logic
      ((rse != 5'd0) && (rse == rf_waw) && we_regw) ? 2'b01 :  // Logic || Memory
      2'b00;

  assign forward_be =
        ((rte != 5'd0) && (rte == rf_wam) && we_regm) ? 2'b10 :
        ((rte != 5'd0) && (rte == rf_waw) && we_regw) ? 2'b01 :
        2'b00;

  assign forward_ad =  // DE stage needs forwarding from MEM (is already reading WB regs)
      (rsd != 5'd0) && (rsd == rf_wam) && we_regm;

  assign forward_bd = (rtd != 5'd0) && (rtd == rf_wam) && we_regm;

  wire lwstall = // Instrs need one stage of seperation
    ((rsd == rte) || (rtd == rte)) && lw_dm2rege;

  wire branchstall =
        (branch && we_rege && // Logic needs one stage of seperation -> forwarding
            ((rsd == rf_wae) || (rtd == rf_wae))) ||
        (branch && (dm2regm[0] || dm2regm[1]) && // Memory needs two stages of seperation
            ((rsd == rf_wam) || (rtd == rf_wam)));

  wire jrstall =
        (j_src && we_rege && (rsd == rf_wae)) ||
        (j_src && (dm2regm[0] || dm2regm[1]) && (rsd == rf_wam));

  wire stall_all = lwstall || branchstall || jrstall;

  assign stall_f = stall_all;
  assign stall_d = stall_all;
  assign flush_e = stall_all;

endmodule
