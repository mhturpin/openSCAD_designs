use <involute_gears.scad>

$fn = $preview ? 30 : 200;

mod = 1;
pressure_angle = 20;
sun_teeth = 8;
ring_teeth = 20;
planet_teeth = (ring_teeth - sun_teeth)/2;
thickness = 5;
clearance = 0.2;

// Ring gear
difference() {
  translate([0, 0, -thickness/2]) cylinder(thickness, 12, 12);
  herringbone_gear(pressure_angle=pressure_angle, mod=mod, num_teeth=ring_teeth, thickness=thickness+0.2, addendum=1.25, dedendum=1);
}


// Sun gear
rotate(360/sun_teeth/2) herringbone_gear(pressure_angle=pressure_angle, mod=mod, num_teeth=sun_teeth, thickness=thickness, reverse=true);

// Planet gears
dist = pitch_radius(mod, ring_teeth) - pitch_radius(mod, planet_teeth);
translate([dist, 0, 0]) herringbone_gear(pressure_angle=pressure_angle, mod=mod, num_teeth=planet_teeth, thickness=5, backlash=clearance);
translate([0, -dist, 0]) rotate(360/planet_teeth/2) herringbone_gear(pressure_angle=pressure_angle, mod=mod, num_teeth=planet_teeth, thickness=5, backlash=clearance);
translate([-dist, 0, 0]) herringbone_gear(pressure_angle=pressure_angle, mod=mod, num_teeth=planet_teeth, thickness=5, backlash=clearance);
translate([0, dist, 0]) rotate(360/planet_teeth/2) herringbone_gear(pressure_angle=pressure_angle, mod=mod, num_teeth=planet_teeth, thickness=5, backlash=clearance);



function pitch_radius(mod, teeth) = mod*teeth/2;
