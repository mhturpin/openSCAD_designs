use <../involute_gears.scad>

$fn = $preview ? 50 : 200;

sun_teeth = 20;
ring_teeth = 60;
planet_teeth = (ring_teeth - sun_teeth)/2;
tooth_difference = -1;
ring_width = 2;
planets = 5;
pressure_angle = 20;
mod = 1;
thickness = 10;
backlash = 0.1;
translate_planets = [0, 0, 0];

reduction = (ring_teeth/sun_teeth+1)*(ring_teeth+tooth_difference)*planet_teeth/(ring_teeth-planet_teeth);
echo(str("Reduction: ", reduction));

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

difference() {
  planetary_gear_set(sun_teeth=sun_teeth, ring_teeth=ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);
  // 0.2 clearence close at first, but loosened up
  translate([0, 0, 1]) linear_extrude(20.2) hexagon(4.1);
}

planet_dist = pitch_radius(mod, sun_teeth) + pitch_radius(mod, planet_teeth);
// Planet centers are the same, so adding one to the ring adds one to each planet
out_planet_teeth = planet_teeth + tooth_difference;
out_sun_teeth = ring_teeth + tooth_difference - 2*out_planet_teeth;

translate([0, 0, -11]) planetary_gear_set(sun_teeth=out_sun_teeth, ring_teeth=ring_teeth+tooth_difference, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);

planet_connector_r = pitch_radius(mod, out_planet_teeth) + mod;

translate(translate_planets) for (i = [0:planets-1]) {
  rotate(i*360/planets) translate([planet_dist, 0, -1]) cylinder(1, planet_connector_r, planet_connector_r);
}

in_ring_pitch_r = pitch_radius(mod, ring_teeth);
in_ring_r = in_ring_pitch_r + mod + ring_width;
out_ring_pitch_r = pitch_radius(mod, ring_teeth+tooth_difference);
out_ring_r = pitch_radius(mod, ring_teeth+tooth_difference) + mod + ring_width;

// Stand
*difference() {
  translate([-in_ring_r, 0, 0]) cube([in_ring_r*2, out_ring_r+2, thickness+1]);
  translate([0, 0, -0.1]) cylinder(thickness+1.2, 28, 28);
  translate([-in_ring_r+5, out_ring_r+2-14, 5]) rotate([-90, 0, 0]) cylinder(14.1, 1.75, 1.75);
  translate([in_ring_r-5, out_ring_r+2-14, 5]) rotate([-90, 0, 0]) cylinder(14.1, 1.75, 1.75);
}

// Retention rings
difference() {
  translate([0, 0, thickness]) cylinder(1, in_ring_r, in_ring_r);
  translate([0, 0, thickness-0.1]) cylinder(1.2, in_ring_pitch_r-1.25*mod, in_ring_pitch_r-1.25*mod);
}

difference() {
  translate([0, 0, -thickness-2]) cylinder(1, out_ring_r, out_ring_r);
  translate([0, 0, -thickness-2.1]) cylinder(1.2, out_ring_pitch_r-1.25*mod, out_ring_pitch_r-1.25*mod);
}
