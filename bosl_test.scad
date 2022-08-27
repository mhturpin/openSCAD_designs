include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/gears.scad>

rotate(-$t*9144) spur_gear(mod=1, teeth=20, thickness=1, pressure_angle=20);
translate([14, 0, 0]) rotate($t*360 + 22.5) spur_gear(mod=1, teeth=8, thickness=1, pressure_angle=20);