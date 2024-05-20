module MAIN_APPLE2 (
    input clk_74a,
    input clk_85_9,
    input clk_50,
    input clk_57_27,
    input clk_pixel_14_318,
    input clock_locked,

    // Control
    input wire external_reset,

    // Inputs
    /*
    input wire p1_button_a,
    input wire p1_button_b,
    input wire p1_button_start,
    input wire p1_button_select,
    input wire p1_dpad_up,
    input wire p1_dpad_down,
    input wire p1_dpad_left,
    input wire p1_dpad_right,

    input wire [7:0] p1_lstick_x,
    input wire [7:0] p1_lstick_y,

    input wire p2_button_a,
    input wire p2_button_b,
    input wire p2_button_start,
    input wire p2_button_select,
    input wire p2_dpad_up,
    input wire p2_dpad_down,
    input wire p2_dpad_left,
    input wire p2_dpad_right,

    input wire p3_button_a,
    input wire p3_button_b,
    input wire p3_button_start,
    input wire p3_button_select,
    input wire p3_dpad_up,
    input wire p3_dpad_down,
    input wire p3_dpad_left,
    input wire p3_dpad_right,

    input wire p4_button_a,
    input wire p4_button_b,
    input wire p4_button_start,
    input wire p4_button_select,
    input wire p4_dpad_up,
    input wire p4_dpad_down,
    input wire p4_dpad_left,
    input wire p4_dpad_right,
    */
    // Settings
    /*
    input wire hide_overscan,
    input wire [1:0] mask_vid_edges,
    input wire allow_extra_sprites,
    input wire [2:0] selected_palette,

    input wire multitap_enabled,
    input wire lightgun_enabled,
    input wire [7:0] lightgun_dpad_aim_speed,
    input wire swap_controllers,
    */

    // Data in
    input wire        ioctl_wr,
    input wire [27:0] ioctl_addr,
    input wire [ 7:0] ioctl_dout,
    input wire [ 7:0] ioctl_index,
    input wire        ioctl_download,

    // UART
    /*
    input         UART_CTS,
    output        UART_RTS,
    input         UART_RXD,
    output        UART_TXD,
    output        UART_DTR,
    input         UART_DSR,
    */

    /*
    input wire palette_download,
    input wire is_downloading,
    */
    // Save data
    /*
    output wire has_save,
    input wire sd_buff_wr,
    input wire sd_buff_rd,
    input wire [17:0] sd_buff_addr,
    output wire [7:0] sd_buff_din,
    input wire [7:0] sd_buff_dout,
    */
    // Save states
    /*
    output wire mapper_has_savestate,

    input wire ss_save,
    input wire ss_load,

    output wire [63:0] ss_din,
    input wire [63:0] ss_dout,
    output wire [25:0] ss_addr,
    output wire ss_rnw,
    output wire ss_req,
    output wire [7:0] ss_be,
    input wire ss_ack,

    output wire ss_busy,
    */
    // SDRAM
    /*
    output wire [12:0] dram_a,
    output wire [ 1:0] dram_ba,
    inout  wire [15:0] dram_dq,
    output wire [ 1:0] dram_dqm,
    output wire        dram_clk,
    output wire        dram_cke,
    output wire        dram_ras_n,
    output wire        dram_cas_n,
    output wire        dram_we_n,
    */
    // Video
    output HSync,
    output VSync,
    output HBlank,
    output VBlank,
    output [7:0] video_r,
    output [7:0] video_g,
    output [7:0] video_b,

    // Audio
    output [15:0] audio_l,
    output [15:0] audio_r
);

/////////////////  HPS  ///////////////////////////

wire [31:0] status = 0;
wire  [1:0] buttons = 0;
wire        forced_scandoubler;
wire [21:0] gamma_bus;

wire [15:0] joystick_0;
wire [15:0] joystick_a0;
wire  [7:0] paddle_0;

wire [10:0] ps2_key;

wire [31:0] sd_lba[3];
reg   [2:0] sd_rd;
reg   [2:0] sd_wr;
wire  [2:0] sd_ack;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din[3];
wire        sd_buff_wr;
wire  [2:0] img_mounted;
wire        img_readonly;

wire [63:0] img_size;
wire [64:0] RTC;


wire soft_reset;

