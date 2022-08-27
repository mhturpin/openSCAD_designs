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

  pitch_diameter = num_teeth*modul;
  pitch_radius = pitch_diameter/2;
  base_diameter = pitch_diameter*cos(pressure_angle);
  base_radius = base_diameter/2;
  root_radius = pitch_radius - (dedendum*modul);
  top_radius = pitch_radius + (addendum*modul);

  create_teeth(num_teeth) tooth(pressure_angle, num_teeth, root_radius, top_radius, base_radius);

  // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=42
  rack_chordal_thickness = PI*modul/2;
  distance_rolled = rack_chordal_thickness/2 - addendum*modul*tan(pressure_angle);
  angle_from_centered = to_deg(distance_rolled/pitch_radius);
  angle_offset = 180/num_teeth - angle_from_centered;
  
  // #rotate(angle_offset) undercut_profile(addendum*modul, pitch_radius);

  translate([0, 0, .5]) ring(root_radius);
  translate([0, 0, .5]) ring(base_radius);
  translate([0, 0, .5]) ring(pitch_radius);
  //circle(root_radius);
}

// Makes all the teeth using a template tooth
module create_teeth(num_teeth) {
  for (i = [0:num_teeth-1]) {
    rotate(360*i/num_teeth) children();
  }
}

// Create an involute gear tooth
module tooth(pressure_angle, num_teeth, root_radius, top_radius, base_radius) {
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
  
  polygon(concat(rotated, mirrored));
  
  
  
  
  // Round the bottom of the root if base_radius > root_radius
  // Needed because involute doesn't extend to the bottom of the root
  angle_between_teeth = 360/num_teeth - 2*half_tooth_angle;
  distance_between_teeth = base_radius*sin(angle_between_teeth/2)*2; // At base circle
  
  // if statement not quite right since teeth arent parallel
  if (distance_between_teeth/2 < base_radius - root_radius) {
    // can't set variables here
    // circle deeper down
    // touches root_radius, lines from origin to tooth fillets
    
    
    fillet_radius = root_radius*sin(angle_between_teeth/2)/(1 - sin(angle_between_teeth/2));
    center = point_on_circle(root_radius + fillet_radius, angle_between_teeth/2);
    fillet_points = translate_points(rotate_points(arc_points(fillet_radius, 90 - angle_between_teeth/2), 180), center);
    
    polygon(rotate_points(fillet_points, half_tooth_angle));
    polygon(mirror_points(rotate_points(fillet_points, half_tooth_angle)));
  }
  else if (base_radius > root_radius) {
    // Find the 90 degree arc tangent to the tooth at the base radius and the root radius
    // For the intersection on the root circle:
    // x = base_radius - y, x^2 + y^2 = root_radius^2, y = fillet_radius (because 90 degree arc)
    // Solve for y: y = (base_radius +/- sqrt(2*root_radius^2 - base_radius^2))/2
    // We only care about the smaller y solution
    intersect_y = (base_radius - sqrt(2*root_radius^2 - base_radius^2))/2;
    fillet_radius = intersect_y;
    // Move the points to line up with the x axis, then rotate them to line up with the tooth
    center = [base_radius, intersect_y];
    fillet_points = translate_points(rotate_points(arc_points(fillet_radius, 90), 180), center);
    polygon(rotate_points(fillet_points, half_tooth_angle));
    polygon(mirror_points(rotate_points(fillet_points, half_tooth_angle)));
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

// Get points representing the arc or radius r through the angle t
function arc_points(r, t) = [for (a = [0:t]) point_on_circle(r, a)];
  
// Translate points
function translate_points(points, to) = [for (p = points) [p[0] + to[0], p[1] + to[1]]];


// Get the circle with the given radius that passes through the two points
// Returns the circle with the greater x value
module circle_through(r, p1, p2) {
  midpoint = [(p1[0] + p2[0])/2, (p1[1] + p2[1])/2];
  d = distance(p1, midpoint);
  dist_to_center = sqrt(r^2 - d^2);
  slope = (p1[1]-p2[1])/(p1[0]-p2[0]);
  slope_perp = -1/slope;
  angle = atan(slope_perp);
  x = dist_to_center*cos(angle) + midpoint[0];
  y = dist_to_center*sin(angle) + midpoint[1];
  
  translate([x, y, 0]) circle(r);
}

//arc_points(10, [0, 0], [0, 5]);
//circle(5);


gear(pressure_angle = 20, modul = 2, num_teeth = 8);





