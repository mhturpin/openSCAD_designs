use <involute_gears.scad>

$fn = $preview ? 50 : 200;

sun_teeth = 20;
ring_teeth = 50;
planet_teeth = (ring_teeth - sun_teeth)/2;
ring_width = 2;
planets = 5;
pressure_angle = 20;
mod = 1;
thickness = 10;
backlash = 0.1;
translate_planets = [0, 0, 0];

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

// (R + S)*Tc = R*Tr + Ts*S
// (50 + 20)*1 = 50*0 + Ts*20
// Ts = 70/20 = 3.5
// 51*3.5 = 178.5

difference() {
  planetary_gear_set(sun_teeth=sun_teeth, ring_teeth=ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);
  translate([0, 0, -0.1]) linear_extrude(20.2) hexagon(4.2);
}

planet_dist = pitch_radius(mod, sun_teeth) + pitch_radius(mod, planet_teeth);
// Planet centers are the same, so adding one to the ring adds one to each planet
out_planet_teeth = planet_teeth + 1;
out_sun_teeth = ring_teeth + 1 - 2*out_planet_teeth;

translate([0, 0, -11]) planetary_gear_set(sun_teeth=out_sun_teeth, ring_teeth=ring_teeth+1, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);

planet_connector_r = pitch_radius(mod, out_planet_teeth) + mod;

translate(translate_planets) for (i = [0:planets-1]) {
  rotate(i*360/planets) translate([planet_dist, 0, -1]) cylinder(1, planet_connector_r, planet_connector_r);
}

in_ring_pitch_r = pitch_radius(mod, ring_teeth);
in_ring_r = in_ring_pitch_r + mod + ring_width;
out_ring_pitch_r = pitch_radius(mod, ring_teeth+1);
out_ring_r = pitch_radius(mod, ring_teeth+1) + mod + ring_width;

// Stand
difference() {
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
  translate([0, 0, -thickness-2]) cylinder(1, 28.5, 28.5);
  translate([0, 0, -thickness-2.1]) cylinder(1.2, out_ring_pitch_r-1.25*mod, out_ring_pitch_r-1.25*mod);
}
