module lab4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    reg en, rdy;
    wire key_valid;
    wire [7:0] ct_addr, ct_rddata;
    wire [23:0] key;
    reg [6:0] key_0, key_1, key_2, key_3, key_4, key_5;

    enum {INIT, PROCESSING} init_state;

    always_ff @(posedge CLOCK_50 or negedge KEY[3]) begin
    	if(~KEY[3]) begin
    		en <= 1'b1;
        LEDR = 10'b1;
    		init_state <= INIT;
    	end else begin
    		case(init_state)
    			INIT: begin
              LEDR = 10'b0000000001;
    					if(rdy) begin
    						en <= 1'b0;
    						init_state <= PROCESSING;
    					end
    				end
    			PROCESSING: begin
    					if(rdy) begin
    						if(key_valid) begin
    							HEX0 <= key_0;
    							HEX1 <= key_1;
    							HEX2 <= key_2;
    							HEX3 <= key_3;
    							HEX4 <= key_4;
    							HEX5 <= key_5;
    						end else begin
    							HEX0 <= 7'b1_000_000;
    							HEX1 <= 7'b1_000_000;
    							HEX2 <= 7'b1_000_000;
    							HEX3 <= 7'b1_000_000;
    							HEX4 <= 7'b1_000_000;
    							HEX5 <= 7'b1_000_000;
    						end
    					end
    				end
    		endcase // init_state
    	end
    end

    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .q(ct_rddata));
    crack c(.clk(CLOCK_50), 
            .HEX0(HEX0),
            .HEX1(HEX1),
            .HEX2(HEX2),
            .HEX3(HEX3),
            .HEX4(HEX4),
            .HEX5(HEX5),
            .rst_n(KEY[3]),
            .en(en), .rdy(rdy),
            .key(key), .key_valid(key_valid),
            .ct_addr(ct_addr), .ct_rddata(ct_rddata));

endmodule: lab4