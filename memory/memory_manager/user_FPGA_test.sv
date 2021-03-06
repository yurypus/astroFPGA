
module user_FPGA_test(clk,rst_n,  rd_ready, rd_req, rd_data,FPGA_wr_en,
					write_data,req_addr, pci_input_data, pci_req_addr, pci_wr_en,
					in_flag, flag_we, out_flag);
	
	input logic			 clk, rst_n;
	input logic [31:0] 	 rd_data;
	input logic			 rd_ready;
	input logic [31:0]	 pci_input_data;
	input logic [20:0]	 pci_req_addr;
	input logic			 pci_wr_en;
	input logic [31:0]   in_flag;
	
	output logic         flag_we;
	output logic [31:0]  out_flag;
	output	logic		 rd_req;     //request to read, or write.
	output  logic [31:0] write_data;
	output  logic [20:0] req_addr;
	output  logic 	 	 FPGA_wr_en;
	
	//testing signals.
	
	// to user.
	logic 			ready_2_start;
	logic [31:0]	user_rd_data;	// read data to send to user.
	
	// from user.
	logic			req;   // requesting a read or write operation.
	logic			rd_wr;		// deterimine if read or write. read = 0, write = 1
	logic	[20:0]	user_req_addr;	// requested address.
	logic 	[31:0]	user_write_data;	// data to write to memory.
	logic			set_done;	// complete a set.
	
	// deal with endianess
	assign user_rd_data = {rd_data[7:0], rd_data[15:8],rd_data[23:16], rd_data[31:24]};
	assign {write_data[7:0], write_data[15:8], write_data[23:16], write_data[31:24]} = user_write_data;
	
	// dummy place holder
	assign req = 1'b0;
	assign rd_wr =1'b0;
	assign user_req_addr =21'b0;
	assign user_write_data = 32'b0;
	assign set_done = 1'b0;
	//
	
	enum {INIT, WAIT, READ, WRITE, DONE} cs,ns;
    	
    	always_comb begin
    		rd_req = 1'b0;
    		FPGA_wr_en = 1'b0;
    		flag_we = 1'b0;
    		out_flag = 32'b0;
			ready_2_start = 1'b0;
    		ns = cs;
			req_addr = user_req_addr;
    		case(cs)
    			INIT:begin // waiting for data transfer to complete, keep reading flag.
    			// there's a write operation to the flag area. find out the instruction.
    				if((pci_req_addr == {2'b00,19'h7FFFE})&& pci_wr_en && (pci_input_data == 32'h0001_0000)) begin
    					    out_flag = 32'h0000_0002;
    					    flag_we = 1'b1;
    						req_addr = 21'b0;
    						ns = WAIT;
    				    end
    				else begin
    				    ns = INIT;
    			    end
					// not ready to start yet
					ready_2_start = 1'b0;
    			end
				WAIT: begin
				
						if(req&&rd_wr) FPGA_wr_en =1'b1; // next operation is write
						
						ready_2_start =1'b1;
						if(req) ns = (rd_wr)? WRITE:READ;
						else ns = WAIT;
				end
				READ: begin
						ready_2_start =1'b1;
						if(req&&rd_wr) FPGA_wr_en =1'b1; // next operation is write
						
						if(set_done) ns = DONE;
						else if(req) ns = (rd_wr)? WRITE:READ;
						else ns = WAIT;
				end
				
				WRITE: begin
						ready_2_start =1'b1;
						if(req&&rd_wr) FPGA_wr_en =1'b1; // next operation is write
						
						if(set_done) ns = DONE;
						else if(req) ns = (rd_wr)? WRITE:READ;
						else ns = WAIT;
				end
				
				DONE: begin
					ready_2_start =1'b0;
					req_addr = {2'b00,19'h7FFFE};
    				flag_we = 1'b1;
    				out_flag = 32'h0000_0004;
					ns = INIT;
				end	
    	endcase
    end
    	always_ff@(posedge clk, negedge rst_n)begin
    		if(~rst_n)begin
    			cs <= INIT;
    		end
    		else begin
    			cs <= ns;
    		end
    	end
    endmodule: user_FPGA_test
