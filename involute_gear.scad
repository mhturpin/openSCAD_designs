include <../libraries/Round-Anything/polyround.scad>

$fn = 50;

// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf
// https://www.tec-science.com/mechanical-power-transmission/involute-gear/calculation-of-involute-gears/
// https://mathworld.wolfram.com/CircleInvolute.html

deg_per_radian = 180/PI;

module gear(pressure_angle = 20,
            modul = 2,
            num_teeth = 32,
            profile_shift = 0,
            addendum = 1,
            dedendum = 1.25,
            backlash = 0.2,
            root_fillet_radius = 0.2,
            thickness = 1,
            hole_diameter = 1) {

  pitch_diameter = num_teeth*modul;
  pitch_radius = pitch_diameter/2;
  base_diameter = pitch_diameter*cos(pressure_angle);
  base_radius = base_diameter/2;
  root_radius = pitch_radius - (dedendum*modul);
  top_radius = pitch_radius + (addendum*modul);

  for (i = [0:num_teeth-1]) {
    // At the pitch circle, teeth take up half the space
    rotate(360*i/num_teeth) tooth(pressure_angle, num_teeth, root_radius, top_radius, base_radius);
  }

  ring(pitch_radius);
  circle(root_radius);
}

// Create an involute gear tooth
module tooth(pressure_angle, num_teeth, root_radius, top_radius, base_radius) {
  // Angle relative to the base circle
  half_tooth_angle = 90/num_teeth + inv(pressure_angle);

  // Angle for the right corner of the tooth
  t_end = theta_for_radius(base_radius, top_radius);

  // Points: [x, y, radius]
  root_right = [base_radius, 0, 0];
  top_right = [inv_x(base_radius, t_end), inv_y(base_radius, t_end), 0];

  // All the points for the right half of the tooth
  points = concat([root_right], involute_points(base_radius, 0, t_end), [top_right]);
  // Rotate points so the center of the tooth is on the x axis
  rotated = [for (p = points) rotate_point(p, -half_tooth_angle)];
  // Mirror points across the x axis and reverse the order so they can be concatenated
  mirrored = [for (i = [len(rotated)-1:-1:0]) [rotated[i][0], -rotated[i][1], rotated[i][2]]];

  polygon(polyRound(concat(rotated, mirrored)));
}

module ring(radius) {
  difference() {
    cylinder(0.1, radius, radius, center=true);
    cylinder(1, radius - 0.1, radius - 0.1, center=true);
  }
}

// Get the [x, y] coordinates for a point on a circle at a given angle
function point_on_circle(radius, angle) = [radius*cos(angle), radius*sin(angle)];

// Get a series of points representing the involute curve between the two angles
function involute_points(r, t_start, t_end, step=1) = [for (t = [t_start:step:t_end]) [inv_x(r, t), inv_y(r, t), 0]];

// Get the x value for point on the involute curve at the given angle
function inv_x(r, t) = r*(cos(t) + (t/deg_per_radian)*sin(t));

// Get the y value for point on the involute curve at the given angle
function inv_y(r, t) = r*(sin(t) - (t/deg_per_radian)*cos(t));

// Get the value of theta for a given radius to involute curve
// x = rb(cos(t) + t*sin(t)), y = rb(sin(t) - t*cos(t))
// x^2 + y^2 = rb^2(t^2 + 1), x^2 + y^2 = r^2
// t = sqrt((r/rb)^2 - 1)
function theta_for_radius(rb, r) = sqrt(pow(r/rb, 2) - 1)*deg_per_radian;

// Rotate point around the origin
function rotate_point(p, t) = [p[0]*cos(t) - p[1]*sin(t), p[0]*sin(t) + p[1]*cos(t), p[2]];

// Get involute angle for a given pitch angle
function inv(angle) = (tan(angle) - angle/deg_per_radian)*deg_per_radian;

gear(pressure_angle = 20, modul = 2, num_teeth = 24);
