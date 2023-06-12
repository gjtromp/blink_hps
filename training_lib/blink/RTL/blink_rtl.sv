module blink (
    input logic clk50m,
    input logic reset_n,
    output logic led,
    output   [14: 0]    HPS_DDR3_ADDR,
    output   [ 2: 0]    HPS_DDR3_BA,
    output              HPS_DDR3_CAS_N,
    output              HPS_DDR3_CK_N,
    output              HPS_DDR3_CK_P,
    output              HPS_DDR3_CKE,
    output              HPS_DDR3_CS_N,
    output   [ 3: 0]    HPS_DDR3_DM,
    inout    [31: 0]    HPS_DDR3_DQ,
    inout    [ 3: 0]    HPS_DDR3_DQS_N,
    inout    [ 3: 0]    HPS_DDR3_DQS_P,
    output              HPS_DDR3_ODT,
    output              HPS_DDR3_RAS_N,
    output              HPS_DDR3_RESET_N,
    input               HPS_DDR3_RZQ,
    output              HPS_DDR3_WE_N

);

wire [15:0]  apb_m0_paddr;            //          apb_m0.paddr
wire        apb_m0_psel;             //                .psel
wire        apb_m0_penable;          //                .penable
wire        apb_m0_pwrite;           //                .pwrite
wire [31:0] apb_m0_pwdata;           //                .pwdata
wire  [31:0] apb_m0_prdata;           //                .prdata
wire         apb_m0_pready;           //                .pready
wire        hps_reset_n;

soc_system u_soc_system_0 (
		.apb_m0_paddr(apb_m0_paddr),            //          apb_m0.paddr
		.apb_m0_psel(apb_m0_psel),             //                .psel
		.apb_m0_penable(apb_m0_penable),          //                .penable
		.apb_m0_pwrite(apb_m0_pwrite),           //                .pwrite
		.apb_m0_pwdata(apb_m0_pwdata),           //                .pwdata
		.apb_m0_prdata(apb_m0_prdata),           //                .prdata
		.apb_m0_pready(apb_m0_pready),           //                .pready
		.clk_clk(clk50m),                 //             clk.clk
		.hps_0_h2f_reset_reset_n(hps_reset_n), // hps_0_h2f_reset.reset_n
      .memory_mem_a(HPS_DDR3_ADDR),                                //                         memory.mem_a
      .memory_mem_ba(HPS_DDR3_BA),                                 //                               .mem_ba
      .memory_mem_ck(HPS_DDR3_CK_P),                               //                               .mem_ck
      .memory_mem_ck_n(HPS_DDR3_CK_N),                             //                               .mem_ck_n
      .memory_mem_cke(HPS_DDR3_CKE),                               //                               .mem_cke
      .memory_mem_cs_n(HPS_DDR3_CS_N),                             //                               .mem_cs_n
      .memory_mem_ras_n(HPS_DDR3_RAS_N),                           //                               .mem_ras_n
      .memory_mem_cas_n(HPS_DDR3_CAS_N),                           //                               .mem_cas_n
      .memory_mem_we_n(HPS_DDR3_WE_N),                             //                               .mem_we_n
      .memory_mem_reset_n(HPS_DDR3_RESET_N),                       //                               .mem_reset_n
      .memory_mem_dq(HPS_DDR3_DQ),                                 //                               .mem_dq
      .memory_mem_dqs(HPS_DDR3_DQS_P),                             //                               .mem_dqs
      .memory_mem_dqs_n(HPS_DDR3_DQS_N),                           //                               .mem_dqs_n
      .memory_mem_odt(HPS_DDR3_ODT),                               //                               .mem_odt
      .memory_mem_dm(HPS_DDR3_DM),                                 //                               .mem_dm
      .memory_oct_rzqin(HPS_DDR3_RZQ),                             //                               .oct_rzqin
		.reset_reset_n(reset_n)            //           reset.reset_n
	);

logic [27:0] counter;
logic ctrl;
logic [7:0] led_output;

always @(posedge clk50m or negedge reset_n)
begin
    if (~reset_n)
	 begin
	     ctrl <= 1'b0;
		  led_output <= 0;
	 end
	 else
	 begin
	     if (apb_m0_psel & apb_m0_penable & apb_m0_pwrite)
		  begin
	         case(apb_m0_paddr[2])
		      0: ctrl <= apb_m0_pwdata[0];
		      1: led_output <= apb_m0_pwdata[7:0];
		      endcase
		  end
	 end
end

always @*
begin
    case (apb_m0_paddr[2])
	 0: apb_m0_prdata <= {15'b0, ctrl};
	 1: apb_m0_prdata <= led_output;
    default: apb_m0_prdata <= 'h12345678;
	 endcase
end

assign apb_m0_pready = 1'b1;
logic [7:0] led_i;

always @(posedge clk50m or negedge reset_n) begin
    if (~reset_n)
    begin
        counter <= 0;
	led_i <= 1'b0;
    end
    else
    begin
        if (counter == 0) begin
            counter <= 24999999;
            led_i <= ~led_i;
        end else begin
            counter <= counter - 1;
        end
    end
end

always @*
begin
    if (~ctrl)
	     led = led_i;
	 else
		  led = led_output;
end

endmodule : blink
