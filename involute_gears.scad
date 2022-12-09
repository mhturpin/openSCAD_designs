$fn = $preview ? 50 : 200;
step = $preview ? 5 : 1;

// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf
// https://www.tec-science.com/mechanical-power-transmission/involute-gear/calculation-of-involute-gears/
// https://mathworld.wolfram.com/CircleInvolute.html

// For a helical gear, pass in the helix angle, positive for a right handed helix
module gear(num_teeth=32,
            pressure_angle=20,
            mod=1,
            thickness=1,
            hole_diameter=0,
            backlash=0,
            helix_angle=0,
            addendum=1,
            dedendum=1.25) {
  twist = tan(-helix_angle)*thickness*360/(num_teeth*mod*PI);

  linear_extrude(height=thickness, twist=twist, convexity=10) {
    gear_2d(num_teeth, pressure_angle, mod, hole_diameter, backlash, addendum, dedendum);
  }
}

module herringbone_gear(num_teeth=32,
                        pressure_angle=20,
                        helix_angle=30,
                        mod=1,
                        thickness=1,
                        hole_diameter=0,
                        backlash=0,
                        addendum=1,
                        dedendum=1.25,
                        reverse=false) {
  direction = reverse ? 1 : -1;

  translate([0, 0, thickness/2]) {
    gear(num_teeth=num_teeth,
         pressure_angle=pressure_angle,
         helix_angle=direction*helix_angle,
         mod=mod,
         thickness=thickness/2,
         hole_diameter=hole_diameter,
         backlash=backlash,
         addendum=addendum,
         dedendum=dedendum);
    mirror([0, 0, 1]) gear(num_teeth=num_teeth,
                           pressure_angle=pressure_angle,
                           helix_angle=direction*helix_angle,
                           mod=mod,
                           thickness=thickness/2,
                           hole_diameter=hole_diameter,
                           backlash=backlash,
                           addendum=addendum,
                           dedendum=dedendum);
  }
}

module ring_gear(num_teeth=24,
                 ring_width=2,
                 pressure_angle=20,
                 mod=1,
                 thickness=1,
                 backlash=0) {
  ring_radius = pitch_radius(mod, num_teeth) + mod + ring_width;
  echo(str("Ring radius: ", ring_radius));

  difference() {
    cylinder(thickness, ring_radius, ring_radius);
    translate([0, 0, -0.1]) gear(num_teeth=num_teeth, pressure_angle=pressure_angle, mod=mod, thickness=thickness+0.2, backlash=-backlash, addendum=1.25, dedendum=1-0.2/mod);
  }
}

// TODO: add helical, herringbone types
// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=61
module planetary_gear_set(sun_teeth=8,
                          ring_teeth=24,
                          ring_width=2,
                          num_planets=4,
                          pressure_angle=20,
                          mod=1,
                          thickness=1,
                          sun_hole_diameter=0,
                          planet_hole_diameter=0,
                          backlash=0,
                          translate_sun=[0, 0, 0],
                          translate_planets=[0, 0, 0]) {
  assert((ring_teeth - sun_teeth)%2 == 0, "Planet gears must have an integer number of teeth");

  planet_teeth = (ring_teeth - sun_teeth)/2;

  // Ring gear
  ring_gear(num_teeth=ring_teeth, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash);

  // Sun gear
  sun_rotation = planet_teeth%2 == 0 ? 180/sun_teeth : 0;
  translate(translate_sun) rotate(sun_rotation) gear(num_teeth=sun_teeth, pressure_angle=pressure_angle, mod=mod, thickness=thickness, hole_diameter=sun_hole_diameter, backlash=backlash);

  // Planet gears
  dist = pitch_radius(mod, ring_teeth) - pitch_radius(mod, planet_teeth);
  // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=61 equation (13-8)
  spacing_number = (sun_teeth + ring_teeth)/num_planets;
  ring_angle_per_tooth = 360/ring_teeth;

  half_min_spacing_angle = floor(spacing_number)*180/(sun_teeth + ring_teeth);
  planet_od = pitch_radius(mod, planet_teeth)*2 + 2*mod;
  planet_center_to_center = 2*(pitch_radius(mod, sun_teeth) + pitch_radius(mod, planet_teeth))*sin(half_min_spacing_angle);

  assert(planet_od < planet_center_to_center, "Planet gears will interfere");

  translate(translate_planets) for (i = [0:num_planets-1]) {
    location_angle = round(i*spacing_number)*360/(sun_teeth + ring_teeth);
    offset_coefficient = (location_angle%ring_angle_per_tooth)/ring_angle_per_tooth;
    rotation = offset_coefficient*360/planet_teeth;

    // echo(str("Planet angle: ", location_angle));

    rotate(location_angle) translate([dist, 0, 0]) rotate(-rotation) gear(num_teeth=planet_teeth, pressure_angle=pressure_angle, mod=mod, thickness=thickness, hole_diameter=planet_hole_diameter, backlash=backlash);
  }
}

