$fn = $preview ? 50 : 200;
step = $preview ? 10 : 2;

block_size = 30;
pin_spacing = 3;
pin_radius = 0.5;
num_pins = block_size/pin_spacing - 1;

difference() {
  cube(block_size);

  for (i = [1:num_pins]) {
    for (j = [1:num_pins]) {
      translate([i*pin_spacing, j*pin_spacing, 0]) pin_hole();
    }
  }
}

module pin_hole() {
  translate([0, 0, -0.5]) cylinder(block_size + 1, pin_radius, pin_radius);
}