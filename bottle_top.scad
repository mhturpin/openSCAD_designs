include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/bottlecaps.scad>
include <../libraries/BOSL2/threading.scad>

$fn = $preview ? 50 : 200;

spout_angle = 60;
spout_height = 20;
spout_length = 15.25/sin(spout_angle);
spout_inner_r = 1;
spout_outer_r = 4;

module cap() {
  difference() {
    union() {
      pco1810_cap(texture="ribbed");
      translate([0, 0, -8]) cylinder(8, 6, 16);
    }

    translate([0, 0, -10]) cylinder(15, 5, 5);
  }
  
  // od, id, h, pitch (5/16-18 bolt)
  translate([0, 0, -3]) threaded_nut(10, 8.3, 10, 1.41);
}

module tube_corner(radius, angle) {
  intersection() {
    hull() {
      cylinder(radius, radius, radius, center=true);
      rotate([0, -angle, 0]) cylinder(radius, radius, radius, center=true);
    }
    
    cylinder(3*radius, radius, radius, center=true);
    rotate([0, -angle, 0]) cylinder(3*radius, radius, radius, center=true);
  }
}

module spout() {
  difference() {
    // Outer section
    union() {
      cylinder(spout_height, spout_outer_r, spout_outer_r);
      x1 = spout_length*sin(spout_angle);
      y1 = spout_height - spout_length*cos(spout_angle);
      translate([x1, 0, y1]) rotate([0, -spout_angle, 0]) cylinder(spout_length, spout_outer_r, spout_outer_r);
      translate([0, 0, spout_height]) tube_corner(spout_outer_r, spout_angle);
      // d, l, pitch (5/16-18 bolt)
      translate([0, 0, -5]) threaded_rod(7.94, 10, 1.41);
    }

    // Inner section
    translate([0, 0, -10.001]) cylinder(spout_height+10, spout_inner_r, spout_inner_r);
    x2 = spout_length*sin(spout_angle);
    y2 = spout_height - spout_length*cos(spout_angle);
    translate([x2, 0, y2]) rotate([0, -spout_angle, 0]) translate([0, 0, -0.001]) cylinder(spout_length, spout_inner_r, spout_inner_r);
    translate([0, 0, spout_height]) tube_corner(spout_inner_r, spout_angle);
  }
}


cap();
translate([25, 0, 0]) spout();

