include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>
use <involute_gears.scad>

$fn = $preview ? 10 : 200;
$vpd = 400;
$vpr = [0, 0, 0];
$vpt = [0, 40, 0];

// Parameters
thickness = 25;
top_teeth = 8;
pressure_angle = 28;
mod = 3;
base_height = 128; // From the center of the bottom pivot to the flat where the base gear section sits
arm_radius = 162; // From the center of the bottom pivot to the center of the top pivot
top_bolt_diameter = (5/16)*25.4;
flat_length = 120.4; // Length of the flat part that the base gear is bolted to
flat_width = 27.75; // Width of the flat part that the base gear is bolted to
base_length = 119; // The length of the base gear
bolt_clearance = 0.2;
base_bolt_diameter = (1/4)*25.4;
base_bolt_depth = 8; // Depth of the hole in the base gear
base_bolt_mm_per_thread = 25.4/20; // 20 threads per inch
// With the jaws on the left
back_hole_1_x = 33.6; // Distance from the left edge of the flat to the back of first hole
back_hole_2_x = 98.5; // Distance from the left edge of the flat to the back of second hole
hole_1_center_y = 14.34; // Distance from the edge closest to you to the center of the first hole
hole_2_center_y = 14.16; // Distance from the edge closest to you to the center of the second hole
distance_between_arms = 32;
arm_width = 19.5;

// Calculated variables
base_teeth = 2*arm_radius/mod - top_teeth;
root_radius = 3*top_teeth/2 - 1.25*3;
washer_thickness = (distance_between_arms - thickness)/2;
washer_radius = top_bolt_diameter/2 + 2;
half_arm = arm_width/2;
half_gear = thickness/2;


module base_piece() {
  difference() {
    intersection() {
      // Move so cut bottom is on the x axis
      translate([0, -base_height, 0]) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=base_teeth, thickness=thickness, backlash=0.2);
      translate([-base_length/2, 0, 0]) cube([base_length, arm_radius-base_height, thickness]);
    }

    // Add threaded holes
    x1 = flat_length/2 - back_hole_1_x + base_bolt_diameter/2;
    x2 = back_hole_2_x - flat_length/2 - base_bolt_diameter/2;
    y = base_bolt_depth/2 - 0.001;
    z1 = flat_width - hole_1_center_y - (flat_width - thickness)/2;
    z2 = flat_width - hole_2_center_y - (flat_width - thickness)/2;

    d = base_bolt_diameter+2*bolt_clearance;
    translate([-x1, y, z1]) rotate([90, 0, 0]) threaded_rod(d, base_bolt_depth, base_bolt_mm_per_thread);
    translate([x2, y, z2]) rotate([90, 0, 0]) threaded_rod(d, base_bolt_depth, base_bolt_mm_per_thread);
  }
}

module top_piece() {
  difference() {
    union() {
      intersection() {
        translate([0, 0, -thickness/2]) rotate(22.5) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=top_teeth, thickness=thickness);
        top_gear_mask();
      }

      translate([0, root_radius, 0]) rotate([-90, 0, 0]) hull() {
        cube([root_radius*2, thickness, 0.001], center=true);
        translate ([0, 0, 30]) linear_extrude (0.001) circle (root_radius);
      }
  
      // Connect gear to tapered section
      translate([0, root_radius/2, 0]) cube([root_radius*2, root_radius, thickness], center=true);
      translate([0, 0, thickness/2]) washer_shape();
      // mirror([0, 0, 1]) translate([0, 0, thickness/2]) washer_shape();
    }

    // Gear center hole
    cylinder(thickness+10, 4, 4, center=true);
    // Hole for handle
    translate([0, root_radius, 0]) rotate([-90, 0, 0]) handle_connector();
  }

}

module handle_connector() {
  // 1/4 20 threaded rod
  // Outer diameter, length, thread width (length/# threads)
  translate([0, 0, 15.1]) threaded_rod(6.75, 30.2, 1.27);
}

module washer_shape() {
  cylinder(washer_thickness, washer_radius, washer_radius);

  // Connection between circle and tab
  a1 = 90 - acos(washer_radius/half_arm);
  x1 = -washer_radius*cos(a1);
  y1 = washer_radius*sin(a1);
  
  corner_d = sqrt(root_radius^2 + half_arm^2);
  a2 = acos(washer_radius/corner_d) - atan(half_arm/root_radius);
  x2 = washer_radius*cos(a2);
  y2 = -washer_radius*sin(a2);

  connector_points = [
    [x2, y2],
    [root_radius, half_arm],
    [0, half_arm],
    [x1, y1]
  ];

  translate([0, 0, -half_gear]) linear_extrude(washer_thickness+half_gear) {
    polygon(connector_points);
  }

  // Tab to catch handle and allow pulling jaws open
  translate([0, half_arm, -half_gear]) cube([root_radius, washer_thickness, 2*washer_thickness+half_gear]);

  // Tab support wedge
  wedge_points = [
    [0, half_arm+washer_thickness, -half_gear],
    [root_radius, half_arm+washer_thickness, -half_gear],
    [root_radius, half_arm+3*washer_thickness+half_gear, -half_gear],
    [0, half_arm+3*washer_thickness+half_gear, -half_gear],
    [0, half_arm+washer_thickness, 2*washer_thickness],
    [root_radius, half_arm+washer_thickness, 2*washer_thickness]
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
  // Add a little extra so surfaces don't touch and cause difference to render weird
  outer_radius = 3*top_teeth/2 + 3 + 1;
  cylinder(thickness+1, root_radius, root_radius, center=true);
  // Remove extra teeth
  rotate(-360/top_teeth) part_cylinder(outer_radius, 4*360/top_teeth, thickness+1);
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


base_piece();
translate([0, arm_radius-base_height, thickness/2]) top_piece();
// top_piece();
