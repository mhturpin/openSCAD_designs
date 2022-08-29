include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>
use <involute_gears.scad>

module mask(width, height, inner_width, inner_height, thickness) {
  difference() {
    cube([width, height, thickness], center=true);
    cube([inner_width, inner_height, thickness+.1], center=true);
  }
}

$fn = 200;
$vpd = 350;
$vpr = [0, 0, 0];
$vpt = [0, 20, 0];

thickness = 25;

//difference() {
//  // Pitch diameter = 3*96 = 288
//  // Pitch radius = 144
//  // Move so cut bottom is on the x axis
//  translate([0, -128, 0]) gear(pressure_angle=25, mod=3, num_teeth=96);
//  translate([0, 17, 0.5]) mask(300, 600, 128, 34, 1.1);
//}
//
//// Pitch radius = 34-(144-128) = 18
//// Pitch diameter = 36
//translate([0, 34, 0]) rotate(15) gear(pressure_angle=25, mod=3, num_teeth=12);

difference() {
  // Pitch diameter = 3*98 = 294
  // Pitch radius = 147
  // Move so cut bottom is on the x axis
  translate([0, -128, 0]) gear(pressure_angle=25, mod=3, num_teeth=98, thickness=thickness, backlash=0.2);
  translate([0, 17, thickness/2]) mask(300, 600, 119, 34, thickness + 0.1);
  // Add threaded holes
  // Holes on nutcracker base 1mm off (one side 10mm, other 11mm)
  translate([32.5, 3.574, 12]) rotate([90, 0, 0]) threaded_rod(6.39, 7.15, 1.27);
  translate([-32.5, 3.574, 12]) rotate([90, 0, 0]) threaded_rod(6.39, 7.15, 1.27);
}

// Pitch radius = 34-(147-128) = 15
// Pitch diameter = 30
translate([0, 34, 0]) rotate(18) gear(pressure_angle=25, mod=3, num_teeth=10, hole_diameter=8.15, thickness=thickness);

