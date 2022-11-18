use <involute_gears.scad>

$fn = $preview ? 50 : 200;

sun_teeth = 20;
ring_teeth = 50;
planet_teeth = (ring_teeth - sun_teeth)/2;
planets = 5;
pressure_angle = 20;
mod = 1;
thickness = 10;
backlash = 0.1;

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

// zs⋅ns/(zr+zs)=nc
// ring: 50, sun: 30
// 51*8/3 = 136

difference() {
  planetary_gear_set(sun_teeth=sun_teeth, ring_teeth=ring_teeth, ring_width=2, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash);
  translate([0, 0, -0.1]) linear_extrude(20.2) hexagon(4.2);
}

planet_dist = pitch_radius(mod, sun_teeth) + pitch_radius(mod, planet_teeth);
out_planet_teeth = planet_teeth + 1;
out_sun_teeth = ring_teeth + 1 - 2*out_planet_teeth;

//translate([0, 0, -11]) {
//  ring_gear(num_teeth=ring+1, ring_width=2, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash);
//  translate([planet_dist, 0, 0]) gear(num_teeth=16, pressure_angle=20, mod=1, thickness=10, backlash=0.1);
//}

translate([0, 0, -11]) planetary_gear_set(sun_teeth=out_sun_teeth, ring_teeth=ring_teeth+1, ring_width=2, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash);





// 50 in, 15 p
// 49 out, 15 p