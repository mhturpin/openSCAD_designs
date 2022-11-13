use <involute_gears.scad>

$fn = $preview ? 30 : 200;
clearance = 0.2;

herringbone_gear(pressure_angle=20, mod=1, num_teeth=10, thickness=5, hole_diameter=2, backlash=clearance);


translate([15, 0, 0]) herringbone_gear(pressure_angle=20, mod=1, num_teeth=10, thickness=5, hole_diameter=2, backlash=clearance);
