$fn = 200;

difference() {
  // Body
  union() {
    // Top
    linear_extrude(38) polygon([[0, 0], [6.7, 0], [6.7, 31.5], [3.6, 31.5], [4, 27], [0, 26]]);
    translate([5.15, 31.5, 0]) cylinder(38, 1.55, 1.55);

    // Vertical
    cube([20.7, 6.7, 38]);
  }
  
  // Screw holes
  translate([10.6, 0, 8.35]) rotate([-90, 0, 0]) {
    translate([0, 0, 2.2]) cylinder(10, 6.3, 6.3);
    translate([0, 0, -1]) cylinder(10, 2.35, 2.35);
  }
  
  translate([10.6, 0, 29.65]) rotate([-90, 0, 0]) {
    translate([0, 0, 2.2]) cylinder(10, 6.3, 6.3);
    translate([0, 0, -1]) cylinder(10, 2.35, 2.35);
  }
}