// TODO: backlash
// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=42
module rack(length=PI*20,
            width=10,
            base_thickness=5,
            pressure_angle=20,
            mod=1,
            backlash=0,
            addendum=1,
            dedendum=1.25,
            helix_angle=0) {
  tooth_height = (addendum + dedendum)*mod;
  circular_pitch = PI*mod;
  base_x_offset = circular_pitch/4 + dedendum*mod*tan(pressure_angle);
  tip_x_offset = circular_pitch/4 - addendum*mod*tan(pressure_angle);
  additional_length = abs(tan(helix_angle)*width); // The additional length we need if it's a helical rack
  initial_length = length + 2*additional_length;

  pitch_x_offset = dedendum*mod*tan(pressure_angle);
  pitch_y = dedendum*mod;
  num_teeth = floor(initial_length/(circular_pitch));
  tooth_points = [[-base_x_offset, 0], [-tip_x_offset, tooth_height], [tip_x_offset, tooth_height], [base_x_offset, 0]];

  // [[scale x,     skew y (+x), skew z (+x), translate x]
  //  [skew x (+y), scale y,     skew z (+y), translate y]
  //  [skew x (+z), skew y (+z), scale z,     translate z]
  //  [nothing,     nothing,     nothing,     shrink all ]
  skew_matrix = [[1, 0, tan(helix_angle), 0],
                 [0, 1, 0, 0],
                 [0, 0, 1, 0],
                 [0, 0, 0, 1]];

  translate([-length/2, 0, 0]) intersection() {
    translate([-additional_length, 0, 0]) multmatrix(skew_matrix) {
      cube([initial_length, base_thickness, width]);

      for (i = [0:num_teeth]) {
        translate([circular_pitch*i, base_thickness, 0]) linear_extrude(width) polygon(tooth_points);
      }
    }

    cube([length, base_thickness+tooth_height, width]);
  }
}

module herringbone_rack(length=PI*20,
                        width=10,
                        base_thickness=5,
                        pressure_angle=20,
                        mod=1,
                        backlash=0,
                        addendum=1,
                        dedendum=1.25,
                        helix_angle=30) {
  translate([0, 0, width/2]) {
    rack(length=length,
         width=width/2,
         base_thickness=base_thickness,
         pressure_angle=pressure_angle,
         mod=mod,
         backlash=backlash,
         addendum=addendum,
         dedendum=dedendum,
         helix_angle=helix_angle);
    mirror([0, 0, 1]) rack(length=length,
                           width=width/2,
                           base_thickness=base_thickness,
                           pressure_angle=pressure_angle,
                           mod=mod,
                           backlash=backlash,
                           addendum=addendum,
                           dedendum=dedendum,
                           helix_angle=helix_angle);
  }
}

