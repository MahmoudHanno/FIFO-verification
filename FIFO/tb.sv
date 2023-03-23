module FIFOtb(FIFO_if.TEST f_if);
  class fiforand;
    rand bit rd_enable,wr_enable;
    rand bit [15:0] data;
    rand bit reset;
    constraint rst{
      reset dist{1:=98,0:=2};
    }
    covergroup wr_rd_cov();
      num_of_rd : coverpoint rd_enable iff (!reset){
        bins rd_1={1};
        bins rd_0={0};
      }
      num_of_wr : coverpoint wr_enable iff (!reset){
        bins wr_1={1};
        bins wr_0={0};
      }
    endgroup
    function new();
      wr_rd_cov=new();
    endfunction

  endclass
  parameter WIDTH=16;
  logic wr_en,rd_en,rst_n,//i/p
        full,almostfull,empty,almostempty,overflow,underflow,wr_ack;
  logic [WIDTH-1:0] data_in,data_out;
  assign clk=f_if.clk;
  assign  data_out = f_if.data_in;
  assign full = f_if.full;
  assign almostfull = f_if.almostfull;
  assign empty =f_if.empty ;
  assign almostempty = f_if.almostempty;
  assign  overflow = f_if.overflow ;
  assign  underflow = f_if.underflow;
  assign  wr_ack=f_if.wr_ack;
  assign f_if.rst_n = rst_n;
  assign f_if.data_in = data_in;
  assign f_if.wr_en = wr_en;
  assign f_if.rd_en = rd_en;
  logic [WIDTH-1:0] FIFOQ[$];
  int i;
  logic [15:0] check;
  fiforand wr_rd=new(); 


  always_comb begin
      if(wr_ack) 
        FIFOQ.push_front(data_in);
      else if(rd_en)
         check=FIFOQ.pop_back;
  end


  initial begin
    @(posedge clk)
    rst_n =0;
    #2
    rst_n=1;
    rd_en=1;
    #2
    rd_en=0;
    wr_en=1;
    for (i=0;i<9;i++)begin
      data_in=$random();
      #2;
    end
    rd_en=1;
    wr_en=0;
    repeat(9) #2;
    $display("starting randomization");
    for (i=0;i<100;i++)begin
      assert(wr_rd.randomize());
      rst_n=wr_rd.reset;
      wr_rd.wr_rd_cov.sample();
      wr_en=wr_rd.wr_enable;
      rd_en=wr_rd.rd_enable;
      #2;
    end
    $stop;
  end

  readerror: assert property(read);
  write_when_full:assert property(write_while_full);
  read_when_empty:assert property(read_while_empty);
  write_when_almostfull:assert property(write_while_almostfull);
  read_when_almostempty:assert property(read_while_almostempty);
  write:assert property(write_whilenotfull);
  reset_assert:assert property(reset);
  read_when_empty2:assert property(read_while_empty2);
  always @(posedge clk) assert (!(wr_en&&rd_en))
                          else $warning("Enta 3'abi yaad");
  //assert property(!(wr_en&&rd_en));
  property read;
  @(posedge clk) rd_en|->(check==data_out) ;
  endproperty

  property write_while_full;
    @(posedge clk) full&&wr_en|->##1(!wr_ack&&overflow);
  endproperty

  property read_while_empty;
    @(posedge clk) empty&&rd_en|->##1 (underflow);
  endproperty
  property read_while_empty2;
    @(posedge clk) $rose(empty)&&rd_en|->(!underflow);
  endproperty
  property write_while_almostfull;
    @(posedge clk) almostfull&&wr_en|->##1(full);
  endproperty

  property read_while_almostempty;
    @(posedge clk) almostempty&&rd_en|->##1(empty);
  endproperty

  property write_whilenotfull;
    @(posedge clk) !full&&wr_en|->(wr_ack);
  endproperty

  property reset;
    @(posedge clk) !rst_n|->(empty);
  endproperty

  cover property(read);
  cover property(write_while_full);
  cover property(read);
  cover property(read_while_empty);
  cover property(read_while_empty2);
  cover property(write_while_almostfull);
  cover property(read_while_almostempty);
  cover property(write_whilenotfull);
  cover property(reset);
endmodule
