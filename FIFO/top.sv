module FIFO_top();
  bit clk;

  //clock generation
  initial begin
    clk = 0;
    forever
      #1 clk = ~clk;
  end

  FIFO_if f_if(clk);
  FIFOtb tb(f_if);
  FIFO dut(f_if);
  //bind vending_machine vending_machine_sva vending_machine_sva_inst(fifo_if);

endmodule