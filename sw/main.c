// C program to test UART receiver with external LED control modes on breadboard
// Incoming data from serial terminal PUTTY
// Modes: 1 - Blink all 5 LEDs, 2 - Shift left with wraparound, 3 - Shift right with wraparound, 0 - Stop
// Continues from current LED state if not zero, else starts from initial
// Assumes 5 external LEDs (bits 0-4)
// FPGA tested

#include <stdint.h>
#include <stdlib.h>

//*** External LED Address mapping */
#define EXT_LED_ADDR 0x80000000  // starting addr of external LED
#define EXT_LED_DATA *((volatile unsigned int *)(EXT_LED_ADDR ))

//********** UART Transmitter Register address map *******
#define UART_DATA_ADDR 0x20000000  // starting addr of UART DATA REG
#define UART_DATA *((volatile unsigned int *)(UART_DATA_ADDR ))
#define UART_CTRL_ADDR 0x30000000  // starting addr of UART CTRL REG
#define UART_CTRL *((volatile unsigned int *)(UART_CTRL_ADDR ))
#define UART_STATUS_ADDR 0x40000000  // starting addr of UART status REG
#define UART_STATUS *((volatile unsigned int *)(UART_STATUS_ADDR ))

//******UART Receiver Register address mapping**************
#define UART_RXDATA_ADDR 0x50000000  // starting addr of UART DATA REG
#define UART_RXDATA *((volatile unsigned int *)(UART_RXDATA_ADDR ))
#define UART_RXCTRL_ADDR 0x60000000  // starting addr of UART CTRL REG
#define UART_RXCTRL *((volatile unsigned int *)(UART_RXCTRL_ADDR ))
#define UART_RXSTATUS_ADDR 0x70000000  // starting addr of UART status REG
#define UART_RXSTATUS *((volatile unsigned int *)(UART_RXSTATUS_ADDR ))

// Delay function
void delay(uint32_t cycles) {
    volatile uint32_t count = 0;  // volatile to prevent compiler optimization
    while (count < cycles) {
        count++;
    }
}

// UART function to send a single character
void uart_send(uint8_t my_char) {
    while(UART_STATUS == 0);
    UART_DATA = my_char;
    UART_CTRL = 1;
    UART_CTRL = 0;
}

// UART function to send a string
void uart_sendline(uint8_t *my_str) {
    for (uint8_t i = 0; my_str[i] != '\0'; i++) {
        uart_send(my_str[i]);
    }
}

// Check if UART receive data is ready (non-blocking)
// Returns 1 if data available, sets *data, else 0
int try_uart_receive(uint32_t *data) {
    if (UART_RXSTATUS == 0) {
        return 0;  // not ready
    }
    *data = UART_RXDATA;
    UART_RXCTRL = 1;  // ack
    UART_RXCTRL = 0;
    return 1;
}

// Driver program to test above function
int main(void) {
    uart_sendline("RISC-V UART External LED Control is ready\n\r");
    uart_sendline("Press 1: Blink all 5 external LEDs\n\r");
    uart_sendline("Press 2: Shift external LEDs to the left with wraparound\n\r");
    uart_sendline("Press 3: Shift external LEDs to the right with wraparound\n\r");
    uart_sendline("Press 0: Stop current mode\n\r");

    uint32_t mode = 0;  // 0: idle, 1: blink, 2: left shift, 3: right shift
    uint32_t led_state = 0;

    EXT_LED_DATA = 0;

    while (1) {
        uint32_t rx_data;
        if (try_uart_receive(&rx_data)) {
            char c = (char)rx_data;
            uart_sendline(" -> You pressed: ");
            uart_send(c);
            uart_sendline("\n\r");

            if (c == '1') {
                mode = 1;
                led_state = 0x1F;  // Start with all on for blink
            } else if (c == '2') {
                mode = 2;
                if (led_state == 0) {
                    led_state = 0x01;  // Start from LSB if zero for left shift
                }
            } else if (c == '3') {
                mode = 3;
                if (led_state == 0) {
                    led_state = 0x10;  // Start from MSB if zero for right shift
                }
            } else if (c == '0') {
                mode = 0;
                // Keep current LED state
            }
        }

        if (mode != 0) {
            if (mode == 1) {
                // Blink all on/off
                EXT_LED_DATA = led_state & 0x1F;
                led_state = (led_state == 0x1F) ? 0x00 : 0x1F;
            } else if (mode == 2) {
                // Shift left with wraparound
                EXT_LED_DATA = led_state & 0x1F;
                uint32_t msb = (led_state & 0x10) >> 4;  // Save bit 4
                led_state = ((led_state << 1) | msb) & 0x1F;  // Shift left, wrap MSB to LSB
            } else if (mode == 3) {
                // Shift right with wraparound
                EXT_LED_DATA = led_state & 0x1F;
                uint32_t lsb = led_state & 0x01;  // Save bit 0
                led_state = ((led_state >> 1) | (lsb << 4)) & 0x1F;  // Shift right, wrap LSB to MSB
            }
            delay(500000);  // Adjust delay for visible speed
        } else {
            delay(10000);  // Small delay in idle mode
        }
    }
    return 0;
}