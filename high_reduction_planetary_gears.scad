use <involute_gears.scad>

$fn = $preview ? 25 : 100;

mod = 2;
pressure_angle = 25;
thickness = 15;
backlash = 0.1;
tr_planets = [70, 0, 0];

module divider(inner_r, outer_r) {
  difference() {
    cylinder(2, outer_r, outer_r);
    translate([0, 0, -0.1]) cylinder(3.2, inner_r, inner_r);
  }
}

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

difference() {
  union() {
    // Input
    planetary_gear_set(sun_teeth=10, ring_teeth=28, ring_width=5, num_planets=4, pressure_angle=pressure_angle, mod=mod, thickness=thickness, planet_hole_diameter=5, backlash=backlash, translate_planets=tr_planets);

    // Output
    translate([0, 0, -17]) planetary_gear_set(sun_teeth=9, ring_teeth=25, ring_width=5, num_planets=4, pressure_angle=pressure_angle, mod=mod, thickness=thickness, planet_hole_diameter=5, backlash=backlash, translate_planets=tr_planets);
    
    translate([0, 0, -thickness-4]) difference() {
      cylinder(thickness+4, 32, 35);
      translate([0, 0, -0.001]) cylinder(thickness+4.002, 31, 31);
    }

    // Connect sun gears
    translate([0, 0, -2]) cylinder(2, 15, 15);

    // Input cap
    translate([0, 0, 16]) divider(25, 35);

    // Center divider
    translate([0, 0, -2]) divider(20, 32);

    // Output cap
    translate([0, 0, -19]) divider(22, 32);
  }

  translate([0, 0, -25]) linear_extrude(50) hexagon(5.3);

  // Screw body 21x2.2
  // 22 - 2+1 (cap) - 15 (ring above 0) = 4
  rotate(180/28) translate([30, 0, -4]) cylinder(22.1, 1.1, 1.1);
  rotate(180/28) translate([-30, 0, -4]) cylinder(22.1, 1.1, 1.1);
}
