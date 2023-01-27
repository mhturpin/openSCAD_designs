use <involute_gears.scad>

$fn = $preview ? 50 : 200;

ring_teeth = 23;
// planet_teeth = 8
// 8 = (23 - sun_teeth)/2
sun_teeth = 9;
ring_width = 2;
planets = 4;
pressure_angle = 20;
mod = 1;
thickness = 5;

herringbone_planetary_gear_set(sun_teeth=sun_teeth, ring_teeth=ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, helix_angle=30, evenly_space_planets=true, backlash=0.1);