include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>
use <involute_gears.scad>

$fn = $preview ? 100 : 200;
//$vpd = 200;
//$vpr = [0, 0, 0];
//$vpt = [0, 40, 0];

thickness = 25;

module base_piece() {
  difference() {
    // Pitch diameter = 3*98 = 294
    // Pitch radius = 147
    // Move so cut bottom is on the x axis
    translate([0, -128, 0]) gear(pressure_angle=25, mod=3, num_teeth=98, thickness=thickness, backlash=0.2);
    translate([0, 17, thickness/2]) base_gear_mask(300, 600, 119, 34, thickness + 0.1);
    // Add threaded holes
    // Holes on nutcracker base 1mm off (one side 10mm, other 11mm)
    // 1/4 inch, 10 threads/half inch, 0.2mm clearance
    translate([32.5, 3.574, 12]) rotate([90, 0, 0]) threaded_rod(6.75, 7.15, 1.27);
    translate([-32.5, 3.574, 12]) rotate([90, 0, 0]) threaded_rod(6.75, 7.15, 1.27);
  }
}

module top_piece() {
  difference() {
    union() {
      // Pitch radius = 34-(147-128) = 15
      // Pitch diameter = 30
      // 5/16 inch hole = 7.9375mm
      translate([0, 0, -thickness/2]) rotate(18) gear(pressure_angle=25, mod=3, num_teeth=10, hole_diameter=7.94, thickness=thickness);

      // 1/2 inch rod = 12.7mm, 2mm boundry = 16.7mm square
      translate([0, 8, 0]) rotate([-90, 0, 0]) trapezoid([17.5, thickness], [16.7, 16.7], 30);
    }
    translate([0, 38.2, 0]) rotate([90, 0, 0]) cylinder(30.2, 6.45, 6.45);
  }
}

module washer() {
  // 1 3/16 inch between arms
  // 5/16 inch hole = 7.9375mm
  difference() {
    cylinder(2.6, 8, 8, center=true);
    cylinder(2.8, 4, 4, center=true);
  }
}

module trapezoid(base, top, height) {
  points = [
    [base[0]/2, base[1]/2, 0],
    [base[0]/2, -base[1]/2, 0],
    [-base[0]/2, -base[1]/2, 0],
    [-base[0]/2, base[1]/2, 0],
    [top[0]/2, top[1]/2, height],
    [top[0]/2, -top[1]/2, height],
    [-top[0]/2, -top[1]/2, height],
    [-top[0]/2, top[1]/2, height]];
  faces = [
    [0,1,2,3],
    [4,5,1,0],
    [7,6,5,4],
    [5,6,2,1],
    [6,7,3,2],
    [7,4,0,3]];

  polyhedron(points, faces, convexity=2);
}

module base_gear_mask(width, height, inner_width, inner_height, thickness) {
  difference() {
    cube([width, height, thickness], center=true);
    cube([inner_width, inner_height, thickness+.1], center=true);
  }
}

module top_gear_mask() {
  root_radius = 3*10/2 - 1.25*3;
  echo(root_radius);
  cylinder(thickness+1, root_radius, root_radius, center=true);
}

//base_piece();
//translate([0, 34, 0])
top_piece();
top_gear_mask();
//washer();



