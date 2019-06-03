`timescale 1 ps / 1 ps
`include "clocking.vh"
`include "constants.vh"

module rocketchip_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,

    clk, // 50MHz
    uart_tx,
    uart_rx,

    // router
    reset_n_in,
    rgmii1_rd,
    rgmii1_rx_ctl,
    rgmii1_rxc,
    rgmii1_td,
    rgmii1_tx_ctl,
    rgmii1_txc,

    rgmii2_rd,
    rgmii2_rx_ctl,
    rgmii2_rxc,
    rgmii2_td,
    rgmii2_tx_ctl,
    rgmii2_txc
);

  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;

  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;

  input clk;

  output uart_tx;
  input uart_rx;
  
  input reset_n_in;

  input [3:0]rgmii1_rd;
  input rgmii1_rx_ctl;
  input rgmii1_rxc;
  output [3:0]rgmii1_td;
  output rgmii1_tx_ctl;
  output rgmii1_txc;

  input [3:0]rgmii2_rd;
  input rgmii2_rx_ctl;
  input rgmii2_rxc;
  output [3:0]rgmii2_td;
  output rgmii2_tx_ctl;
  output rgmii2_txc;

  wire FCLK_RESET0_N;
  
  wire [31:0]M_AXI_araddr;
  wire [1:0]M_AXI_arburst;
  wire [7:0]M_AXI_arlen;
  wire M_AXI_arready;
  wire [2:0]M_AXI_arsize;
  wire M_AXI_arvalid;
  wire [31:0]M_AXI_awaddr;
  wire [1:0]M_AXI_awburst;
  wire [7:0]M_AXI_awlen;
  wire [3:0]M_AXI_wstrb;
  wire M_AXI_awready;
  wire [2:0]M_AXI_awsize;
  wire M_AXI_awvalid;
  wire M_AXI_bready;
  wire M_AXI_bvalid;
  wire [31:0]M_AXI_rdata;
  wire M_AXI_rlast;
  wire M_AXI_rready;
  wire M_AXI_rvalid;
  wire [31:0]M_AXI_wdata;
  wire M_AXI_wlast;
  wire M_AXI_wready;
  wire M_AXI_wvalid;
  wire [11:0] M_AXI_arid, M_AXI_awid; // outputs from ARM core
  wire [11:0] M_AXI_bid, M_AXI_rid;   // inputs to ARM core

  wire S_AXI_arready;
  wire S_AXI_arvalid;
  wire [31:0] S_AXI_araddr;
  wire [5:0]  S_AXI_arid;
  wire [2:0]  S_AXI_arsize;
  wire [7:0]  S_AXI_arlen;
  wire [1:0]  S_AXI_arburst;
  wire S_AXI_arlock;
  wire [3:0]  S_AXI_arcache;
  wire [2:0]  S_AXI_arprot;
  wire [3:0]  S_AXI_arqos;
  //wire [3:0]  S_AXI_arregion;

  wire S_AXI_awready;
  wire S_AXI_awvalid;
  wire [31:0] S_AXI_awaddr;
  wire [5:0]  S_AXI_awid;
  wire [2:0]  S_AXI_awsize;
  wire [7:0]  S_AXI_awlen;
  wire [1:0]  S_AXI_awburst;
  wire S_AXI_awlock;
  wire [3:0]  S_AXI_awcache;
  wire [2:0]  S_AXI_awprot;
  wire [3:0]  S_AXI_awqos;
  //wire [3:0]  S_AXI_awregion;

  wire S_AXI_wready;
  wire S_AXI_wvalid;
  wire [7:0]  S_AXI_wstrb;
  wire [63:0] S_AXI_wdata;
  wire S_AXI_wlast;

  wire S_AXI_bready;
  wire S_AXI_bvalid;
  wire [1:0] S_AXI_bresp;
  wire [5:0] S_AXI_bid;

  wire S_AXI_rready;
  wire S_AXI_rvalid;
  wire [1:0]  S_AXI_rresp;
  wire [5:0]  S_AXI_rid;
  wire [63:0] S_AXI_rdata;
  wire S_AXI_rlast;
  
  wire S_AXI_MMIO_arready;
  wire S_AXI_MMIO_arvalid;
  wire [31:0] S_AXI_MMIO_araddr;
  wire [5:0]  S_AXI_MMIO_arid;
  wire [2:0]  S_AXI_MMIO_arsize;
  wire [7:0]  S_AXI_MMIO_arlen;
  wire [1:0]  S_AXI_MMIO_arburst;
  wire S_AXI_MMIO_arlock;
  wire [3:0]  S_AXI_MMIO_arcache;
  wire [2:0]  S_AXI_MMIO_arprot;
  wire [3:0]  S_AXI_MMIO_arqos;
  //wire [3:0]  S_AXI_MMIO_arregion;

  wire S_AXI_MMIO_awready;
  wire S_AXI_MMIO_awvalid;
  wire [31:0] S_AXI_MMIO_awaddr;
  wire [5:0]  S_AXI_MMIO_awid;
  wire [2:0]  S_AXI_MMIO_awsize;
  wire [7:0]  S_AXI_MMIO_awlen;
  wire [1:0]  S_AXI_MMIO_awburst;
  wire S_AXI_MMIO_awlock;
  wire [3:0]  S_AXI_MMIO_awcache;
  wire [2:0]  S_AXI_MMIO_awprot;
  wire [3:0]  S_AXI_MMIO_awqos;
  //wire [3:0]  S_AXI_MMIO_awregion;

  wire S_AXI_MMIO_wready;
  wire S_AXI_MMIO_wvalid;
  wire [7:0]  S_AXI_MMIO_wstrb;
  wire [63:0] S_AXI_MMIO_wdata;
  wire S_AXI_MMIO_wlast;

  wire S_AXI_MMIO_bready;
  wire S_AXI_MMIO_bvalid;
  wire [1:0] S_AXI_MMIO_bresp;
  wire [5:0] S_AXI_MMIO_bid;

  wire S_AXI_MMIO_rready;
  wire S_AXI_MMIO_rvalid;
  wire [1:0]  S_AXI_MMIO_rresp;
  wire [5:0]  S_AXI_MMIO_rid;
  wire [63:0] S_AXI_MMIO_rdata;
  wire S_AXI_MMIO_rlast;

  wire reset, reset_cpu;
  wire host_clk; // 25MHz
  wire sys_clk; // 50MHz
  wire gclk_i, gclk_fbout, host_clk_i, mmcm_locked;

  wire [1:0] interrupts;
  
  assign interrupts[1] = 0;

  wire [7:0] AXI_STR_RXD_0_tdata;
  wire AXI_STR_RXD_0_tlast;
  wire AXI_STR_RXD_0_tready;
  wire AXI_STR_RXD_0_tvalid;

  wire [7:0] AXI_STR_TXD_0_tdata;
  wire AXI_STR_TXD_0_tlast;
  wire AXI_STR_TXD_0_tready;
  wire AXI_STR_TXD_0_tvalid;

  wire [`PORT_OS_COUNT-1:0][`STATS_WIDTH-1:0] stats_rx_packets;
  wire [`PORT_OS_COUNT-1:0][`STATS_WIDTH-1:0] stats_rx_bytes;
  wire [`PORT_OS_COUNT-1:0][`STATS_WIDTH-1:0] stats_tx_packets;
  wire [`PORT_OS_COUNT-1:0][`STATS_WIDTH-1:0] stats_tx_bytes;

  wire [`STATS_WIDTH-1:0] stats_total_rx_packets;
  wire [`STATS_WIDTH-1:0] stats_total_rx_bytes;
  wire [`STATS_WIDTH-1:0] stats_total_tx_packets;
  wire [`STATS_WIDTH-1:0] stats_total_tx_bytes;

  assign stats_total_rx_packets = stats_rx_packets[0] + stats_rx_packets[1];
  assign stats_total_rx_bytes = stats_rx_bytes[0] + stats_rx_bytes[1];
  assign stats_total_tx_packets = stats_tx_packets[0] + stats_tx_packets[1];
  assign stats_total_tx_bytes = stats_tx_bytes[0] + stats_tx_bytes[1];

  // accessing routing table
  wire os_clk;
  wire [16-1:0] os_addr;
  wire [`ROUTING_TABLE_ENTRY_WIDTH-1:0] os_din;
  wire [`ROUTING_TABLE_ENTRY_WIDTH-1:0] os_dout;
  wire [(`ROUTING_TABLE_ENTRY_WIDTH)/`BYTE_WIDTH-1:0] os_wea;
  wire os_rst;
  wire os_en;

  system system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_RESET0_N(FCLK_RESET0_N),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
	
        .AXI_STR_RXD_0_tdata(AXI_STR_RXD_0_tdata),
        .AXI_STR_RXD_0_tready(AXI_STR_RXD_0_tready),
        .AXI_STR_RXD_0_tvalid(AXI_STR_RXD_0_tvalid),
        .AXI_STR_RXD_0_tlast(AXI_STR_RXD_0_tlast),

        .AXI_STR_TXD_0_tdata(AXI_STR_TXD_0_tdata),
        .AXI_STR_TXD_0_tready(AXI_STR_TXD_0_tready),
        .AXI_STR_TXD_0_tvalid(AXI_STR_TXD_0_tvalid),
        .AXI_STR_TXD_0_tlast(AXI_STR_TXD_0_tlast),


        // master AXI interface (zynq = master, fpga = slave)
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arburst(M_AXI_arburst), // burst type
        .M_AXI_arcache(),
        .M_AXI_arid(M_AXI_arid),
        .M_AXI_arlen(M_AXI_arlen), // burst length (#transfers)
        .M_AXI_arlock(),
        .M_AXI_arprot(),
        .M_AXI_arqos(),
        .M_AXI_arready(M_AXI_arready),
        .M_AXI_arregion(),
        .M_AXI_arsize(M_AXI_arsize), // burst size (bits/transfer)
        .M_AXI_arvalid(M_AXI_arvalid),
        //
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awcache(),
        .M_AXI_awid(M_AXI_awid),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awlock(),
        .M_AXI_awprot(),
        .M_AXI_awqos(),
        .M_AXI_awready(M_AXI_awready),
        .M_AXI_awregion(),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awvalid(M_AXI_awvalid),
        //
        .M_AXI_bid(M_AXI_bid),
        .M_AXI_bready(M_AXI_bready),
        .M_AXI_bresp(2'b00),
        .M_AXI_bvalid(M_AXI_bvalid),
        //
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rid(M_AXI_rid),
        .M_AXI_rlast(M_AXI_rlast),
        .M_AXI_rready(M_AXI_rready),
        .M_AXI_rresp(),
        .M_AXI_rvalid(M_AXI_rvalid),
        //
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wlast(M_AXI_wlast),
        .M_AXI_wready(M_AXI_wready),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wvalid(M_AXI_wvalid),

        // slave AXI interface (fpga = master, zynq = slave) 
        // connected directly to DDR controller to handle test chip mem
        .S_AXI_araddr(S_AXI_araddr),
        .S_AXI_arburst(S_AXI_arburst),
        .S_AXI_arcache(S_AXI_arcache),
        .S_AXI_arid(S_AXI_arid),
        .S_AXI_arlen(S_AXI_arlen),
        .S_AXI_arlock(S_AXI_arlock),
        .S_AXI_arprot(S_AXI_arprot),
        .S_AXI_arqos(S_AXI_arqos),
        .S_AXI_arready(S_AXI_arready),
        .S_AXI_arregion(4'b0),
        .S_AXI_arsize(S_AXI_arsize),
        .S_AXI_arvalid(S_AXI_arvalid),
        //
        .S_AXI_awaddr(S_AXI_awaddr),
        .S_AXI_awburst(S_AXI_awburst),
        .S_AXI_awcache(S_AXI_awcache),
        .S_AXI_awid(S_AXI_awid),
        .S_AXI_awlen(S_AXI_awlen),
        .S_AXI_awlock(S_AXI_awlock),
        .S_AXI_awprot(S_AXI_awprot),
        .S_AXI_awqos(S_AXI_awqos),
        .S_AXI_awready(S_AXI_awready),
        .S_AXI_awregion(4'b0),
        .S_AXI_awsize(S_AXI_awsize),
        .S_AXI_awvalid(S_AXI_awvalid),
        //
        .S_AXI_bid(S_AXI_bid),
        .S_AXI_bready(S_AXI_bready),
        .S_AXI_bresp(S_AXI_bresp),
        .S_AXI_bvalid(S_AXI_bvalid),
        //
        .S_AXI_rid(S_AXI_rid),
        .S_AXI_rdata(S_AXI_rdata),
        .S_AXI_rlast(S_AXI_rlast),
        .S_AXI_rready(S_AXI_rready),
        .S_AXI_rresp(S_AXI_rresp),
        .S_AXI_rvalid(S_AXI_rvalid),
        //
        .S_AXI_wdata(S_AXI_wdata),
        .S_AXI_wlast(S_AXI_wlast),
        .S_AXI_wready(S_AXI_wready),
        .S_AXI_wstrb(S_AXI_wstrb),
        .S_AXI_wvalid(S_AXI_wvalid),
	
        // slave AXI MMIO interface
        // connected to peripherals for test chip
        .S_AXI_MMIO_araddr(S_AXI_MMIO_araddr),
        .S_AXI_MMIO_arburst(S_AXI_MMIO_arburst),
        .S_AXI_MMIO_arcache(S_AXI_MMIO_arcache),
        .S_AXI_MMIO_arid(S_AXI_MMIO_arid),
        .S_AXI_MMIO_arlen(S_AXI_MMIO_arlen),
        .S_AXI_MMIO_arlock(S_AXI_MMIO_arlock),
        .S_AXI_MMIO_arprot(S_AXI_MMIO_arprot),
        .S_AXI_MMIO_arqos(S_AXI_MMIO_arqos),
        .S_AXI_MMIO_arready(S_AXI_MMIO_arready),
        .S_AXI_MMIO_arregion(4'b0),
        .S_AXI_MMIO_arsize(S_AXI_MMIO_arsize),
        .S_AXI_MMIO_arvalid(S_AXI_MMIO_arvalid),
        //
        .S_AXI_MMIO_awaddr(S_AXI_MMIO_awaddr),
        .S_AXI_MMIO_awburst(S_AXI_MMIO_awburst),
        .S_AXI_MMIO_awcache(S_AXI_MMIO_awcache),
        .S_AXI_MMIO_awid(S_AXI_MMIO_awid),
        .S_AXI_MMIO_awlen(S_AXI_MMIO_awlen),
        .S_AXI_MMIO_awlock(S_AXI_MMIO_awlock),
        .S_AXI_MMIO_awprot(S_AXI_MMIO_awprot),
        .S_AXI_MMIO_awqos(S_AXI_MMIO_awqos),
        .S_AXI_MMIO_awready(S_AXI_MMIO_awready),
        .S_AXI_MMIO_awregion(4'b0),
        .S_AXI_MMIO_awsize(S_AXI_MMIO_awsize),
        .S_AXI_MMIO_awvalid(S_AXI_MMIO_awvalid),
        //
        .S_AXI_MMIO_bid(S_AXI_MMIO_bid),
        .S_AXI_MMIO_bready(S_AXI_MMIO_bready),
        .S_AXI_MMIO_bresp(S_AXI_MMIO_bresp),
        .S_AXI_MMIO_bvalid(S_AXI_MMIO_bvalid),
        //
        .S_AXI_MMIO_rid(S_AXI_MMIO_rid),
        .S_AXI_MMIO_rdata(S_AXI_MMIO_rdata),
        .S_AXI_MMIO_rlast(S_AXI_MMIO_rlast),
        .S_AXI_MMIO_rready(S_AXI_MMIO_rready),
        .S_AXI_MMIO_rresp(S_AXI_MMIO_rresp),
        .S_AXI_MMIO_rvalid(S_AXI_MMIO_rvalid),
        //
        .S_AXI_MMIO_wdata(S_AXI_MMIO_wdata),
        .S_AXI_MMIO_wlast(S_AXI_MMIO_wlast),
        .S_AXI_MMIO_wready(S_AXI_MMIO_wready),
        .S_AXI_MMIO_wstrb(S_AXI_MMIO_wstrb),
        .S_AXI_MMIO_wvalid(S_AXI_MMIO_wvalid),
        .UART_0_rxd(uart_rx),
        .UART_0_txd(uart_tx),
        .ext_clk_in(host_clk), // 25MHz
        .interrupts_interrupt(interrupts[0]),

        .rx_bytes_tri_i(stats_total_rx_bytes),
        .rx_packets_tri_i(stats_total_rx_packets),

        .tx_bytes_tri_i(stats_total_tx_bytes),
        .tx_packets_tri_i(stats_total_tx_packets),

        .routing_table_addr(os_addr),
        .routing_table_clk(os_clk),
        .routing_table_din(os_din),
        .routing_table_dout(os_dout),
        .routing_table_en(os_en),
        .routing_table_rst(os_rst),
        .routing_table_we(os_wea),

        .sys_clk(sys_clk)
        );

  assign reset = !FCLK_RESET0_N || !mmcm_locked;

  wire [31:0] mem_araddr;
  wire [31:0] mem_awaddr;

  // Memory given to Rocket is the upper 256 MB of the 512 MB DRAM
  assign S_AXI_araddr = {4'd1, mem_araddr[27:0]};
  assign S_AXI_awaddr = {4'd1, mem_awaddr[27:0]};

  Top top(
   .clock(host_clk), // 25MHz
   .reset(reset),

   .io_ps_axi_slave_aw_ready (M_AXI_awready),
   .io_ps_axi_slave_aw_valid (M_AXI_awvalid),
   .io_ps_axi_slave_aw_bits_addr (M_AXI_awaddr),
   .io_ps_axi_slave_aw_bits_len (M_AXI_awlen),
   .io_ps_axi_slave_aw_bits_size (M_AXI_awsize),
   .io_ps_axi_slave_aw_bits_burst (M_AXI_awburst),
   .io_ps_axi_slave_aw_bits_id (M_AXI_awid),
   .io_ps_axi_slave_aw_bits_lock (1'b0),
   .io_ps_axi_slave_aw_bits_cache (4'b0),
   .io_ps_axi_slave_aw_bits_prot (3'b0),
   .io_ps_axi_slave_aw_bits_qos (4'b0),

   .io_ps_axi_slave_ar_ready (M_AXI_arready),
   .io_ps_axi_slave_ar_valid (M_AXI_arvalid),
   .io_ps_axi_slave_ar_bits_addr (M_AXI_araddr),
   .io_ps_axi_slave_ar_bits_len (M_AXI_arlen),
   .io_ps_axi_slave_ar_bits_size (M_AXI_arsize),
   .io_ps_axi_slave_ar_bits_burst (M_AXI_arburst),
   .io_ps_axi_slave_ar_bits_id (M_AXI_arid),
   .io_ps_axi_slave_ar_bits_lock (1'b0),
   .io_ps_axi_slave_ar_bits_cache (4'b0),
   .io_ps_axi_slave_ar_bits_prot (3'b0),
   .io_ps_axi_slave_ar_bits_qos (4'b0),

   .io_ps_axi_slave_w_valid (M_AXI_wvalid),
   .io_ps_axi_slave_w_ready (M_AXI_wready),
   .io_ps_axi_slave_w_bits_data (M_AXI_wdata),
   .io_ps_axi_slave_w_bits_strb (M_AXI_wstrb),
   .io_ps_axi_slave_w_bits_last (M_AXI_wlast),

   .io_ps_axi_slave_r_valid (M_AXI_rvalid),
   .io_ps_axi_slave_r_ready (M_AXI_rready),
   .io_ps_axi_slave_r_bits_id (M_AXI_rid),
   .io_ps_axi_slave_r_bits_resp (M_AXI_rresp),
   .io_ps_axi_slave_r_bits_data (M_AXI_rdata),
   .io_ps_axi_slave_r_bits_last (M_AXI_rlast),

   .io_ps_axi_slave_b_valid (M_AXI_bvalid),
   .io_ps_axi_slave_b_ready (M_AXI_bready),
   .io_ps_axi_slave_b_bits_id (M_AXI_bid),
   .io_ps_axi_slave_b_bits_resp (M_AXI_bresp),

   .io_mem_axi_ar_valid (S_AXI_arvalid),
   .io_mem_axi_ar_ready (S_AXI_arready),
   .io_mem_axi_ar_bits_addr (mem_araddr),
   .io_mem_axi_ar_bits_id (S_AXI_arid),
   .io_mem_axi_ar_bits_size (S_AXI_arsize),
   .io_mem_axi_ar_bits_len (S_AXI_arlen),
   .io_mem_axi_ar_bits_burst (S_AXI_arburst),
   .io_mem_axi_ar_bits_cache (S_AXI_arcache),
   .io_mem_axi_ar_bits_lock (S_AXI_arlock),
   .io_mem_axi_ar_bits_prot (S_AXI_arprot),
   .io_mem_axi_ar_bits_qos (S_AXI_arqos),
   .io_mem_axi_aw_valid (S_AXI_awvalid),
   .io_mem_axi_aw_ready (S_AXI_awready),
   .io_mem_axi_aw_bits_addr (mem_awaddr),
   .io_mem_axi_aw_bits_id (S_AXI_awid),
   .io_mem_axi_aw_bits_size (S_AXI_awsize),
   .io_mem_axi_aw_bits_len (S_AXI_awlen),
   .io_mem_axi_aw_bits_burst (S_AXI_awburst),
   .io_mem_axi_aw_bits_cache (S_AXI_awcache),
   .io_mem_axi_aw_bits_lock (S_AXI_awlock),
   .io_mem_axi_aw_bits_prot (S_AXI_awprot),
   .io_mem_axi_aw_bits_qos (S_AXI_awqos),
   .io_mem_axi_w_valid (S_AXI_wvalid),
   .io_mem_axi_w_ready (S_AXI_wready),
   .io_mem_axi_w_bits_strb (S_AXI_wstrb),
   .io_mem_axi_w_bits_data (S_AXI_wdata),
   .io_mem_axi_w_bits_last (S_AXI_wlast),
   .io_mem_axi_b_valid (S_AXI_bvalid),
   .io_mem_axi_b_ready (S_AXI_bready),
   .io_mem_axi_b_bits_resp (S_AXI_bresp),
   .io_mem_axi_b_bits_id (S_AXI_bid),
   .io_mem_axi_r_valid (S_AXI_rvalid),
   .io_mem_axi_r_ready (S_AXI_rready),
   .io_mem_axi_r_bits_resp (S_AXI_rresp),
   .io_mem_axi_r_bits_id (S_AXI_rid),
   .io_mem_axi_r_bits_data (S_AXI_rdata),
   .io_mem_axi_r_bits_last (S_AXI_rlast),

   .io_mmio_axi_ar_valid (S_AXI_MMIO_arvalid),
   .io_mmio_axi_ar_ready (S_AXI_MMIO_arready),
   .io_mmio_axi_ar_bits_addr (S_AXI_MMIO_araddr),
   .io_mmio_axi_ar_bits_id (S_AXI_MMIO_arid),
   .io_mmio_axi_ar_bits_size (S_AXI_MMIO_arsize),
   .io_mmio_axi_ar_bits_len (S_AXI_MMIO_arlen),
   .io_mmio_axi_ar_bits_burst (S_AXI_MMIO_arburst),
   .io_mmio_axi_ar_bits_cache (S_AXI_MMIO_arcache),
   .io_mmio_axi_ar_bits_lock (S_AXI_MMIO_arlock),
   .io_mmio_axi_ar_bits_prot (S_AXI_MMIO_arprot),
   .io_mmio_axi_ar_bits_qos (S_AXI_MMIO_arqos),
   .io_mmio_axi_aw_valid (S_AXI_MMIO_awvalid),
   .io_mmio_axi_aw_ready (S_AXI_MMIO_awready),
   .io_mmio_axi_aw_bits_addr (S_AXI_MMIO_awaddr),
   .io_mmio_axi_aw_bits_id (S_AXI_MMIO_awid),
   .io_mmio_axi_aw_bits_size (S_AXI_MMIO_awsize),
   .io_mmio_axi_aw_bits_len (S_AXI_MMIO_awlen),
   .io_mmio_axi_aw_bits_burst (S_AXI_MMIO_awburst),
   .io_mmio_axi_aw_bits_cache (S_AXI_MMIO_awcache),
   .io_mmio_axi_aw_bits_lock (S_AXI_MMIO_awlock),
   .io_mmio_axi_aw_bits_prot (S_AXI_MMIO_awprot),
   .io_mmio_axi_aw_bits_qos (S_AXI_MMIO_awqos),
   .io_mmio_axi_w_valid (S_AXI_MMIO_wvalid),
   .io_mmio_axi_w_ready (S_AXI_MMIO_wready),
   .io_mmio_axi_w_bits_strb (S_AXI_MMIO_wstrb),
   .io_mmio_axi_w_bits_data (S_AXI_MMIO_wdata),
   .io_mmio_axi_w_bits_last (S_AXI_MMIO_wlast),
   .io_mmio_axi_b_valid (S_AXI_MMIO_bvalid),
   .io_mmio_axi_b_ready (S_AXI_MMIO_bready),
   .io_mmio_axi_b_bits_resp (S_AXI_MMIO_bresp),
   .io_mmio_axi_b_bits_id (S_AXI_MMIO_bid),
   .io_mmio_axi_r_valid (S_AXI_MMIO_rvalid),
   .io_mmio_axi_r_ready (S_AXI_MMIO_rready),
   .io_mmio_axi_r_bits_resp (S_AXI_MMIO_rresp),
   .io_mmio_axi_r_bits_id (S_AXI_MMIO_rid),
   .io_mmio_axi_r_bits_data (S_AXI_MMIO_rdata),
   .io_mmio_axi_r_bits_last (S_AXI_MMIO_rlast),
   .io_interrupts(interrupts)
  );

  IBUFG ibufg_gclk (.I(clk), .O(gclk_i));
  BUFG  bufg_host_clk (.I(host_clk_i), .O(host_clk)); // 25MHz
  BUFG  bufg_sys_clk (.I(gclk_i), .O(sys_clk)); // 50MHz

  MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(`RC_CLK_MULT),
    .CLKFBOUT_PHASE(0.0),
    .CLKIN1_PERIOD(`ZYNQ_CLK_PERIOD),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT0_DIVIDE_F(`RC_CLK_DIVIDE),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),
    .CLKOUT6_PHASE(0.0),
    .CLKOUT4_CASCADE("FALSE"),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.0),
    .STARTUP_WAIT("FALSE")
  ) MMCME2_BASE_inst (
    .CLKOUT0(host_clk_i),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(gclk_fbout),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked),
    .CLKIN1(gclk_i),
    .PWRDWN(1'b0),
    .RST(1'b0),
    .CLKFBIN(gclk_fbout));

  top_axi top_axi_inst (
    .clk(sys_clk), // 50MHz
    .reset_n_in(reset_n_in),
    .axis_clk(host_clk), // 25MHz
    .axis_rxd_tdata(AXI_STR_RXD_0_tdata),
    .axis_rxd_tready(AXI_STR_RXD_0_tready),
    .axis_rxd_tvalid(AXI_STR_RXD_0_tvalid),
    .axis_rxd_tlast(AXI_STR_RXD_0_tlast),
    .axis_txd_tdata(AXI_STR_TXD_0_tdata),
    .axis_txd_tready(AXI_STR_TXD_0_tready),
    .axis_txd_tvalid(AXI_STR_TXD_0_tvalid),
    .axis_txd_tlast(AXI_STR_TXD_0_tlast),

    .rgmii1_rd(rgmii1_rd),
    .rgmii1_rx_ctl(rgmii1_rx_ctl),
    .rgmii1_rxc(rgmii1_rxc),
    .rgmii1_td(rgmii1_td),
    .rgmii1_tx_ctl(rgmii1_tx_ctl),
    .rgmii1_txc(rgmii1_txc),

    .rgmii2_rd(rgmii2_rd),
    .rgmii2_rx_ctl(rgmii2_rx_ctl),
    .rgmii2_rxc(rgmii2_rxc),
    .rgmii2_td(rgmii2_td),
    .rgmii2_tx_ctl(rgmii2_tx_ctl),
    .rgmii2_txc(rgmii2_txc),

    .stats_rx_bytes(stats_rx_bytes),
    .stats_rx_packets(stats_rx_packets),
    .stats_tx_bytes(stats_tx_bytes),
    .stats_tx_packets(stats_tx_packets),

    .os_clk(os_clk),
    .os_addr(os_addr[15:4]),
    .os_din(os_din),
    .os_dout(os_dout),
    .os_wea(os_wea),
    .os_rst(os_rst),
    .os_en(os_en)
  );

endmodule
