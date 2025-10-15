$fn = $preview ? 50 : 200;
step = $preview ? 10 : 2;

disk_radius = 5/16*25.4;
pin_height = 12;
pin_spacing = 3;
pin_radius = 0.32 + 0.1;
extra_radius = 10;
screw_radius = 1;
screw_head_radius = 4.2;
screw_head_height = 4;
cap_thickness = 5;

module pin_holder() {
  difference() {
    // Body
    difference() {
      cylinder(pin_height, disk_radius + extra_radius, disk_radius + extra_radius);
      translate([0, 0, -0.5]) cylinder(3, disk_radius + extra_radius/2 + 0.1, disk_radius + extra_radius/2 + 0.1);
    }

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
  translate([0, 0, -0.5]) cylinder(pin_height + 1, pin_radius, pin_radius);
}

module base() {
  // Base
  cylinder(cap_thickness, disk_radius + extra_radius, disk_radius + extra_radius);
  
  // Centering ring
  difference() {
    cylinder(cap_thickness + 2, disk_radius + extra_radius/2, disk_radius + extra_radius/2);
    cylinder(cap_thickness + 3, disk_radius + 0.2, disk_radius + 0.2);
  }
}

module top() {
  difference() {
    cylinder(cap_thickness, disk_radius + extra_radius, disk_radius + extra_radius);

    // Holes for screws
    for (i = [0:3]) {
      rotate(i*90) translate([disk_radius + extra_radius/2, 0, -0.1]) {
        cylinder(cap_thickness + 2, screw_radius, screw_radius);
        cylinder(screw_head_radius, screw_head_radius, screw_radius);
      }
    }
  }
}

pin_holder();
translate([2*(disk_radius + extra_radius) + extra_radius, 0, 0]) base();
translate([0, 2*(disk_radius + extra_radius) + extra_radius, 0]) top();