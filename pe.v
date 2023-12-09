`timescale 1 ps / 1 ps

module pe
#(
    parameter   D_W_ACC  = 64, //accumulator data width
    parameter   D_W      = 32  //operand data width
)
(
    input   wire                    clk,
    input   wire                    rst,
    input   wire                    init,
    input   wire    [D_W-1:0]       in_a,
    input   wire    [D_W-1:0]       in_b,
    output  reg     [D_W-1:0]       out_b,
    output  reg     [D_W-1:0]       out_a,

    input   wire    [(D_W_ACC)-1:0] in_data,
    input   wire                    in_valid,
    output  reg     [(D_W_ACC)-1:0] out_data,
    output  reg                     out_valid
);

// enter your RTL here
reg [D_W_ACC-1:0] out_sum_reg = 0;
reg [D_W_ACC-1:0] in_sum_reg  = 0;
reg flag = 0; //Delay by a cycle
always @(posedge clk) begin

    if(in_valid) begin
        flag <= 1;
    end else if (!in_valid) begin
        flag <= 0;
    end 
    in_sum_reg <= in_data;
end

always @(posedge clk) begin
    out_a <= in_a;
    out_b <= in_b;

    if(rst) begin
        out_data <= 0;
        out_valid <= 0;
        out_a <= 0;
        out_b <= 0;
	out_sum_reg <= 0; 
    end else if (init) begin
        out_valid <= 1;
        out_data <= out_sum_reg;
        out_sum_reg <= in_a * in_b;
    end else begin
        out_valid <= 0;
        out_sum_reg <= out_sum_reg + in_a * in_b;
    end
    
    if (flag) begin
        out_valid <= 1;
        out_data <= in_sum_reg;
    end

end

endmodule
