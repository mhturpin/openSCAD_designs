$fn = 200;

// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf
// https://www.tec-science.com/mechanical-power-transmission/involute-gear/calculation-of-involute-gears/
// https://mathworld.wolfram.com/CircleInvolute.html

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

  // Base gear dimension calculations
  pitch_diameter = num_teeth*modul;
  pitch_radius = pitch_diameter/2;
  base_diameter = pitch_diameter*cos(pressure_angle);
  base_radius = base_diameter/2;
  root_radius = pitch_radius - (dedendum*modul);
  top_radius = pitch_radius + (addendum*modul);

  // Undercut calculations
  // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=42
  rack_chordal_thickness = PI*modul/2;
  distance_rolled = rack_chordal_thickness/2 - addendum*modul*tan(pressure_angle);
  angle_from_centered = to_deg(distance_rolled/pitch_radius);
  angle_offset = 180/num_teeth - angle_from_centered;


  for (i = [0:num_teeth-1]) {
    rotate(360*i/num_teeth) {
      difference() {
        tooth(pressure_angle, num_teeth, root_radius, top_radius, base_radius, pitch_radius);
        rotate(angle_offset) undercut_profile(addendum*modul, pitch_radius);
        mirror([0, 1, 0]) rotate(angle_offset) undercut_profile(addendum*modul, pitch_radius);
      }
    }
  }

  circle(root_radius);
}

// Create an involute gear tooth
module tooth(pressure_angle, num_teeth, root_radius, top_radius, base_radius, pitch_radius) {
  // The angle from the start of the involute curve to the center of the tooth 
  // At the pitch circle, teeth take up half the circumference, so half the tooth is 1/4 of 360/teeth
  half_tooth_angle = 90/num_teeth + inv(pressure_angle);

  // Angle for the right corner of the tooth
  t_end = theta_for_radius(base_radius, top_radius);

  // Points: [x, y, radius]
  base_right = [base_radius, 0];
  top_right = [inv_x(base_radius, t_end), inv_y(base_radius, t_end)];

  // All the points for the right half of the tooth
  points = concat([base_right], involute_points(base_radius, 0, t_end), [top_right]);
  // Rotate points so the center of the tooth is on the x axis
  rotated = rotate_points(points, -half_tooth_angle);
  // Mirror points across the x axis and reverse the order so they can be concatenated
  mirrored = reverse(mirror_points(rotated));

  // The involute portion of the tooth
  polygon(concat(rotated, mirrored));

  // Round the bottom of the root if base_radius > root_radius
  // Needed because involute doesn't extend to the bottom of the root
  if (base_radius > root_radius) {
    half_root_angle = 180/num_teeth - half_tooth_angle;
    distance_between_teeth = base_radius*sin(half_root_angle)*2; // At base circle
    // The angle to stop making the arc for the fillet radius
    end_angle = 270 + half_tooth_angle;
    
    // Extra points for creating a polygon
    tooth_base = rotate_point([base_radius, 0], half_tooth_angle);
    tooth_center = [pitch_radius, 0];

    // For gears with fewer teeth, where the root is too deep for the circle to intersect the base circle
    // The circle is tangent to the root_radius and the two lines connecting the edge of the teeth to the origin
    // A right triangle is formed where sin(half_root_angle) = fillet_radius/(fillet_radius + root_radius)
    deep_fillet_radius = root_radius*sin(half_root_angle)/(1 - sin(half_root_angle));

    // For gears with a medium number of teeth, where the root is too shallow for the circle to intersect the center of the root circle
    // Find the 90 degree arc tangent to the tooth at the base radius and the root radius
    // For the intersection on the root circle:
    // x = base_radius - y, x^2 + y^2 = root_radius^2, y = fillet_radius (because 90 degree arc)
    // Solve for y: y = (base_radius +/- sqrt(2*root_radius^2 - base_radius^2))/2
    // We only care about the smaller y solution
    shallow_fillet_radius = (base_radius - sqrt(2*root_radius^2 - base_radius^2))/2;

    fillet_radius = min(deep_fillet_radius, shallow_fillet_radius);

    if (deep_fillet_radius < shallow_fillet_radius) {
      center = rotate_point(point_on_circle(root_radius + fillet_radius, half_root_angle), half_tooth_angle);
      start_angle = end_angle - (90 - half_root_angle);
      fillet_points = arc_points(fillet_radius, start_angle, end_angle, center);
      half_polygon = concat([[0, 0]], fillet_points, [tooth_base, tooth_center]);

      polygon(concat(half_polygon, reverse(mirror_points(half_polygon))));

    } else {
      center = rotate_point([base_radius, fillet_radius], half_tooth_angle);
      start_angle = end_angle - 90;
      fillet_points = arc_points(fillet_radius, start_angle, end_angle, center);
      half_polygon = concat([[0, 0]], fillet_points, [tooth_base, tooth_center]);

      polygon(concat(half_polygon, reverse(mirror_points(half_polygon))));
    }
  }
}

// The profile that a tooth makes as it meshes with a gear of the given base radius
// Assume the worst possible undercutting, which occurs with a rack
// Can be thought of as an offset inwards of an involute since the rack pitch line is a straight line rolling along the pitch circle of the gear
// Start the profile when the tooth tip is deepest
module undercut_profile(addendum, radius) {  
  points = [for (t = [0:90]) tip_arc_point(addendum, radius, t)];
  polygon(points);
}

module ring(radius) {
  difference() {
    cylinder(0.1, radius, radius, center=true);
    cylinder(1, radius - 0.1, radius - 0.1, center=true);
  }
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


module test_gears() {
  // Pitch radius: 8
  // 360 degrees rotation per cycle
  translate([20, -16, 0]) rotate($t*360 + 22.5) gear(pressure_angle = 20, modul = 1, num_teeth = 8);
  // Pitch radius: 16
  // 90 degrees rotation per cycle
  translate([0, -16, 0]) rotate(-$t*90) gear(pressure_angle = 20, modul = 1, num_teeth = 32);
  // Pitch radius: 25
  // 57.6 degrees rotation per cycle
  translate([0, 25, 0]) rotate($t*57.6) gear(pressure_angle = 20, modul = 1, num_teeth = 50);
}

test_gears();
