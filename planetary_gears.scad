use <involute_gears.scad>

$fn = $preview ? 25 : 100;

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

difference() {
  planetary_gear_set(sun_teeth=8, ring_teeth=20, ring_width=2, num_planets=4, pressure_angle=20, mod=1.5, thickness=2, backlash=0.2, translate_internals=0);
  translate([0, 0, -0.1]) linear_extrude(2.2) hexagon(4.3);
}
