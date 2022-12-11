// 8mm rod
// 89mm to center of plate
// 62mm inner large end
$fn = 200;

translate([-28-4.1, 0, 0]) difference() {
  cylinder(10, 9, 9, center=true);
  cylinder(10.2, 4.1, 4.1, center=true);
}

// 90 - 34
cube([56, 10, 10], center=true);

translate([28+34, 0, 0]) difference() {
  cylinder(10, 41, 41, center=true);
  cylinder(10.2, 31, 33.4, center=true);
}

// funnel base diameter 12
// funnel top diameter 76
// funnel height 133