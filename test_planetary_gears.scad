use <involute_gears.scad>

$fn = $preview ? 25 : 100;

mod = 1;
pressure_angle = 20;
thickness = 5;
clearance = 0.2;

function pitch_radius(mod, teeth) = mod*teeth/2;


// https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=61
module planetary_gear_set(sun_teeth, ring_teeth, ring_width, num_planets) {
  assert((ring_teeth-sun_teeth)%2 == 0, "Planet gears must have an integer number of teeth");

  planet_teeth = (ring_teeth - sun_teeth)/2;
  ring_radius = pitch_radius(mod, ring_teeth) + mod + ring_width;

  // Ring gear
  difference() {
    cylinder(thickness, ring_radius, ring_radius);
    translate([0, 0, -0.1]) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=ring_teeth, thickness=thickness+0.2, addendum=1.25, dedendum=1);
  }

  // Sun gear
  // TODO: calc rotation
  gear(pressure_angle=pressure_angle, mod=mod, num_teeth=sun_teeth, thickness=thickness);

  // Planet gears
  dist = pitch_radius(mod, ring_teeth) - pitch_radius(mod, planet_teeth);
  planet_gears(num_planets, dist, sun_teeth, ring_teeth, planet_teeth) {
    gear(pressure_angle=pressure_angle, mod=mod, num_teeth=planet_teeth, thickness=5, backlash=clearance);
  }
}

module planet_gears(num, radius, sun_teeth, ring_teeth, planet_teeth) {
  // https://qtcgears.com/tools/catalogs/PDF_Q420/Tech.pdf#page=61 equation (13-8)
  spacing_number = (sun_teeth + ring_teeth)/num;
  ring_angle_per_tooth = 360/ring_teeth;
  
  for (i = [0:num-1]) {
    location_angle = round(i*spacing_number)*360/(sun_teeth + ring_teeth);
    offset_coefficient = (location_angle%ring_angle_per_tooth)/ring_angle_per_tooth;
    rotation = offset_coefficient*360/planet_teeth;

    rotate(location_angle) translate([radius, 0, 0]) rotate(-rotation) children();
  }
}

planetary_gear_set(8, 22, 2, 4);


