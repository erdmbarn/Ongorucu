`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2024 23:31:41
// Design Name: 
// Module Name: ongorucu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ongorucu(
input clk,
input rst,
input [31:0] getir_ps,
input [31:0] getir_buyruk,
input getir_gecerli,
input [31:0] yurut_ps,
input [31:0] yurut_buyruk,
input yurut_dallan,
input [31:0] yurut_dallan_ps,
input  yurut_gecerli,
output reg sonuc_dallan,
output reg [31:0] sonuc_dallan_ps
 );
 
 
 // GShare Parametreleri
parameter GHR_SIZE = 3; // Global History Register boyutu
parameter PHT_SIZE = 8; // Pattern History Table boyutu, 2^GHR_SIZE

// GHR ve PHT tanýmlamalarý
reg [GHR_SIZE-1:0] GHR;
reg [1:0] PHT[PHT_SIZE-1:0]; // 2-bit saturating counter
/*reg signed[31:0] imm;
reg [12:0]imm1;*/
reg [31:0] instruction=0;
reg signed [31:0] extendedImm;
//reg  [31:0] extendedImm;
reg [31:0] BUYRUK;

wire [1:0] aaa; // 2-bit saturating counter
reg signed [31:0] ps;

assign aaa = PHT[GHR ^ getir_ps[GHR_SIZE-1:0]];

// PHT ve GHR'yi baþlangýç durumuna getir
integer i;
initial begin
    GHR = 0;
    for (i = 0; i < PHT_SIZE; i = i + 1) begin
        PHT[i] = 2'b01; // Weakly Not Taken 01
    end
end
always @ * begin
if (getir_gecerli) begin
        // Öngörü yap
       // BUYRUK=getir_buyruk;
        instruction=getir_buyruk;
        ps=getir_ps;
        sonuc_dallan = PHT[GHR ^ getir_ps[GHR_SIZE-1:0]][1];
        if(sonuc_dallan)begin
        
       /*  imm1=0;
         imm1[12]=BUYRUK[31];
         imm1[10:5]=BUYRUK[30:25];
         imm1[4:1]=BUYRUK[11:8];
         imm1[11]=BUYRUK[7];
         imm=imm1;*/
         extendedImm[12] = instruction[31];
                                extendedImm[11] = instruction[7];
                                extendedImm[10:5] = instruction[30:25];
                                extendedImm[4:1] = instruction[11:8];
                                extendedImm[0] = 1'b0;                        // This line of code very importanrt pay attention to this
                                if(extendedImm[12] == 0)
                                    extendedImm[31:13] = 19'b0000000000000000000;
                                else
                                    extendedImm[31:13] = 19'b1111111111111111111;    
         //sonuc_dallan_ps = getir_ps + imm;
         $display("extendedImm is %h", instruction);
         $display("extendedImm is %d", extendedImm);
       $display("getir_ps is %h", getir_ps);
         //sonuc_dallan_ps = getir_ps + extendedImm;
    //  sonuc_dallan_ps = 32'h80000010;
     sonuc_dallan_ps = ps + extendedImm;    
        end else begin
        sonuc_dallan_ps = getir_ps + 4; 
        end
        
    end

   if (yurut_gecerli) begin
    /*   $display("sonuc dallan is %d", sonuc_dallan);
       $display("yurut dallan is %d", yurut_dallan);*/
        // Gerçek dallanma sonucuna göre GHR ve PHT güncelle
        GHR = {GHR[GHR_SIZE-2:0], yurut_dallan};
        if (yurut_dallan) begin
            if (PHT[GHR ^ yurut_ps[GHR_SIZE-1:0]] < 2'b11) PHT[GHR ^ yurut_ps[GHR_SIZE-1:0]] = PHT[GHR ^ yurut_ps[GHR_SIZE-1:0]] + 1;
        end else begin
            if (PHT[GHR ^ yurut_ps[GHR_SIZE-1:0]] > 2'b00) PHT[GHR ^ yurut_ps[GHR_SIZE-1:0]] = PHT[GHR ^ yurut_ps[GHR_SIZE-1:0]] - 1;
        end
    end


end

always @(posedge clk) begin
 if (!rst) begin
        // Reset durumu
        GHR = 0;
        for (i = 0; i < PHT_SIZE; i = i + 1) begin
            PHT[i] = 2'b01;
        end
    end 
    
end
endmodule
