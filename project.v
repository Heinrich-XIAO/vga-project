/*
 * Blank VGA Project Template
 * 
 * This template provides a clean starting point for VGA projects
 * with the basic TinyTapeout structure and HSync/VSync generator included.
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD - correct pin assignment
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  // Instantiate the HSync/VSync generator
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // TODO: Add your VGA logic here!
  // Example: Generate a colorful test pattern to demonstrate VGA capabilities
  
  // Create some interesting visual patterns
  wire [2:0] zone_x = pix_x[8:6];  // Divide screen into 8 horizontal zones
  wire [2:0] zone_y = pix_y[8:6];  // Divide screen into 8 vertical zones
  
  // Generate moving patterns using frame counter (simulated with position)
  wire [7:0] pattern = pix_x[7:0] ^ pix_y[7:0];  // XOR pattern
  wire [7:0] checkerboard = (pix_x[5] ^ pix_y[5]) ? 8'hFF : 8'h00;
  wire [7:0] gradient_x = pix_x[9:2];  // Horizontal gradient
  wire [7:0] gradient_y = pix_y[8:1];  // Vertical gradient
  
  // Combine patterns based on screen zones
  wire [7:0] combined_pattern;
  assign combined_pattern = 
    (zone_x == 3'b000) ? gradient_x :          // Left: horizontal gradient
    (zone_x == 3'b001) ? gradient_y :          // Next: vertical gradient  
    (zone_x == 3'b010) ? pattern :             // Next: XOR pattern
    (zone_x == 3'b011) ? checkerboard :       // Next: checkerboard
    (zone_x == 3'b100) ? (gradient_x + gradient_y) : // Next: combined gradients
    (zone_x == 3'b101) ? (pattern + gradient_y) :    // Next: pattern + gradient
    (zone_x == 3'b110) ? ~pattern :            // Next: inverted XOR
    8'hFF;                                     // Right: white
  
  // Map the pattern to RGB channels with different emphasis
  assign R = video_active ? {combined_pattern[7:6]} : 2'b00;  // Red channel
  assign G = video_active ? {combined_pattern[5:4]} : 2'b00;  // Green channel  
  assign B = video_active ? {combined_pattern[3:2]} : 2'b00;  // Blue channel

endmodule

`default_nettype wire