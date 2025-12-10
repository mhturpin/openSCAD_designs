// This is designed to be assembled with sequin pins and #4 x 1/2" wood screws
// https://www.michaels.com/product/loops-threads-appliquesequin-pins-M10340868
// https://www.homedepot.com/p/Everbilt-4-x-1-2-in-Phillips-Flat-Head-Zinc-Plated-Wood-Screw-100-Pack-801742/204275520

$fn = $preview ? 50 : 200;
step = $preview ? 10 : 2;
$vpd = 250;
$vpr = [40, 0, 60];
$vpt = [25, 0, 10];


pin_spacing = 3;

disk_radius = 5/16*25.4;
pin_height = 13.7;
pin_head_height = 0.7;
pin_radius = 0.32;
extra_radius = 10;
screw_head_radius = 2.5;
screw_head_height = 2.5;
screw_radius = 1.42; // Outside diameter of threads
cap_thickness = 5;

module pin_holder() {
  difference() {
    // Height of body is pin_height + 0.5 to keep the tips from protruding
    // The height of the head is 0.5mm, so this will make the tips about 1mm below the edge
    cylinder(pin_height + 0.5, disk_radius + extra_radius, disk_radius + extra_radius);

    // Cavity
    // 3mm to account for +0.5 on body height, pin head height, and ~2 for protrusion to poke the leaves
    translate([0, 0, -0.1]) cylinder(3.1, disk_radius + extra_radius/2 + 0.1, disk_radius + extra_radius/2 + 0.1);

    // Cut out in case the leaf gets stuck to the pins
    translate([0, -1.75, -0.1]) cube([disk_radius + extra_radius + 2, 3, 3.1]);

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
    for (i = [0:2]) {
      rotate(i*120) translate([disk_radius + extra_radius/2, 0, 4]) cylinder(pin_height, screw_radius - 0.25, screw_radius - 0.25);
    }
  }
}

module pin_hole() {
  translate([0, 0, -1]) cylinder(pin_height + 2, pin_radius + 0.2, pin_radius + 0.2);
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
    for (i = [0:2]) {
      rotate(i*120) translate([disk_radius + extra_radius/2, 0, -0.1]) {
        // Relief for the rounded edge
        cylinder(1.01, screw_head_radius, screw_head_radius);
        // Tapered part of the head
        translate([0, 0, 1]) cylinder(screw_head_height - 1, screw_head_radius, screw_radius + 0.1);
        // Shaft
        cylinder(cap_thickness + 2, screw_radius + 0.1, screw_radius + 0.1);
      }
    }
    
    // Recess for pin heads
    translate([0, 0, cap_thickness - pin_head_height]) cylinder(pin_head_height + 0.1, disk_radius + 0.2, disk_radius + 0.2);
  }
}


pin_holder();
translate([2*(disk_radius + extra_radius) + extra_radius, 0, 0]) base();
translate([0, 2*(disk_radius + extra_radius) + extra_radius, 0]) top();


translate([30, 30, 0]) difference() {
  cube(6);

  translate([2, 2, -1]) cylinder(pin_height + 2, pin_radius, pin_radius);
  translate([2, 4, -1]) cylinder(pin_height + 2, pin_radius + 0.1, pin_radius + 0.1);
  translate([4, 2, -1]) cylinder(pin_height + 2, pin_radius + 0.2, pin_radius + 0.2);
  translate([4, 4, -1]) cylinder(pin_height + 2, pin_radius + 0.3, pin_radius + 0.3);
}





