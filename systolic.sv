`timescale 1 ps / 1 ps
`default_nettype none

module systolic
#
(
    parameter   D_W  = 8, //operand data width
    parameter   D_W_ACC = 16, //accumulator data width
    parameter   N1   = 4,
    parameter   N2   = 4,
    parameter   M    = 8
)
(
    input   wire                                        clk,
    input   wire                                        rst,
    input   wire                                        enable_row_count_A,
    output  wire    [$clog2(M)-1:0]                     pixel_cntr_A,
    output  wire    [($clog2(M/N1)?$clog2(M/N1):1)-1:0] slice_cntr_A,
    output  wire    [($clog2(M/N2)?$clog2(M/N2):1)-1:0] pixel_cntr_B,
    output  wire    [$clog2(M)-1:0]                     slice_cntr_B,
    output  wire    [$clog2((M*M)/N1)-1:0]              rd_addr_A,
    output  wire    [$clog2((M*M)/N2)-1:0]              rd_addr_B,
    input   wire    [D_W-1:0]                           A [N1-1:0], //m0
    input   wire    [D_W-1:0]                           B [N2-1:0], //m1
    output  wire    [D_W_ACC-1:0]                       D [N1-1:0], //m2
    output  wire    [N1-1:0]                            valid_D
);


reg     [D_W-1:0]       Areg        [N1-1:0];
reg     [D_W-1:0]       Breg        [N2-1:0];
wire    [N2-1:0]        validD   [N1-1:0];
wire    [D_W-1:0]       out_a    [N1-1:0][N2-1:0];
wire    [D_W-1:0]       out_b    [N1-1:0][N2-1:0];
wire    [D_W-1:0]       in_a     [N1-1:0][N2-1:0];
wire    [D_W-1:0]       in_b     [N1-1:0][N2-1:0];
reg    [N2-1:0]        init_pe  [N1-1:0];
reg     [2*M+N1-1:0]    init_pe_reg_e;
reg     [M-1:0]         init_pe_reg_ne;
reg     [(M-1):0]       flag;
wire    [N2-1:0]        in_valid  [N1-1:0];
wire    [(D_W_ACC)-1:0] data_in   [N1-1:0][N2-1:0];
wire    [(D_W_ACC)-1:0] data_out  [N1-1:0][N2-1:0];
wire    [N2-1:0]        out_valid [N1-1:0];
reg                     delay;

always@(posedge clk) begin
  Areg <= A;
  Breg <= B;
end

always@(posedge clk)
begin
  if(rst)
  delay <= 0;
end
control #
  (
    .N2       (N2),
    .N1       (N1),
    .M        (M)
  )
  control_inst
  (

    .clk                  (clk),
    .rst                  (rst),
    .enable_row_count     (enable_row_count_A),

    .pixel_cntr_B         (pixel_cntr_B),
    .slice_cntr_B         (slice_cntr_B),

    .pixel_cntr_A         (pixel_cntr_A),
    .slice_cntr_A         (slice_cntr_A),

    .rd_addr_A            (rd_addr_A),
    .rd_addr_B            (rd_addr_B)
  );

genvar i,j;
generate
  for(i=0;i<N1;i=i+1) begin   : row_counter
    for(j=0;j<N2;j=j+1) begin : col_counter
    //Connecting PEs Vertically
      if(i==0) begin 
         assign in_b[i][j] = Breg[j];
      end
      else begin 
         assign in_b[i][j] = out_b[i-1][j];
      end
    //Connecting PEs Horizontally
      if(j==0) begin
        assign in_a[i][j] = Areg[i];
        assign in_valid[i][j] = 0;
        assign data_in[i][j]  = 0;
      end
      else begin
        assign in_a[i][j] = out_a[i][j-1];
        assign in_valid[i][j] = out_valid[i][j-1];
        assign data_in[i][j]  = data_out[i][j-1];
      end

      pe #(.D_W_ACC(D_W_ACC), .D_W(D_W))
      pe_inst
      (
          .clk(clk),
          .rst(rst),
          .init(init_pe[i][j]),
          .in_a(in_a[i][j]),
          .in_b(in_b[i][j]),
          .in_valid(in_valid[i][j]),
          .in_data(data_in[i][j]),
          .out_valid(out_valid[i][j]),
          .out_data(data_out[i][j]),
          .out_a(out_a[i][j]),
          .out_b(out_b[i][j])
      ); 

      if(j == N2-1) begin
       assign valid_D[i] = out_valid[i][j];
       assign D[i] = data_out[i][j];
      end

      //Shift Register for init
      //init_pe = N+R+C
      if(M==N1) begin
        always@(posedge clk) begin 
         init_pe[i][j] <= init_pe_reg_e[M+i+j+1];
        end
      end

      else if(M>N1) begin 
        always@(posedge clk) begin
          init_pe[i][j] <= (init_pe_reg_ne[i+j+1])? 1: 0;
        end
      end

    end 
  end

  if(M==N1) begin
    always @(posedge clk) begin
      if(rst) begin
        init_pe_reg_e <= 0 | 1'b1;
      end else begin
        init_pe_reg_e <= init_pe_reg_e << 1;
      end
    end
  end

      
  else if(M!=N1) begin
 //To delay the start of init after 4 clock cycles.  
      always @(posedge clk) begin
        
        if(rst) begin
          init_pe_reg_ne <= 0;
          flag <= 1'b0;
        end
        
        else if(flag == M-1) begin
          flag <= 1'b0;
          init_pe_reg_ne <= 0 | 1'b1;
        end
        
        else begin
          flag <= flag + 1;
          init_pe_reg_ne <= init_pe_reg_ne << 1;
        end
   end
  end
endgenerate
endmodule




