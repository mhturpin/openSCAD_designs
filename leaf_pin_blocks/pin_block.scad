$fn = $preview ? 50 : 200;
step = $preview ? 10 : 2;

disk_radius = 5/16*25.4;
pin_height = 13.7;
pin_spacing = 3;
pin_radius = 0.6;
extra_radius = 10;
screw_radius = 1.8;
screw_head_radius = 6;
screw_head_height = 4;
cap_thickness = 5;

module pin_holder() {
  difference() {
    // Height of body is pin_height + 1 to keep the tips from protruding
    cylinder(pin_height + 1, disk_radius + extra_radius, disk_radius + extra_radius);

    // Cavity
    // 3.5mm to account for +1 on body height, pin head height, and ~2 for protrusion to poke the leaves
    translate([0, 0, -0.1]) cylinder(3.6, disk_radius + extra_radius/2 + 0.2, disk_radius + extra_radius/2 + 0.2);

    // Cut out in case the leaf gets stuck to the pins
    translate([0, -1.75, -0.1]) cube([disk_radius + extra_radius + 2, 3.5, 3.6]);

    // Pin holes
    // r is the row of dots
    for (r = [0:5]) {
      // i is the pin hole index within the row
      for (i = [1:5]) {
        distance = pin_spacing*sqrt(i^2 + i*r + r^2);
        angle_offset = asin((r*sqrt(3))/(2*sqrt(i^2 + i*r + r^2)));

        if (distance < disk_radius - pin_spacing/2) {
          for (j = [0:5]) {
            rotate(angle_offset + j*60) translate([distance, 0, 0]) pin_hole();
          }
        }
      }
    }

    // Holes for screws
    for (i = [0:3]) {
      rotate(i*90) translate([disk_radius + extra_radius/2, 0, 4]) cylinder(pin_height, screw_radius, screw_radius);
    }
  }
}

module pin_hole() {
  translate([0, 0, -0.5]) cylinder(pin_height + 2, pin_radius, pin_radius);
}

module base() {
  // Base
  cylinder(cap_thickness, disk_radius + extra_radius, disk_radius + extra_radius);

  // Centering ring
  difference() {
    cylinder(cap_thickness + 3, disk_radius + extra_radius/2, disk_radius + extra_radius/2);
    translate([0, 0, cap_thickness + 2]) cylinder(1.1, disk_radius + 0.2, disk_radius + 0.2);
    
    // Cut out in case the leaf gets stuck in the ring
    translate([0, -1.75, cap_thickness + 2]) cube([disk_radius + extra_radius, 3.5, 2]);
  }
}

module top() {
  difference() {
    cylinder(cap_thickness, disk_radius + extra_radius, disk_radius + extra_radius);

    // Holes for screws
    for (i = [0:3]) {
      rotate(i*90) translate([disk_radius + extra_radius/2, 0, -0.1]) {
        cylinder(cap_thickness + 2, screw_radius, screw_radius);
        cylinder(screw_head_height, screw_head_radius, screw_radius);
      }
    }
  }
}


pin_holder();
translate([2*(disk_radius + extra_radius) + extra_radius, 0, 0]) base();
translate([0, 2*(disk_radius + extra_radius) + extra_radius, 0]) top();








