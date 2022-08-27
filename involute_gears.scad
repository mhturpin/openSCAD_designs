$fn = 200;

// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf
// https://www.tec-science.com/mechanical-power-transmission/involute-gear/calculation-of-involute-gears/
// https://mathworld.wolfram.com/CircleInvolute.html

module gear(pressure_angle = 20,
            mod = 1,
            num_teeth = 32,
            addendum = 1,
            dedendum = 1.25,
            hole_diameter = 0,
            thickness = 1,
            twist = 0) {
  linear_extrude(height = thickness, twist = twist, convexity = 10) {
    gear_2d(pressure_angle, mod, num_teeth, addendum, dedendum, hole_diameter);
  }
}

// TODO: add profile_shift, backlash, root_fillet_radius
module gear_2d(pressure_angle, mod, num_teeth, addendum, dedendum, hole_diameter) {
  // Base gear dimension calculations
  pitch_diameter = num_teeth*mod;
  pitch_radius = pitch_diameter/2;
  base_diameter = pitch_diameter*cos(pressure_angle);
  base_radius = base_diameter/2;
  root_radius = pitch_radius - (dedendum*mod);
  top_radius = pitch_radius + (addendum*mod);

  // Undercut calculations
  // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=42
  rack_chordal_thickness = PI*mod/2;
  distance_rolled = rack_chordal_thickness/2 - addendum*mod*tan(pressure_angle);
  angle_from_centered = to_deg(distance_rolled/pitch_radius);
  angle_offset = 180/num_teeth - angle_from_centered;

  tooth_ps = tooth_points(pressure_angle, num_teeth, root_radius, base_radius, pitch_radius, top_radius);
  // Points are listed from +x to -x, so go clockwise
  gear_points = [for (i = [0:num_teeth-1]) each rotate_points(tooth_ps, -360*i/num_teeth)];

  difference() {
    polygon(gear_points);

    for (i = [0:num_teeth-1]) {
      rotate(360*i/num_teeth) {
        rotate(angle_offset) undercut_profile(addendum*mod, pitch_radius, top_radius);
        mirror([0, 1, 0]) rotate(angle_offset) undercut_profile(addendum*mod, pitch_radius, top_radius);
      }
    }

    circle(hole_diameter/2);
  }

  #ring(root_radius);
  #ring(base_radius);
  #ring(pitch_radius);
}

// Get the points for an involute gear tooth
// Center of tooth on x axis, points above x axis
function tooth_points(pressure_angle, num_teeth, root_radius, base_radius, pitch_radius, top_radius) =
  let(
    // If base_radius > root_radius, start at base_radius, else start where involute crosses root_radius
    t_start = base_radius > root_radius ? 0 : theta_for_radius(base_radius, root_radius),
    // Angle for the corner of the tooth
    t_end = theta_for_radius(base_radius, top_radius),
    // The angle from the start of the involute curve on the base circle to the center of the tooth
    // At the pitch circle, teeth take up half the circumference, so half the tooth is 1/4 of 360/teeth
    tooth_center_angle = 90/num_teeth + inv(pressure_angle),
    contact_ps = contact_surface_points(base_radius, t_start, t_end, tooth_center_angle),
    fillet_ps = fillet_points(base_radius, root_radius, num_teeth, tooth_center_angle),
    half_tooth_points = concat(fillet_ps, contact_ps)
  ) concat(half_tooth_points, reverse(mirror_points(half_tooth_points)));

// Get the points for the involute section of the tooth
// Center of tooth on x axis, points above x axis
function contact_surface_points(base_radius, t_start, t_end, tooth_center_angle) =
  let(
    // Add start and end points to ensure the whole tooth is included
    start_point = involute_point(base_radius, t_start),
    end_point = involute_point(base_radius, t_end),
    inv_points = concat([start_point], involute_points(base_radius, t_start, t_end), [end_point])
  ) mirror_points(rotate_points(inv_points, -tooth_center_angle));

// Get the points for the fillet of the tooth
// Round the bottom of the root if base_radius > root_radius
// Needed because involute doesn't extend to the bottom of the root
// If root_radius >= base_radius, don't return anything since a fillet radius is not needed
// Center of tooth on x axis, points above x axis
// TODO: not working for teeth < 8, pressure_angle = 20
function fillet_points(base_radius, root_radius, num_teeth, tooth_center_angle) =
  let(
    half_root_angle = 180/num_teeth - tooth_center_angle,
    distance_between_teeth = base_radius*sin(half_root_angle)*2, // At base circle
    // For gears with fewer teeth, where the root is too deep for the circle to intersect the base circle
    // The circle is tangent to the root_radius and the two lines connecting the edge of the teeth to the origin
    // A right triangle is formed where sin(half_root_angle) = fillet_radius/(fillet_radius + root_radius)
    deep_fillet_radius = root_radius*sin(half_root_angle)/(1 - sin(half_root_angle)),
    // For gears with a medium number of teeth, where the root is too shallow for the circle to intersect the center of the root circle
    // Find the 90 degree arc tangent to the tooth at the base radius and the root radius
    // For the intersection on the root circle:
    // x = base_radius - y, x^2 + y^2 = root_radius^2, y = fillet_radius (because 90 degree arc)
    // Solve for y: y = (base_radius +/- sqrt(2*root_radius^2 - base_radius^2))/2
    // We only care about the smaller y solution
    shallow_fillet_radius = (base_radius - sqrt(2*root_radius^2 - base_radius^2))/2,
    fillet_radius = min(deep_fillet_radius, shallow_fillet_radius),
    is_deep = deep_fillet_radius < shallow_fillet_radius,
    center0 = is_deep ? point_on_circle(root_radius + fillet_radius, half_root_angle) : [base_radius, fillet_radius],
    center = rotate_point(center0, tooth_center_angle),
    // The angle to stop making the arc for the fillet radius
    end_angle = 270 + tooth_center_angle,
    start_angle = end_angle - 90 + (is_deep ? half_root_angle : 0)
  ) base_radius > root_radius ? arc_points(fillet_radius, start_angle, end_angle, center) : [];

