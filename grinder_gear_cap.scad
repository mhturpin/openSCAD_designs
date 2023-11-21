$fn = 100;

difference() {
  union() {
    cylinder(1, 24, 24);

    translate([0, 0, 1]) difference() {
      cylinder(4.2, 22.7, 22.7);
      
      translate([0, 0, 3.2]) {
        cube([50, 9.2, 6], true);
        rotate(60) cube([50, 9.2, 6], true);
        rotate(120) cube([50, 9.2, 6], true);
      }
    }
  }
  
  translate([0, 0, -1]) cylinder(7, 10, 10);
}