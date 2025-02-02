/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_yannickreiss_stack (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[3:0]  = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = cell_output;
  assign uio_oe  = bus_io;


  // I/O ports
  wire push;
  wire pop;
  reg  instructionDone;
  reg[7:0] bus_io;
  reg parity;

  assign push = ui_in[7];
  assign pop  = ui_in[6];
  assign uo_out[7] = instructionDone;
  assign uo_out[6] = (stack_pointer == {7{1'b0}}) ? 1'b1 : 1'b0;
  assign uo_out[5] = (stack_pointer == {7{1'b1}}) ? 1'b1 : 1'b0;
  assign uo_out[4] = parity;

  // memory block
  reg [7:0] memory_block [0:127];
  reg [6:0] stack_pointer;
  reg [7:0] cell_output;

  // State machine
  reg [2:0] state; // 000: Idle, 001: push write, 010: push raise, 011: pull dec, 100: pull read cell

  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 1'b0)
        begin
          instructionDone <= 1'b1;
        end
    end

  // Set uio_oe according to state.
  always @*
    begin
      case (state)
        3'b001, 3'b010:
          bus_io = 8'b00000000;
        default:
          bus_io = 8'b11111111;
      endcase
    end

  // Read / write operation, depending on state
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 1'b1)
        begin
          case (state)
            3'b001:
              begin
                memory_block[stack_pointer] <= uio_in;
                stack_pointer = stack_pointer;
              end
            3'b010:
              begin
                stack_pointer <= stack_pointer + 1;
                memory_block[stack_pointer] <= memory_block[stack_pointer];
              end
            3'b011:
              begin
                stack_pointer <= stack_pointer - 1;
                memory_block[stack_pointer] <= memory_block[stack_pointer];
              end
            default:
              begin
                cell_output <= memory_block[stack_pointer];
                stack_pointer = stack_pointer;
              end
          endcase
        end
      else
        begin
          stack_pointer<= 7'b0;
          cell_output <= 8'b0;
          for (int i = 0; i < 128; i = i + 1)
            begin
              memory_block[i] = 8'h00;
            end
        end
    end

  // Update state on clock updates
  always @(posedge clk)
    begin
      if (state == 3'b000)
        begin
          if (push == 1'b1)
            begin
              state <= 3'b001;
            end
          else
            begin
              if (pop == 1'b0)
                begin
                  state <= 3'b011;
                end
              else
                begin
                  case (state)
                    3'b001:
                      state <= 3'b010;
                    3'b011:
                      state <= 3'b100;
                    default:
                      state <= 3'b000;
                  endcase
                end
            end
        end
      else begin
        state <= state;
      end
    end

integer i;
integer j;

always @(posedge clk) begin
    if (!rst_n) begin
        parity <= 1'b0;
    end
    else
        begin
            for (i = 0; i < 127; i = i + 1) begin
                for (j = 0; j < 7; j = j + 1) begin
                    parity <= parity ^ memory_block[i][j];
                end
            end
        end
end
endmodule
