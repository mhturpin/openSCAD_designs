include <involute_gear.scad>

// Reference https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf page T18
// Angles marked by yellow spheres are theta (t)
// Red vertices mark the length of string unraveled (l)
// r = radius of base circle
// l = length of arc of circle that subtends theta = r*t
// x = base of red triangle + base of white triangle
// base of red triangle = r*cos(t)
// base of white triangle = l*sin(t)
// x = r*cos(t) + l*sin(t)
// x = r*cos(t) + r*t*sin(t)
// x = r*(cos(t) + t*sin(t))
// y = height of red triangle - height of white triangle
// height of red triangle = r*sin(t)
// height of white triangle = l*cos(t)
// y = r*sin(t) - l*cos(t)
// y = r*sin(t) - r*t*cos(t)
// y = r*(sin(t) - t*cos(t))

module ring(radius) {
  difference() {
    cylinder(0.1, radius, radius, center=true);
    cylinder(1, radius - 0.1, radius - 0.1, center=true);
  }
}

module line(start, end) {
  hull() {
    translate(start) sphere(0.1);
    translate(end) sphere(0.1);
  }
}

module curve(points) {
  for (i = [1:len(points)-1]) {
    line(points[i-1], points[i]);
  }
}

ring(20); // Base circle
line([0, 23.09, 0], [40, 0, 0]); // String line
line([0, 0, 0], [10, 17.32, 0]); // Radius to unwinding point
line([10, 0, 0], [10, 17.32, 0]); // Vertical line from unwinding point
line([10, 6.85, 0], [28.14, 6.85, 0]);
line([28.14, 0, 0], [28.14, 6.85, 0]); // Vertical line from involute x coordinate
curve(get_inv_points(20, 0, 70)); // Involute
#polygon([[0, 0], [10, 17.32], [10, 0]]); // Red triangle
%polygon([[10, 6.85], [10, 17.32], [28.14, 6.85]]); // White triangle
translate([1, 0.5, 0]) sphere(0.5); // Theta
translate([10.7, 16, 0]) sphere(0.5); // Theta
#translate([10, 17.32, 0]) sphere(0.5); // String at tangent
#translate([28.14, 6.85, 0]) sphere(0.5); // String end
