module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here
    enum {INIT, WAIT_FOR_I, READ_J, WAIT_FOR_J, SWAP_J, SWAP_I, READ_I} current_state;

    reg [7:0] j;
    reg [7:0] i;
    reg [7:0] temp_i;

    wire [7:0] new_i = i + 1;
    wire [1:0] i_mod = i % 3;
    wire [7:0] key_portion = (i_mod == 0) ? key[23:16] :
    					     (i_mod == 1) ? key[15:8]  :
    					     key[7:0];
    wire [7:0] new_j = (j + rddata + key_portion) % 256;

    always_ff @(posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
    		//similar to init
    		j <= 8'b0;
    		i <= 8'b0;
    		rdy <= 1;
    		wren <= 0;
    		addr <= 0; //read from S[0] to get initial S[i]
    		current_state <= INIT;
    	end else begin
    		case (current_state)
    			INIT: begin
	    				j <= 8'b0;
	    				i <= 8'b0;
	    				wren <= 0;  //set to read
	    			    addr <= 0; //read from S[0] to get initial S[i]

	    				if(rdy && en) begin	    					
	    					rdy <= 0; //not ready anymore
	    					current_state <= WAIT_FOR_I;
	    				end else begin
	    					rdy <= 1;
	    					current_state <= INIT;
	    				end
    				end
    			WAIT_FOR_I: begin
    					current_state <= READ_J; // the waiting cycle for memory to return data
					end
    			READ_J: begin
    					j <= new_j; //update j
    					temp_i <= rddata; 
                        //store the value read from S[i], which is set up at the end of the READ_I 					
    					addr <= new_j; //get S[new_j]
    					wren <= 0;
    					current_state <= SWAP_J;
    				end
    			SWAP_J: begin
    					addr <= j; //update S[j]
    					wrdata <= temp_i; // S[j] = previously read S[i] which was stored in temp_i
    					wren <= 1;
    					current_state <= SWAP_I;
    				end
    			SWAP_I: begin
    					addr <= i; //update S[i]
    					wrdata <= rddata; // S[i] = previously read S[j] from last state
    					wren <= 1;
    					current_state <= READ_I;
    				end

    			READ_I: begin
    					i <= new_i; //increase i by 1
    					addr <= new_i; //read S[i] at the new location
    				    wren <= 0;
						if(i < 255)
							current_state <= WAIT_FOR_I;
						else
							current_state <= INIT;
    				end
    		endcase // current_state
    	end
    end

endmodule: ksa