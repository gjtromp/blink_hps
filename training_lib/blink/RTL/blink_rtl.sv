module blink (
    input logic clk50m,
    input logic reset_n,
    output logic led
);

logic [27:0] counter;

always @(posedge clk50m or negedge reset_n) begin
    if (~reset_n)
    begin
        counter <= 0;
	led <= 1'b0;
    end
    else
    begin
        if (counter == 0) begin
            counter <= 49999999;
            led <= ~led;
        end else begin
            counter <= counter - 1;
        end
    end
end

endmodule : blink
