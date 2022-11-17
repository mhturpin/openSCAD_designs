use <involute_gears.scad>

$fn = $preview ? 25 : 100;

mod = 2;
pressure_angle = 20;
thickness = 5;
clearance = 0.1;
sun = 8;
ring = 20;
planet = (ring - sun)/2;

function pitch_radius(mod, teeth) = mod*teeth/2;

module make_gear(teeth) {
  gear(pressure_angle=pressure_angle, mod=mod, num_teeth=teeth, thickness=thickness, backlash=clearance);
}

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

dist = 35;

// Sun
translate([dist, 0, 0]) difference() {
  make_gear(sun);
  translate([0, 0, -0.1]) linear_extrude(thickness+0.2) hexagon(4);
}

// Ring
ring_radius = pitch_radius(mod, 20) + mod + 2;

difference() {
  cylinder(1 + thickness, ring_radius, ring_radius);
  translate([0, 0, 1]) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=ring, thickness=thickness+0.1, addendum=1.25, dedendum=1);
}

// Planets
  for (i = [1:4]) {
    rotate(i*30) translate([dist, 0, 0]) make_gear(planet);
  }