// Get the profile that a tooth makes as it meshes with a gear of the given base radius
// Assume the worst possible undercutting, which occurs with a rack
// Can be thought of as an offset inwards of an involute since the rack pitch line is a straight line rolling along the pitch circle of the gear
// Start the profile when the tooth tip is deepest
// To find t_stop, a right triangle can be drawn with sides a = pitch_radius - addendum, b = t_stop*pitch_radius (length of arc/string), c = top_radius
module undercut_profile(addendum, pitch_radius, top_radius) {
  t_stop = to_deg(sqrt(top_radius^2 - (pitch_radius - addendum)^2)/pitch_radius);
  points = [for (t = [0:t_stop]) tip_arc_point(addendum, pitch_radius, t)];
  polygon(points);
}

// Get the [x, y] coordinates for a point on a circle at a given angle
function point_on_circle(r, t) = [r*cos(t), r*sin(t)];

// Get the [x, y] coordinates for a point on the involute curve
function involute_point(r, t) = [inv_x(r, t), inv_y(r, t)];

// Get a series of points representing the involute curve between the two angles
function involute_points(r, t_start, t_end, step=1) = [for (t = [t_start:step:t_end]) involute_point(r, t)];

// Get the x value for point on the involute curve at the given angle
function inv_x(r, t) = r*(cos(t) + to_rad(t)*sin(t));

// Get the y value for point on the involute curve at the given angle
function inv_y(r, t) = r*(sin(t) - to_rad(t)*cos(t));

// Get the value of theta for a given radius to involute curve
// x = rb(cos(t) + t*sin(t)), y = rb(sin(t) - t*cos(t))
// x^2 + y^2 = rb^2(t^2 + 1), x^2 + y^2 = r^2
// t = sqrt((r/rb)^2 - 1)
function theta_for_radius(rb, r) = to_deg(sqrt(pow(r/rb, 2) - 1));

// Rotate point around the origin
function rotate_point(p, t) = [p[0]*cos(t) - p[1]*sin(t), p[0]*sin(t) + p[1]*cos(t)];

// Rotate point around the origin
function rotate_points(points, t) = [for (p = points) rotate_point(p, t)];

// Mirror points across the x axis
function mirror_points(points) = [for (p = points) [p[0], -p[1]]];

// Translate points
function translate_points(points, to) = [for (p = points) [p[0] + to[0], p[1] + to[1]]];

// Reverse order of array
function reverse(elements) = [for (i = [len(elements)-1:-1:0]) elements[i]];

// Get involute angle for a given pitch angle
function inv(angle) = to_deg(tan(angle) - to_rad(angle));

// Get the [x, y] coordinates for a point on the arc generated by the corner of a gear tooth
function tip_arc_point(d, r, t) = [inv_x(r, t) - d*cos(t), inv_y(r, t) - d*sin(t)];

// Radians to degrees
function to_deg(t) = t*180/PI;

// Degrees to radians
function to_rad(a) = a*PI/180;

// Degrees to radians
function distance(p1, p2) = sqrt((p1[0] - p2[0])^2 + (p1[1] - p2[1])^2);

// Get points representing the arc
function arc_points(r, t_start, t_end, center) = translate_points([for (a = [t_start:t_end]) point_on_circle(r, a)], center);



module ring(radius) {
  translate([0, 0, .5]) difference() {
    cylinder(0.1, radius, radius, center=true);
    cylinder(1, radius - 0.1, radius - 0.1, center=true);
  }
}

module test_gears() {
  // Pitch radius: 8
  // 360 degrees rotation per cycle
  translate([20, -16, 0]) rotate($t*360 + 22.5) gear(pressure_angle = 20, mod = 1, num_teeth = 8);
  // Pitch radius: 16
  // 90 degrees rotation per cycle
  translate([0, -16, 0]) rotate(-$t*90) gear(pressure_angle = 20, mod = 1, num_teeth = 32);
  // Pitch radius: 25
  // 57.6 degrees rotation per cycle
  translate([0, 25, 0]) rotate($t*57.6) gear(pressure_angle = 20, mod = 1, num_teeth = 50);
}

// test_gears();
// gear(pressure_angle = 20, mod = 1, num_teeth = 15);