// TODO: add profile_shift, root_fillet_radius
module gear_2d(num_teeth, pressure_angle, mod, hole_diameter, backlash, addendum, dedendum) {
  // Base gear dimension calculations
  pitch_diameter = num_teeth*mod;
  pitch_radius = pitch_diameter/2;
  base_diameter = pitch_diameter*cos(pressure_angle);
  base_radius = base_diameter/2;
  root_radius = pitch_radius - (dedendum*mod);
  top_radius = pitch_radius + (addendum*mod);

  tooth_ps = tooth_points(pressure_angle, num_teeth, root_radius, base_radius, pitch_radius, top_radius, backlash);
  // Points are listed from +x to -x, so go clockwise
  gear_points = [for (i = [0:num_teeth-1]) each rotate_points(tooth_ps, -360*i/num_teeth)];

  difference() {
    polygon(gear_points);

    if (dedendum == 1.25) {
      // Undercut calculations
      // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=42
      rack_chordal_thickness = PI*mod/2;
      distance_rolled = rack_chordal_thickness/2 - addendum*mod*tan(pressure_angle);
      angle_from_centered = to_deg(distance_rolled/pitch_radius);
      // Use standard addendum of 1*module
      half_undercut_points = undercut_profile_points(mod, pitch_radius, top_radius);
      undercut_points = concat(rotate_points(half_undercut_points, -angle_from_centered), rotate_points(mirror_points(reverse(half_undercut_points)), angle_from_centered));

      for (i = [0:num_teeth-1]) {
        rotate(360*i/num_teeth) {
          rotate(180/num_teeth) polygon(undercut_points);
        }
      }
    }

    circle(hole_diameter/2);
  }
}

// Get the points for an involute gear tooth
// Center of tooth on x axis, points above x axis
function tooth_points(pressure_angle, num_teeth, root_radius, base_radius, pitch_radius, top_radius, backlash) =
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
    half_tooth_points = concat(fillet_ps, contact_ps),
    shifted_points = [for (p = half_tooth_points) [p[0], p[1] - backlash/2]]
  ) concat(shifted_points, reverse(mirror_points(shifted_points)));

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
function undercut_profile_points(addendum, pitch_radius, top_radius) =
  let(
    t_stop = to_deg(sqrt(top_radius^2 - (pitch_radius - addendum)^2)/pitch_radius)
  ) [for (t = [0:step:t_stop]) tip_arc_point(addendum, pitch_radius, t)];


// Get the [x, y] coordinates for a point on a circle at a given angle
function point_on_circle(r, t) = [r*cos(t), r*sin(t)];

// Get the [x, y] coordinates for a point on the involute curve
function involute_point(r, t) = [inv_x(r, t), inv_y(r, t)];

// Get a series of points representing the involute curve between the two angles
function involute_points(r, t_start, t_end) = [for (t = [t_start:step:t_end]) involute_point(r, t)];

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
function arc_points(r, t_start, t_end, center) = translate_points([for (a = [t_start:step:t_end]) point_on_circle(r, a)], center);

// Get the pitch radius
function pitch_radius(mod, teeth) = mod*teeth/2;

module ring(radius) {
  translate([0, 0, .5]) difference() {
    cylinder(0.1, radius, radius, center=true);
    cylinder(1, radius - 0.1, radius - 0.1, center=true);
  }
}

module test_gears() {
  // Pitch radius: 8
  // 360 degrees rotation per cycle
  translate([20, -16, 0]) rotate($t*360 + 22.5) gear(pressure_angle=20, mod=1, num_teeth=8, backlash=0.1);
  // Pitch radius: 16
  // 90 degrees rotation per cycle
  translate([0, -16, 0]) rotate(-$t*90) gear(pressure_angle=20, mod=1, num_teeth=32);
  // Pitch radius: 25
  // 57.6 degrees rotation per cycle
  translate([0, 25, 0]) rotate($t*57.6) gear(pressure_angle=20, mod=1, num_teeth=50);
}

test_gears();
// gear(pressure_angle=20, mod=1, num_teeth=15);
