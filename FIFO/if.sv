interface FIFO_if(clk);
  input clk;
 parameter WIDTH=16;
  logic wr_en,rd_en,rst_n,//i/p
        full,almostfull,empty,almostempty,overflow,underflow,wr_ack;
        logic [WIDTH-1:0] data_in,data_out;
  modport DUT (input data_in,wr_en,rd_en,rst_n,clk, output data_out,full,almostfull,empty,almostempty,overflow,underflow,wr_ack);

  modport TEST (output data_in,wr_en,rd_en,rst_n, input clk, data_out,full,almostfull,empty,almostempty,overflow,underflow,wr_ack);


endinterface 
