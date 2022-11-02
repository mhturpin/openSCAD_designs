use <involute_gears.scad>

$fn = $preview ? 30 : 200;
clearance = 0.2;

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

difference() {
  translate([0, 0, 7.15]) herringbone_gear(pressure_angle=20, mod=2.5, num_teeth=10, thickness=14.3, backlash=clearance);

  translate([0, 0, -0.1]) cylinder(4.6, 6.03+clearance, 6.03+clearance);
  translate([0, 0, 4.4]) cylinder(5.2, 4+clearance, 4+clearance);
  translate([0, 0, 9.5]) linear_extrude(4.9) hexagon(11.05+clearance*2);
}


translate([40, 0, 7.15]) herringbone_gear(pressure_angle=20, mod=2.5, num_teeth=10, thickness=14.3, hole_diameter=6.35, backlash=clearance);
