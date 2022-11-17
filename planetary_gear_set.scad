use <involute_gears.scad>

$fn = $preview ? 25 : 100;

mod = 1;
pressure_angle = 20;
thickness = 5;
clearance = 0.2;

function pitch_radius(mod, teeth) = mod*teeth/2;

// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=61
module planetary_gear_set(sun, ring, ring_width, num_planets) {
  assert((ring-sun)%2 == 0, "Planet gears must have an integer number of teeth");

  planet_teeth = (ring - sun)/2;
  ring_radius = pitch_radius(mod, ring) + mod + ring_width;

  // Ring gear
  difference() {
    cylinder(thickness, ring_radius, ring_radius);
    translate([0, 0, -0.1]) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=ring, thickness=thickness+0.2, addendum=1.25, dedendum=1);
  }

  // Sun gear
  sun_rotation = planet_teeth%2 == 0 ? 180/sun : 0;
  rotate(sun_rotation) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=sun, thickness=thickness);

  // Planet gears
  dist = pitch_radius(mod, ring) - pitch_radius(mod, planet_teeth);
  // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=61 equation (13-8)
  spacing_number = (sun + ring)/num_planets;
  ring_angle_per_tooth = 360/ring;

  half_min_spacing_angle = floor(spacing_number)*180/(sun + ring);
  planet_od = pitch_radius(mod, planet_teeth)*2 + 2*mod;
  planet_center_to_center = 2*(pitch_radius(mod, sun) + pitch_radius(mod, planet_teeth))*sin(half_min_spacing_angle);

  assert(planet_od < planet_center_to_center, "Planet gears will interfere");

  for (i = [0:num_planets-1]) {
    location_angle = round(i*spacing_number)*360/(sun + ring);
    offset_coefficient = (location_angle%ring_angle_per_tooth)/ring_angle_per_tooth;
    rotation = offset_coefficient*360/planet_teeth;

    rotate(location_angle) translate([dist, 0, 0]) rotate(-rotation) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=planet_teeth, thickness=5, backlash=clearance);
  }
}

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

difference() {
  planetary_gear_set(8, 20, 2, 4);
  translate([0, 0, -0.1]) linear_extrude(thickness+0.2) hexagon(4);
}

ring_radius = pitch_radius(mod, 20) + mod + 2;
translate([0, 0, -1]) cylinder(1, ring_radius, ring_radius);
