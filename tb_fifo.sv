module tb_fifo();

   reg clk;
   reg rst_n;
   reg rd_n;
   reg wr_n;
   reg [7:0] data_in;

   wire [7:0] data_out;
   wire under_flow, over_flow;

   fifo dut (.clk(clk),
             .rst_n(rst_n),
             .rd_n(rd_n),
             .wr_n(wr_n),
             .data_in(data_in),
             .data_out(data_out),
             .under_flow(under_flow),
             .over_flow(over_flow));

    bind DUV fifo_assertions sva(clk,rst_n,rd_n,wr_n,over_flow,under_flow);

    always
        begin
            #5 clk = 1'b0;
            #5 clk = 1'b1;
        end
    
    task reset_fifo;
        begin
            rst_n <= 1'b0;
            data_in <= $random;
            rd_n <= 1'b1;
            wr_n <= 1'b1;
            repeat(3)
                @(negedge clk);
            rst_n <= 1'b1
        end
    endtask


    task wr_rd (input [15:0] wr_data, input wr,input rd);
         begin
             data_in = wr_data;
             rd_n = rd;
             wr_n = wr;
             if (~wr_n)
                $display("FIFO WRITE : Data = %d \n",data_in);
            @(posedge clk);
            @(posedge clk);
            if (~rd_n)
                $display("Fifo Read: Data = %d \n",data_out);
         end
    endtask

    initial 
        begin : 
           integer i;
           reset_fifo;
           $display("\n\n ***********WRITING INTO FIFO********* \n\n");
           for (i= 16; i>0 ; i = i - 1)
               begin
                  wr_rd(i,1'b0,1'b1);
               end

            wr_rd(8'b1,1'b0,1'b1);
            wr_rd(8'b1,1'b0,1'b1);

            $display("\n\n ********************* Reading Fifo ********** \n\n");
            repeat(16)
                begin
                    wr_rd(8'd0,1'b1,1'b0);
                end

            wr_rd(8'b0,1'b1,1'b0);
            wr_rd(8'b0,1'b1,1'b0);

            wr_rd(8'b0,1'b0,1'b1);
            wr_rd(8'b0,1'b0,1'b1);

            wr_rd(8'b0,1'b1,1'b0);
            wr_rd(8'b0,1'b1,1'b0);

            wr_rd(8'd2,1'b0,1'b1);
            wr_rd(8'd3,1'b0,1'b0);

            $finish;
        end

initial begin

    `ifdef  VCS
               $fsdbDumpSVA(0,tb_fifo);
               $fsdbDumpSVA(0,tb_fifo);
            'endif

    $monitor("************FIFO : Underflow = %b, Overflow = %b ******", under_flow,over_flow);
end

endmodule

        
