include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>
use <involute_gears.scad>

$fn = $preview ? 100 : 200;
$vpd = 400;
$vpr = [0, 0, 0];
$vpt = [0, 40, 0];

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
    // back - 31/32 from end = 24.61
    // front - 38/32 from end = 30.16
    // 4.75 long = 120.65mm
    x1 = 120.65/2 - 24.61;
    x2 = 120.65/2 - 30.16;

    translate([x1, 3.574, 12]) rotate([90, 0, 0]) threaded_rod(6.75, 7.15, 1.27);
    translate([-x2, 3.574, 12]) rotate([90, 0, 0]) threaded_rod(6.75, 7.15, 1.27);
  }
}

module top_piece() {
  difference() {
    union() {
      intersection() {
        // Pitch radius = 34-(147-128) = 15
        // Pitch diameter = 30
        // 5/16 inch hole = 7.9375mm
        translate([0, 0, -thickness/2]) gear(pressure_angle=25, mod=3, num_teeth=10, hole_diameter=8, thickness=thickness);
        top_gear_mask();
      }

      // 1/2 inch rod = 12.7mm, 2mm boundry = 16.7mm square
      translate([0, 7, 0]) rotate([-90, 0, 0]) trapezoid([17.5, thickness], [16.7, 16.7], 30);
    }
    translate([0, 38.2, 0]) rotate([90, 0, 0]) cylinder(30.2, 6.45, 6.45);
  }
  
  translate([0, 0, thickness/2]) washer();
  mirror([0, 0, 1]) translate([0, 0, thickness/2]) washer();
}

module washer() {
  // 1 3/16 inch between arms
  // 5/16 inch hole = 7.9375mm
  // distance to tab (half arm width) = 9.6
  h = 2.6;
  r = 6;
  d = 9.6;

  difference() {
    cylinder(h, r, r);
    translate([0, 0, -0.1]) cylinder(h + 0.2, 4, 4);
  }

  root_radius = 3*10/2 - 1.25*3;
  // Tab to catch handle and allow pulling jaws open
  translate([0, d, h]) cube([r, h, h]);

  a = 90 - acos(6/(d+h));
  x = -r*cos(a);
  y = r*sin(a);

  points = [
    [r, 0],
    [r, d+h],
    [0, d+h],
    [x, y],
    [0, r]
  ];

  // Add extra depth so there aren't gaps
  translate([0, 0, -h]) linear_extrude(2*h) {
    polygon(points);
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
  outer_radius = 3*10/2 + 3 + 1; // add a little extra for difference
  cylinder(thickness+1, root_radius, root_radius, center=true);
  // remove 6 teeth 1 tooth = 360/10 = 36 degrees
  rotate(-54) part_cylinder(outer_radius, 36*6, thickness+1);
}

module part_cylinder(r, angle, height) {
  rotate(floor(angle/90)*90) difference() {
    cylinder(height, r, r, center=true);

    translate([0, 0, -height/2-1]) union() {
      points = [
        [0, 0, 0],
        [2*r, 0, 0],
        [2*r*cos(angle%90), 2*r*sin(angle%90), 0],
        [0, 0, height+2],
        [2*r, 0, height+2],
        [2*r*cos(angle%90), 2*r*sin(angle%90), height+2]];
      faces = [
        [0,1,2],
        [0, 3, 4, 1],
        [1, 4, 5, 2],
        [0, 2, 5, 3],
        [3, 4, 5]];

      polyhedron(points, faces, convexity=2);

      for (i = [1:angle/90]) {
        translate([(i > 1 ? -1 : 0)*(height+2), (i < 3 ? -1 : 0)*(height+2), 0]) cube(height+2);
      }
    }
  }
}


base_piece();
//top_piece();


