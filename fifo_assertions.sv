module fifo_assertions (
    input clk,
    input rst_n,
    input rd_n,
    input wr_n,
    input over_flow,
    input under_flow
);

sequence rst_seq;
  ( (!under_flow) && (!over_flow));
endsequence

property rst_prty;
   @(posedge clk)(~rst_n) | => rst_seq;
endproperty

property overflow_prty;
   @(posedge clk) disable iff(~rst_n) ~rst_n ##1 rst_n ##1 (~wr_n && rd_n)[*17] |=> over_flow;
endproperty

property underflow_prty;
    @(posedge clk) disable iff (~rst_n) over_flow ##1 (~rd_n && wr_n)[*17] |=> under_flow;
endproperty

Reset : assert property (reset_prty);
Overflow : assert property (overflow_prty);
Underflow : assert property (underflow_prty);

endmodule