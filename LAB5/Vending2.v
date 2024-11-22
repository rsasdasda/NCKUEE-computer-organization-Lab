module Vending(clk, rst, DI, MI, sel, re, MO, PO);
    input re;
    input clk;
    input rst;

    input [7:0] DI;
    input [7:0] MI;
    input [1:0] sel;
    
    output reg [7:0] MO;
    output reg [1:0] PO;


    parameter IDLE = 2'd0, Read = 2'd1, Seal = 2'd2;

    reg [1:0] state, next_state;
    reg [7:0] price_A, price_B, price_C;
    reg [1:0] item;
    reg [7:0] coin, next_coin;
    reg [7:0] cur_price;
    reg buy;

    //state
    always @(posedge clk or negedge rst)
    begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    //next_state
    always @(*)
    begin
        case(state)
        IDLE: next_state = Read;
        Read: begin
            if(item == 2'd2) next_state = Seal;
            else next_state = Read;
        end
        Seal: next_state = Seal;
        default: next_state = IDLE; 
        endcase
    end

    //item
    always @(posedge clk or negedge rst)
    begin
        if(rst) item <= 2'd0;
        else if(state == Read) begin
            item <= item + 2'd1;
        end
        else item <= 2'd0;
    end

    //price
    always @(posedge clk or negedge rst)
    begin
        if(rst) begin
            price_A <= 8'd0;
            price_B <= 8'd0;
            price_C <= 8'd0;
        end
        else if(state == Read) begin
            if(item == 2'd0) begin
                price_A <= DI;
                price_B <= price_B;
                price_C <= price_C;
            end
            else if(item == 2'd1) begin
                price_A <= price_A;
                price_B <= DI;
                price_C <= price_C;
            end
            if(item == 2'd2) begin
                price_A <= price_A;
                price_B <= price_B;
                price_C <= DI;
            end
        end
        else begin
            price_A <= price_A;
            price_B <= price_B;
            price_C <= price_C;
        end
    end

    //coin
    always @(posedge clk or negedge rst)
    begin
        if(rst) coin <= 8'd0;
        else if(state == Seal) begin
            if(re) coin <= 8'd0;
            else if(buy && PO != 2'd0) coin <= MI;
            else coin <= coin + MI;
        end
        else coin <= coin;
    end

    always @(*)
    begin
        if(sel && MI && PO) next_coin = MI;
        else if(sel && MI) next_coin = coin + MI;
        else next_coin = MI;
    end

    //cur_price
    always @(*)
    begin
        if(state == Seal) begin
            if(sel == 2'd1) cur_price = price_A;
            else if(sel == 2'd2) cur_price = price_B;
            else if(sel == 2'd3) cur_price = price_C;
            else cur_price = 8'd0;
        end
        else cur_price = 8'd0;
    end

    //buy
    always @(posedge clk or negedge rst)
    begin
        if(rst) buy <= 1'b0;
        else if(sel != 2'b0) buy <= 1'b1;
        else buy <= 1'b0;
    end

    //PO
    always @(posedge clk or negedge rst)
    begin
        if(rst) PO <= 2'd0;
        else if(state == Seal && re) PO <= 2'd0;
        else if(state == Seal && sel != 2'b0) begin
            if(sel && MI && next_coin < cur_price) PO <= 2'd0;
            else if(sel && MI && next_coin >= cur_price) PO <= sel;
            else if(coin >= cur_price) PO <= sel;
            else PO <= 2'd0;
        end
        else PO <= 2'd0;
    end

    //MO
    always @(posedge clk or negedge rst)
    begin
        if(rst) MO <= 8'd0;
        else if(state == Seal && re) MO <= coin + MI;
        else if(state == Seal && sel != 2'b0) begin
            if(sel && MI && next_coin < cur_price) MO <= 8'd0;
            else if(sel && MI && next_coin >= cur_price) MO <= next_coin - cur_price;
            else if(buy && coin < cur_price) MO <= 8'd0;
            else if(coin >= cur_price) MO <= coin - cur_price;
            else MO <= coin;
        end
        else MO <= 8'd0;
    end

endmodule