wire  [7:0] pdl  = {~paddle_0[7], paddle_0[6:0]};
wire [15:0] joys = status[6] ? joystick_a0 : {joystick_a0[7:0],joystick_a0[15:8]};
wire [15:0] joya = {status[17] ? pdl : joys[15:8], status[18] ? pdl : joys[7:0]};
wire  [5:0] joyd = joystick_0[5:0] & {2'b11, {2{~|joys[7:0]}}, {2{~|joys[15:8]}}};


reg ce_pix;
always @(posedge clk_pixel_14_318) begin
	reg [2:0] div = 0;
	
	div <= div + 1'd1;
	ce_pix <= status[16] ? &div : &div[1:0];
end

wire led;
wire hbl,vbl;

reg [1:0] screen_mode;
reg       text_color;

always @(status[21:19]) case (status[21:19])
	3'b001: begin
		screen_mode = 2'b00;
		text_color = 1;
	end
	3'b010: begin
		screen_mode = 2'b01;
		text_color = 0;
	end
	3'b011: begin
		screen_mode = 2'b10;
		text_color = 0;
	end
	3'b100: begin
		screen_mode = 2'b11;
		text_color = 0;
	end
	default: begin
		screen_mode = 2'b00;
		text_color = 0;
	end
endcase // always @ (status[21:19])


apple2_top apple2_top
(
	.CLK_14M(clk_pixel_14_318),
	.CLK_50M(clk_50),

	.CPU_WAIT(cpu_wait_hdd /*| cpu_wait_fdd*/),
	.cpu_type(~status[5]),

	.reset_cold(external_reset | status[0]),
	.reset_warm(buttons[1]),
	.soft_reset(soft_reset),

	.hblank(HBlank),
	.vblank(VBlank),
	.hsync(HSync),
	.vsync(VSync),
	.r(video_r),
	.g(video_g),
	.b(video_b),
	.SCREEN_MODE(screen_mode),
	.TEXT_COLOR(text_color),
	.PALMODE(status[22]),
	.ROMSWITCH(~status[23]),

	.AUDIO_L(audio_l),
	.AUDIO_R(audio_r),
	.TAPE_IN(tape_adc_act & tape_adc),

	.ps2_key(ps2_key),

	.joy(joyd),
	.joy_an(joya),

	.mb_enabled(~status[4]),
	
	.TRACK1(TRACK1),
	.TRACK1_ADDR(TRACK1_RAM_ADDR),
	.TRACK1_DI(TRACK1_RAM_DI),
	.TRACK1_DO (TRACK1_RAM_DO),
	.TRACK1_WE (TRACK1_RAM_WE),
	.TRACK1_BUSY (TRACK1_RAM_BUSY),
	//-- Track buffer interface disk 2
	.TRACK2(TRACK2),
	.TRACK2_ADDR(TRACK2_RAM_ADDR),
	.TRACK2_DI(TRACK2_RAM_DI),
	.TRACK2_DO (TRACK2_RAM_DO),
	.TRACK2_WE (TRACK2_RAM_WE),
	.TRACK2_BUSY (TRACK2_RAM_BUSY),

	.DISK_READY(DISK_READY),
	.D1_ACTIVE(D1_ACTIVE),
	.D2_ACTIVE(D2_ACTIVE),
	.DISK_ACT(led),

	.HDD_SECTOR(sd_lba[1]),
	.HDD_READ(hdd_read),
	.HDD_WRITE(hdd_write),
	.HDD_MOUNTED(hdd_mounted),
	.HDD_PROTECT(hdd_protect),
	.HDD_RAM_ADDR(sd_buff_addr),
	.HDD_RAM_DI(sd_buff_dout),
	.HDD_RAM_DO(sd_buff_din[1]),
	.HDD_RAM_WE(sd_buff_wr & sd_ack[1]),

	.ram_addr(ram_addr),
	.ram_do(ram_dout),
	.ram_di(ram_din),
	.ram_we(ram_we),
	.ram_aux(ram_aux),
	
	.ioctl_addr(ioctl_addr),
	.ioctl_data(ioctl_dout),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),

/*
	.UART_TXD(UART_TXD),
	.UART_RXD(UART_RXD), // input
	.UART_RTS(UART_RTS),
	.UART_CTS(UART_CTS), // input
	.UART_DTR(UART_DTR),
	.UART_DSR(UART_DSR), // input
	.RTC(RTC)
*/
);

wire [2:0] scale = status[11:9];
wire [2:0] sl = scale ? scale - 1'd1 : 3'd0;
wire       scandoubler = (scale || forced_scandoubler);

wire [17:0] ram_addr;
reg  [15:0] ram_dout;
wire  [7:0]	ram_din;
wire        ram_we;
wire        ram_aux;

reg [7:0] ram0[196608];
always @(posedge clk_pixel_14_318) begin
	if(ram_we & ~ram_aux) begin
		ram0[ram_addr] <= ram_din;
		ram_dout[7:0]  <= ram_din;
	end else begin
		ram_dout[7:0]  <= ram0[ram_addr];
	end
end

reg [7:0] ram1[65536];
always @(posedge clk_pixel_14_318) begin
	if(ram_we & ram_aux) begin
		ram1[ram_addr[15:0]] <= ram_din;
		ram_dout[15:8] <= ram_din;
	end else begin
		ram_dout[15:8] <= ram1[ram_addr[15:0]];
	end
end

wire dd_reset = external_reset | status[0] | buttons[1] | soft_reset;

