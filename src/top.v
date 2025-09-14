// ** Top module to receive character from serial port and display pressed character and
//If character is number 0-9 then display the same in LED
module top(
    input rst, clk,
    input uart_rx,
    output uart_tx, 
    output [5:0] LEDS,
    output [4:0] ext_leds
  );
  wire [31:0] mem_rdata, mem_wdata, addr;
  wire rstrb;
  wire [3:0] wr_strobe;
  wire [31:0] uart_txstatus, uart_rx_data;
//select device
  wire isMEM = (addr[31:28]==4'b0000);
  wire isLED = (addr[31:28]==4'b0001);
  wire isUART_RXDATA= (addr[31:28]==4'b0101);
  wire isUART_RXSTATUS= (addr[31:28]==4'b0111);
  wire isUART_TXSTATUS= (addr[31:28]==4'b0100);
  wire isEXT_LED = (addr[31:28]==4'b1000);

//Selecting input data to CPU from memory or peripheral devices based on address
  wire [31:0] cpu_rdata = isUART_TXSTATUS ? uart_txstatus: 
                          isLED ? led_rdata :
                          isEXT_LED ? ext_led_rdata :
                          isMEM ? mem_rdata:
                          (isUART_RXSTATUS|isUART_RXDATA) ? uart_rx_data:32'h0;

wire [7:0] leds;
assign LEDS = ~leds[5:0];//mapping leds to physical port of FPGA LED
  
//Instantiate sub modules
// Mapping CPU
  cpu cpu0(
        .rst(!rst), .clk(clk),
        .mem_rdata(cpu_rdata),
        .mem_addr(addr),
        .cycle(),
        .mem_rstrb(rstrb),
        .mem_wdata(mem_wdata),
        .mem_wstrb(wr_strobe)
      );

//Mapping Program memory
  progmem mem0(
            .rst(!rst), .clk(clk),
            .addr(addr),
            .data_in(mem_wdata),
            .rd_strobe(rstrb & isMEM),
            .wr_strobe(wr_strobe & {4{isMEM}}),
            .data_out(mem_rdata)
          );

// Mapping UART Transmitter GPIO
  uart_tx_gpio uart_tx0(
                .rst(!rst), .clk(clk),
                .addr(addr),
                .data_in(mem_wdata),
                .rd_strobe(rstrb ),
                .wr_strobe(wr_strobe),
                .data_out(uart_txstatus),
                .tx_pin(uart_tx)
                );
// Mapping UART Receiver GPIO
 uart_rx_gpio uart_rx0(.rst(!rst), .clk(clk),
                .addr(addr),
                .data_in(mem_wdata),
                .rd_strobe(rstrb ),
                .wr_strobe(wr_strobe),
                .data_out(uart_rx_data),
                .uart_rx(uart_rx)
                );

// Mapping LED GPIO (on-board)
led_gpio led0(.rst(!rst), .clk(clk),
                .addr(addr),
                .data_in(mem_wdata),
                .rd_strobe(rstrb & isLED),
                .wr_strobe(wr_strobe & {4{isLED}}),
                .data_out(led_rdata),
                .leds(leds)
                );

// Mapping External LED GPIO (breadboard)
ext_led_gpio ext_led0(.rst(!rst), .clk(clk),
                .addr(addr),
                .data_in(mem_wdata),
                .rd_strobe(rstrb & isEXT_LED),
                .wr_strobe(wr_strobe & {4{isEXT_LED}}),
                .data_out(ext_led_rdata),
                .leds(ext_leds)
                );

  
endmodule