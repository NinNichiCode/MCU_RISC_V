//UART GPIO unit to control UART transmitter
//address range: DATA: 0x2000-0000
//CTRL: 0x3000-0000
// STATUS: 0x4000-0000
//`include "uart_tx.v"
module  uart_tx_gpio(
    input [31:0] addr,
    input rst, clk,
    input [31:0] data_in,
    input rd_strobe,
    input [3:0] wr_strobe,
    output reg [31:0] data_out,
    output tx_pin
  );

  reg [31:0] uart_data, uart_control;
//reg o_ready_reg;

  //flags
  wire isUART_DATA= (addr[31:28]==4'b0010);
  wire isUART_CTRL= (addr[31:28]==4'b0011);
  wire isUART_STATUS= (addr[31:28]==4'b0100);

    wire o_ready;
    wire valid = uart_control[0];
    wire [7:0] tx_data = uart_data[7:0];

  initial
  begin
    uart_data <= 0;
    uart_control <= 0;
  end

  always @(posedge clk)
  begin
    if(rst)
    begin
      uart_data <= 0;
      uart_control <= 0;
    end

     if(rd_strobe && isUART_STATUS) begin
      
      data_out <= {31'h0,o_ready};
      //data_out <= 0; //valid for one cycle
      end
    
   if(|wr_strobe && isUART_DATA) 
      uart_data <= data_in;
   
   if(|wr_strobe && isUART_CTRL) begin 
      uart_control <= data_in;
      //uart_control <= 0; //only valid for 1 cycle 
    end
  end

  //Instantiate UART transmitter module here
  uart_tx tx0(.i_clk(clk), .i_rst(rst),
              .i_data(tx_data),
              .i_valid(valid),
              .o_ready(o_ready),
              .o_uart_tx(tx_pin)
             );


  endmodule