reg  hdd_mounted = 0;
wire hdd_read;
wire hdd_write;
reg  hdd_protect;
reg  cpu_wait_hdd = 0;

always @(posedge clk_pixel_14_318) begin
	reg state = 0;
	reg old_ack = 0;
	reg hdd_read_pending = 0;
	reg hdd_write_pending = 0;

	old_ack <= sd_ack[1];
	hdd_read_pending <= hdd_read_pending | hdd_read;
	hdd_write_pending <= hdd_write_pending | hdd_write;

	if (img_mounted[1]) begin
		hdd_mounted <= img_size != 0;
		hdd_protect <= img_readonly;
	end

	if(dd_reset) begin
		state <= 0;
		cpu_wait_hdd <= 0;
		hdd_read_pending <= 0;
		hdd_write_pending <= 0;
		sd_rd[1] <= 0;
		sd_wr[1] <= 0;
	end
	else if(!state) begin
		if (hdd_read_pending | hdd_write_pending) begin
			state <= 1;
			sd_rd[1] <= hdd_read_pending;
			sd_wr[1] <= hdd_write_pending;
			cpu_wait_hdd <= 1;
		end
	end
	else begin
		if (~old_ack & sd_ack[1]) begin
			hdd_read_pending <= 0;
			hdd_write_pending <= 0;
			sd_rd[1] <= 0;
			sd_wr[1] <= 0;
		end
		else if(old_ack & ~sd_ack[1]) begin
			state <= 0;
			cpu_wait_hdd <= 0;
		end
	end
end


always @(posedge clk_pixel_14_318) begin
	if (img_mounted[0]) begin
		disk_mount[0] <= img_size != 0;
		DISK_CHANGE[0] <= ~DISK_CHANGE[0];
		//disk_protect <= img_readonly;
	end
end
always @(posedge clk_pixel_14_318) begin
	if (img_mounted[2]) begin
		disk_mount[1] <= img_size != 0;
		DISK_CHANGE[1] <= ~DISK_CHANGE[1];
		//disk_protect <= img_readonly;
	end
end
	
wire D1_ACTIVE,D2_ACTIVE;
wire TRACK1_RAM_BUSY;
wire [12:0] TRACK1_RAM_ADDR;
wire [7:0] TRACK1_RAM_DI;
wire [7:0] TRACK1_RAM_DO;
wire TRACK1_RAM_WE;
wire [5:0] TRACK1;

wire TRACK2_RAM_BUSY;
wire [12:0] TRACK2_RAM_ADDR;
wire [7:0] TRACK2_RAM_DI;
wire [7:0] TRACK2_RAM_DO;
wire TRACK2_RAM_WE;
wire [5:0] TRACK2;

wire [1:0] DISK_READY;
reg [1:0] DISK_CHANGE;
reg [1:0]disk_mount;



floppy_track floppy_track_1
(
   .clk(clk_pixel_14_318),
   .reset(dd_reset),
	
   .ram_addr(TRACK1_RAM_ADDR),
   .ram_di(TRACK1_RAM_DI),
   .ram_do(TRACK1_RAM_DO),
   .ram_we(TRACK1_RAM_WE),
	
   .track (TRACK1),
   .busy  (TRACK1_RAM_BUSY),
   .change(DISK_CHANGE[0]),
   .mount (disk_mount[0]),
   .ready  (DISK_READY[0]),
   .active (D1_ACTIVE),

   .sd_buff_addr (sd_buff_addr),
   .sd_buff_dout (sd_buff_dout),
   .sd_buff_din  (sd_buff_din[0]),
   .sd_buff_wr   (sd_buff_wr),

   .sd_lba       (sd_lba[0] ),
   .sd_rd        (sd_rd[0]),
   .sd_wr       ( sd_wr[0]),
   .sd_ack       (sd_ack[0])	
);


floppy_track floppy_track_2
(
   .clk(clk_pixel_14_318),
   .reset(dd_reset),
	
   .ram_addr(TRACK2_RAM_ADDR),
   .ram_di(TRACK2_RAM_DI),
   .ram_do(TRACK2_RAM_DO),
   .ram_we(TRACK2_RAM_WE),
	
   .track (TRACK2),
   .busy  (TRACK2_RAM_BUSY),
   .change(DISK_CHANGE[1]),
   .mount (disk_mount[1]),
   .ready  (DISK_READY[1]),
   .active (D2_ACTIVE),

   .sd_buff_addr (sd_buff_addr),
   .sd_buff_dout (sd_buff_dout),
   .sd_buff_din  (sd_buff_din[2]),
   .sd_buff_wr   (sd_buff_wr),

   .sd_lba       (sd_lba[2] ),
   .sd_rd        (sd_rd[2]),
   .sd_wr       ( sd_wr[2]),
   .sd_ack       (sd_ack[2])	
);

wire tape_adc, tape_adc_act;

endmodule
