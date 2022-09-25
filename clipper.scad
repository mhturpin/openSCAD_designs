$fn = 100;

shell_thickness = 1;
metal_thickness = 1.3;

bump1_r = 3;
bump1_from_tip = 2.9 + bump1_r;
bump2_r = 3.95;
bump2_from_tip = 49 + bump2_r;


l1 = 11;
l2 = 45;
l3 = 2;
w1 = 12.3;
w2 = 12.8;
w3 = 9;
w4 = 10.5;
h1 = 8.7;
h2 = 2.7;

center = [w2/2, (l1 + l2)/2, h1/2];

x1 = (w2 - w1)/2;
x2 = (w2 + w1)/2;
x3 = w2;
x4 = (w2 + w3)/2;
x5 = (w2 - w3)/2;
x6 = (w2 - w4)/2;
x7 = (w2 + w4)/2;

y1 = l1;
y2 = l1 + l2;
y3 = -l3;

z1 = h1;
z2 = (h1 - h2)*(l2/(l1 + l2)) + h2;
z3 = h2;
z4 = h1/2;

points = [
  [x1, 0, 0],
  [x2, 0, 0],
  [x3, y1, 0],
  [x4, y2, 0],
  [x5, y2, 0],
  [0, y1, 0],
  [x1, 0, z1],
  [x2, 0, z1],
  [x3, y1, z2],
  [x4, y2, z3],
  [x5, y2, z3],
  [0, y1, z2],
  [x6, y3, z4],
  [x7, y3, z4]
];

faces = [
  [0, 1, 2, 3, 4, 5],
  [1, 7, 8, 2],
  [2, 8, 9, 3],
  [3, 9, 10, 4],
  [4, 10, 11, 5],
  [5, 11, 6, 0],
  [6, 11, 10, 9, 8, 7],
  [0, 6, 12],
  [6, 7, 13, 12],
  [1, 13, 7],
  [0, 12, 13, 1]
];

function shell_points(points, d, c) = [for (p=points) [p[0] < c[0] ? p[0]-d : p[0]+d, p[1] < c[1] ? p[1] : p[1]+d, p[2] < 1 ? p[2]-d : p[2]]];



points2 = [
  [x1, 0],
  [x6, y3],
  [x7, y3],
  [x2, 0],
  [x3, y1],
  [x4, y2],
  [x5, y2],
  [0, y1]
];



difference() {
  polyhedron(shell_points(points, shell_thickness, center), faces);
  //#translate([0, -.1, 0]) resize([0, 0, z1*1.01]) polyhedron(points, faces);
  linear_extrude(h1) polygon(points2);
  translate([x3/2, y2-bump1_from_tip, -1.5*shell_thickness]) cylinder(2*shell_thickness, bump1_r, bump1_r);
  translate([x3/2, y2-bump2_from_tip, -1.5*shell_thickness]) cylinder(2*shell_thickness, bump2_r, bump2_r);
}

translate([x5-shell_thickness, y2+shell_thickness-2, z3]) cube([w3+2*shell_thickness, 2, shell_thickness]);
//translate([x1, shell_thickness/2, metal_thickness+shell_thickness/2]) rotate([0, 45, 0]) cube(shell_thickness, center=true);
//translate([x2, shell_thickness/2, metal_thickness+shell_thickness/2]) rotate([0, 45, 0]) cube(shell_thickness, center=true);
