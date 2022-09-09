include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>
use <involute_gears.scad>

$fn = $preview ? 100 : 200;
$vpd = 400;
$vpr = [0, 0, 0];
$vpt = [0, 40, 0];

thickness = 25;
teeth_1 = 8;
teeth_2 = 108 - teeth_1;
root_radius = 3*teeth_1/2 - 1.25*3;

module base_piece() {
  difference() {
    intersection() {
      // Pitch diameter = 3*98 = 294
      // Pitch radius = 147
      // Move so cut bottom is on the x axis
      translate([0, -128, 0]) gear(pressure_angle=28, mod=3, num_teeth=teeth_2, thickness=thickness, backlash=0.2);
      translate([-119/2, 0, 0]) cube([119, 34, thickness]);
    }

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
        translate([0, 0, -thickness/2]) rotate(22.5) gear(pressure_angle=28, mod=3, num_teeth=teeth_1, thickness=thickness);
        top_gear_mask();
      }

      translate([0, root_radius, 0]) rotate([-90, 0, 0]) hull() {
        cube([16.5, thickness, 0.001], center=true);
        translate ([0, 0, 30]) linear_extrude (0.001) circle (8.25);
      }

      translate([0, root_radius/2, 0]) cube([16.5, root_radius, thickness], center=true);
      translate([0, 0, thickness/2]) washer_shape();
      //mirror([0, 0, 1]) translate([0, 0, thickness/2]) washer_shape();
    }

    cylinder(thickness+10, 4, 4, center=true); // Gear center hole
    translate([0, root_radius, 0]) rotate([-90, 0, 0]) handle_connector(); // Hole for handle
  }

}

module handle_connector() {
  //cylinder(30.2, 6.75, 6.75);
  linear_extrude(30.2) hexagon(4.1);
}

module washer_shape() {
  // 1 3/16 inch between arms
  // 5/16 inch hole = 7.9375mm
  // distance to tab (half arm width) = 9.6
  height = 2.6; // Height of washer
  r = 6; // Outer radius of washer
  d = 9.6; // Distance from center of hole to edge of arm
  half_gear = thickness/2;

  cylinder(height, r, r);

  // Connection between circle and tab
  a1 = 90 - acos(r/d);
  x1 = -r*cos(a1);
  y1 = r*sin(a1);
  
  corner_d = sqrt(root_radius^2 + d^2);
  a2 = acos(r/corner_d) - atan(d/root_radius);
  x2 = r*cos(a2);
  y2 = -r*sin(a2);

  connector_points = [
    [x2, y2],
    [root_radius, d],
    [0, d],
    [x1, y1]
  ];

  translate([0, 0, -half_gear]) linear_extrude(height+half_gear) {
    polygon(connector_points);
  }

  // Tab to catch handle and allow pulling jaws open
  translate([0, d, -half_gear]) cube([root_radius, height, 2*height+half_gear]);

  // Tab support wedge
  wedge_points = [
    [0, d+height, -half_gear],
    [root_radius, d+height, -half_gear],
    [root_radius, d+3*height+half_gear, -half_gear],
    [0, d+3*height+half_gear, -half_gear],
    [0, d+height, 2*height],
    [root_radius, d+height, 2*height]
  ];
  faces = [
  [0, 1, 2, 3],
  [0, 4, 5, 1],
  [1, 5, 2],
  [5, 4, 3, 2],
  [0, 3, 4]
  ];
  polyhedron(wedge_points, faces);
}

module top_gear_mask() {
  outer_radius = 3*teeth_1/2 + 3 + 1; // add a little extra for difference
  cylinder(thickness+1, root_radius, root_radius, center=true);
  // remove teeth, 1 tooth = 360/8 = 45 degrees
  rotate(-45) part_cylinder(outer_radius, 4*360/teeth_1, thickness+1);
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

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}


//base_piece();
//translate([0, 34, thickness/2]) top_piece();
top_piece();
//washer_shape();

