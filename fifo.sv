`define Fifo_depth 16
`define Data_width 8
`define Ptr_size 4

module fifo (input clk,
             input rst_n,
             input rd_n,
             input [`Data_width-1:0] data_in,
             output [`Data_width-1:0] data_out,
             input over_flow,
             input under_flow);

reg under_flow, over_flow;
reg full,empty;
reg [`Data_width : 0] data_out;
reg [`Data_width - 1 : 0] fifo_mem [0 : `Fifo_depth - 1];
reg [`Ptr_size - 1 : 0] fifo_status;
reg [`Ptr_size - 1 : 0] read_ptr;
reg [`Ptr_size - 1 : 0] write_ptr;

always@(posedge clk or negedge rst_n) 
     begin
        if (~rst_n)
           begin
             read_ptr <= `Ptr_size'b1;
             write_ptr <= `Ptr_size'b0;
           end
        else
            begin
                if (~rd_n && ~empty)
                   begin
                        if (read_ptr == `FIFO_DEPTH - 1)
                            read_ptr <= `Ptr_size'b0;
                        else 
                            read_ptr <= read_ptr + 1'b1;
                   end
                if (~wr_n && ~full)
                    begin
                      if (write_ptr == `FIFO_DEPTH - 1)
                          write_ptr <= `PTR_SIZE'b0;
                       else 
                          	write_ptr <=  write_ptr + 1'b0; // Error - ASSERTION - WRITE will catch this bug
                    end
            end 
        end    

always@(posedge clk or negedge rst_n)
    begin
        if (~rst_n)  
           begin
             under_flow <= 1'b0;
             over_flow <= 1'b0'
           end
        else 
           begin
              if (~rd_n)
                  begin
                    if (!empty)
                       begin
                          data_out <= fifo_mem[read_ptr];
                          under_flow <= 1'b0;
                       end
                    else 
                       begin
                        under_flow <= 1'b1;
                       end
                  end
                else 
                   under_flow <= 1'b0;

                if (~wr_n)
                   begin
                     if (!full)
                            begin
                            fifo_mem[write_ptr] <= data_in;
                            over_flow <= 1'b0;
                            end
                     else
                        begin
                            over_flow <= 1'b1;
                        end
                   end
                   else 
                      over_flow <= 1'b0;
           end
    end

    always@(posedge clk or negedge rst_n)
        begin
            if(~rst_n)
               fifo_status <= 'Ptr_size'b0;
            else if ((fifo_status == 'Fifo_depth - 1) && (~wr_n))
               fifo_status <= `Fifo_depth - 1;
            else if ((fifo_status == `Ptr_size'b0) && (~rd_n))
                fifo_status <= `Ptr_size'b0;
            else if ((rd_n == 1'b0 && wr_n == 1'b1 && empty == 1'b0))
                 fifo_status <= fifo_status - 1'b1;
            else if ((wr_n == 1'b0 && rd_n == 1'b1 && full == 1'b0))
                 fifo_status <= fifo_status + 1'b1;
        end
    
    always@ (posedge clk or negedge rst_n)
        begin
            if (~rst_n)
                begin
                    full <= 1'b0;
                    empty <= 1'b1;
                end
            else 
                begin
                    if (fifo_status == `Fifo_depth - 1)
                        full <= 1'b1;
                    else 
                        full <= 1'b0;
                    
                    if (fifo_status == `Ptr_size'b0)
                       empty <= 1'b1;
                    else 
                       empty <= 1'b0;
                end
        end

    endmodule




        

