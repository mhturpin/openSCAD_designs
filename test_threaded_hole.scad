include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>

$fn = 200;

difference() {
  translate([0, 0, 5]) cube(9, center=true);
  translate([0, 0, 3.574]) threaded_rod(6.37, 7.15, 1.27);
}