// External LED GPIO unit for breadboard LEDs
// address of EXT_LED reg is 0x8000_0000
module ext_led_gpio(
    input [31:0] addr,
    input rst, clk,
    input [31:0] data_in,
    input rd_strobe,
    input [3:0] wr_strobe,
    output reg [31:0] data_out,
    output [4:0] leds
  );

  reg [31:0] ext_led_data_reg;

  always @(posedge clk)
  begin
    if(rst)
      ext_led_data_reg <= 0;
    else if(rd_strobe)
      data_out <= ext_led_data_reg;
    else if(|wr_strobe)
      ext_led_data_reg <= data_in;
  end

  assign leds = ext_led_data_reg[4:0];  // Assuming active high
endmodule