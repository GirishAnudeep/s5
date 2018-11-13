`timescale 1ns / 1ps

module mark1(
        
        //inputs and outputs
        input clock_100Mhz,
       // input [3:0] A,B;
        reset,
        [14:0] sw,
        //output  [15:0] prod,
        output reg [3:0] AN,
        output reg [6:0] led
    );
        //internal variables.
        wire [3:0] A,B;
        wire [15:0] prod;
        wire s11,s12,s13,s14,s15,s22,s23,s24,s25,s26,s32,s33,s34,s35,s36,s37;
        wire c11,c12,c13,c14,c15,c22,c23,c24,c25,c26,c32,c33,c34,c35,c36,c37;
        wire [6:0] p0,p1,p2,p3;
        wire [1:0] LED_activating_counter; 
        reg [19:0] refresh_counter; 
        
        reg [3:0] LED_BCD;

        
        	assign A[3:0]=sw[3:0];
        	assign B[3:0]=sw[7:4];

    
    //initialize the p's.
        assign  p0 = A & {4{B[0]}};
        assign  p1 = A & {4{B[1]}};
        assign  p2 = A & {4{B[2]}};
        assign  p3 = A & {4{B[3]}};
    
    //final product assignments    
        assign prod[0] = p0[0];
        assign prod[1] = s11;
        assign prod[2] = s22;
        assign prod[3] = s32;
        assign prod[4] = s34;
        assign prod[5] = s35;
        assign prod[6] = s36;
        assign prod[7] = s37;
    
    //first stage
        half_adder ha11 (p0[1],p1[0],s11,c11);
        full_adder fa12(p0[2],p1[1],p2[0],s12,c12);
        full_adder fa13(p0[3],p1[2],p2[1],s13,c13);
        full_adder fa14(p1[3],p2[2],p3[1],s14,c14);
        half_adder ha15(p2[3],p3[2],s15,c15);
    
    //second stage
        half_adder ha22 (c11,s12,s22,c22);
        full_adder fa23 (p3[0],c12,s13,s23,c23);
        full_adder fa24 (c13,c32,s14,s24,c24);
        full_adder fa25 (c14,c24,s15,s25,c25);
        full_adder fa26 (c15,c25,p3[3],s26,c26);
    
    //third stage
        half_adder ha32(c22,s23,s32,c32);
        half_adder ha34(c23,s24,s34,c34);
        half_adder ha35(c34,s25,s35,c35);
        half_adder ha36(c35,s26,s36,c36);
        half_adder ha37(c36,c26,s37,c37);
       assign prod[15:8]=8'b00000000;

    always @(posedge clock_100Mhz or posedge reset)
	begin 
		if(reset==1)
			refresh_counter <= 0;
		else
			refresh_counter <= refresh_counter + 1;
	end 
	assign LED_activating_counter = refresh_counter[19:18];
	always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            AN = 4'b0111; 
           // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = prod/1000;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            AN = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = (prod % 1000)/100;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            AN = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = ((prod % 1000)%100)/10;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            AN = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = ((prod % 1000)%100)%10;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end

	always @(*)
	begin
		case(LED_BCD)
			4'b0000: led = 7'b0000001; // "0"  
			4'b0001: led = 7'b1001111; // "1" 
			4'b0010: led = 7'b0010010; // "2" 
			4'b0011: led = 7'b0000110; // "3" 
			4'b0100: led = 7'b1001100; // "4" 
			4'b0101: led = 7'b0100100; // "5" 
			4'b0110: led = 7'b0100000; // "6" 
			4'b0111: led = 7'b0001111; // "7" 
			4'b1000: led = 7'b0000000; // "8"  
			4'b1001: led = 7'b0000100; // "9" 
			default: led = 7'b0000001; // "0"
		endcase
	end
    always@(*)
    begin

    end
    endmodule

