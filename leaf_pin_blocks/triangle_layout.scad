$fn = $preview ? 50 : 200;
step = $preview ? 10 : 2;

block_size = 30;
pin_height = 3;
pin_spacing = 3;
pin_radius = 0.5;
x_pins = block_size/(pin_spacing*sqrt(3)/2) - 1;
y_pins = block_size/pin_spacing - 1;

difference() {
  cube([block_size, block_size, pin_height]);

  for (i = [1:x_pins]) {
    y_offset = i%2 == 0 ? pin_spacing/2 : 0;

    for (j = [1:y_pins]) {
      translate([i*pin_spacing*sqrt(3)/2, j*pin_spacing + y_offset - pin_spacing/4, 0]) pin_hole();
    }
  }
}

module pin_hole() {
  translate([0, 0, -0.5]) cylinder(block_size + 1, pin_radius, pin_radius);
}