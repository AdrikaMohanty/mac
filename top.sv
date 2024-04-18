module mac(clk,a,b,c);
    input clk;
    input [15:0]a,b;
    output reg [31:0]c;

    reg [15:0] data_a,data_b;
    wire [31:0]prod,addo;
    always @(posedge clk)
    begin 
        data_a <= a;
        data_b <= b;
        
    end 
    always@(posedge clk)
    begin 
        c <= addo+carry;
     end 

    

    multiplier mul(clk,data_a,data_b,prod);
    pipeline_adder add(clk,prod,c,addo,carry);

endmodule 

module multiplier(clk,multiplicand,multiplier,product);
    parameter WIDTH = 16;
    input clk;
    input [WIDTH-1:0] multiplicand,multiplier;
    reg [((2*WIDTH)-1):0] mid [WIDTH-1:0];
    wire [((2*WIDTH)-1):0] multiplicand_ext;
    output reg [(2*WIDTH)-1:0] product;
    integer i;


    assign multiplicand_ext = {{WIDTH{1'b0}},multiplicand};

    always @ (posedge clk)
        begin 
            mid[0] = multiplicand_ext & {(2*WIDTH){multiplier[0]}};
            for (i=1;i<WIDTH;i=i+1)
            begin 
                mid[i] = (multiplicand_ext << i)& {(2*WIDTH){multiplier[i]}};
            end 

            product = mid[0];

            for (i=1;i<WIDTH;i=i+1)
            begin
                product = product + mid[i];
            end
        end
endmodule 


module pipeline_adder(clk,a,b,sum,carry);
    parameter width = 32;
    parameter width1 = 16;
    parameter width2 = 16;

    input  clk;
    input [31:0]a,b;
    output [width-1:0]sum;
    output  carry;

    reg [width1-1:0]l1,l2,s1;
    reg [width1:0]r1;
    reg [width2-1:0]l3,l4,r2,s2;

    always @ (posedge clk)
    begin 
        l1<= a[width1-1:0];
        l2<= b[width1-1:0];

        l3 <= a[width-1:width1];
        l4 <= b[width-1:width1];
        // first stage 
        r1 <= {1'b0,l1}+{1'b0,l2};
        r2 <= l3+l4;
        // second stage 
        s1 <= r1[width1-1:0];

        s2 <= r1[width1]+r2;

    end 

    assign carry = r1[width1];
    assign sum = {s2,s1};
endmodule