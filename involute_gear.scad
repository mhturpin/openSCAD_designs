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
    rotate(360*i/num_teeth) tooth(pressure_angle, 90/num_teeth, root_radius, top_radius, base_radius);
  }
  //circle(base_radius);
}

// Create an involute gear tooth
module tooth(pressure_angle, half_tooth_angle, root_radius, top_radius, base_radius) {
  // Points: [x, y, radius]
  root_center = concat(point_on_circle(base_radius, 0), [0]);
  top_center = concat(point_on_circle(top_radius, 0), [0]);
  t_end = theta_for_radius(base_radius, top_radius);
  
  tooth_points = get_involute_points(base_radius, 0, t_end, step=5);
  
  tp = [for (p = tooth_points) concat(p, [0])];
  

  polygon(polyRound(concat(tp, [top_center, root_center])));
  //mirror([0, 1, 0]) polygon(polyRound(concat(tooth_points, [top_center, root_center])));
}

// Get the [x, y] coordinates for a point on a circle at a given angle
function point_on_circle(radius, angle) = [radius*cos(angle), radius*sin(angle)];

// Involute function
// Uses radians, convert value back to degrees before returning
function inv(angle) = (tan(angle) - angle/deg_per_radian)*deg_per_radian;

// Get the angle away from the tooth center of a given radius
// acos(base_r/r) = operating pressure angle
function angle_from_tooth_center(r, base_r, inv_half_tooth) = inv_half_tooth - inv(acos(base_r/r));

// Get a series of points representing the involute curve between the two angles
function get_involute_points(r, t_start, t_end, step=1) = [for (t = [t_start:step:t_end]) [inv_x(r, t), inv_y(r, t)]];
// Get the x value for the 
function inv_x(r, t) = r*(cos(t) + (t/deg_per_radian)*sin(t));
function inv_y(r, t) = r*(sin(t) - (t/deg_per_radian)*cos(t));
// x = rb(cos(t) + t*sin(t)), y = rb(sin(t) - t*cos(t))
// x^2 + y^2 = rb^2(t^2 + 1), x^2 + y^2 = r^2
// t = sqrt((r/rb)^2 - 1)
function theta_for_radius(rb, r) = sqrt(pow(r/rb, 2) - 1)*deg_per_radian;


gear(pressure_angle = 20, modul = 2, num_teeth = 14);




