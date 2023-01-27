use <../../involute_gears.scad>
include <../../../libraries/BOSL2/std.scad>

$fn = $preview ? 50 : 200;

// Common values
tooth_difference = -1;
ring_width = 4;
planets = 4;
pressure_angle = 25;
thickness = 10;
backlash = 0.1;
helix_angle = 30;
rack_base = 10;
translate_planets = [90, 0, 0];

// Input values (outside gear sets)
in_sun_teeth = 8;
in_ring_teeth = 24;
in_mod = 2.5;

// Common calculations
planet_teeth = (in_ring_teeth - in_sun_teeth)/2;
planet_dist = pitch_radius(in_mod, in_sun_teeth) + pitch_radius(in_mod, planet_teeth);

// Input calculations (outside gear sets)
in_ring_pitch_r = pitch_radius(in_mod, in_ring_teeth);
in_ring_r = in_ring_pitch_r + in_mod + ring_width;
in_sun_r = pitch_radius(in_mod, in_sun_teeth) + in_mod;

// Output calculations (middle gear set)
out_ring_teeth = in_ring_teeth + tooth_difference;
out_sun_teeth = in_sun_teeth + tooth_difference;
out_mod = 2*planet_dist/(planet_teeth + out_sun_teeth);
outer_teeth = out_ring_teeth + 10;
center_height = pitch_radius(out_mod, outer_teeth) + rack_base + 1.25*out_mod;
out_ring_r = pitch_radius(out_mod, out_ring_teeth) + out_mod + ring_width;

reduction = out_ring_teeth*(in_ring_teeth+in_sun_teeth)/in_sun_teeth;
echo(str("Reduction: ", reduction));

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

module translate_polar(d, a) {
  translate([d*cos(a), d*sin(a), 0]) children();
}

// Input set
difference() {
  planetary_gear_set(sun_teeth=in_sun_teeth, ring_teeth=in_ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=in_mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);
  
  // Number planets for assembly
  translate(translate_planets) for (i = [0:planets-1]) {
    angle = i*360/planets;
    translate_polar(planet_dist, angle) {
      translate([0, 0, thickness]) text3d(str(i+1), 0.5, 5, anchor=CENTER);
    }
  }
}

// Wrench attachment
union() {
  translate([0, 0, thickness]) cylinder(1, in_sun_r, in_sun_r);
  translate([0, 0, thickness+1]) linear_extrude(10) hexagon(17);
  rotate([0, 0, 30]) translate([0, 0, thickness+1]) linear_extrude(10) hexagon(17);
}

// Stand
difference() {
  translate([-in_ring_r, -center_height, 0]) cube([in_ring_r*2, center_height, thickness+1]);
  translate([0, 0, -0.1]) cylinder(thickness+1.2, in_ring_r, in_ring_r);
  translate([-in_ring_r+thickness/2, -center_height-0.1, (thickness+1)/2]) rotate([-90, 0, 0]) cylinder(center_height, 1.75, 1.75);
  translate([in_ring_r-thickness/2, -center_height-0.1, (thickness+1)/2]) rotate([-90, 0, 0]) cylinder(center_height, 1.75, 1.75);
}

// Retention ring
translate([0, 0, thickness]) difference() {
  cylinder(1, in_ring_r, in_ring_r);
  translate([0, 0, -0.1]) cylinder(1.2, in_ring_pitch_r-1.25*in_mod, in_ring_pitch_r-1.25*in_mod);
}

// Support set
translate([0, 0, -thickness*3]) union() {
  planetary_gear_set(sun_teeth=in_sun_teeth, ring_teeth=in_ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=in_mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);

  // Stand
  translate([0, 0, -1]) difference() {
    translate([-in_ring_r, -center_height, 0]) cube([in_ring_r*2, center_height, thickness+1]);
    translate([0, 0, -0.1]) cylinder(thickness+1.2, in_ring_r, in_ring_r);
    translate([-in_ring_r+thickness/2, -center_height-0.1, (thickness+1)/2]) rotate([-90, 0, 0]) cylinder(center_height, 1.75, 1.75);
    translate([in_ring_r-thickness/2, -center_height-0.1, (thickness+1)/2]) rotate([-90, 0, 0]) cylinder(center_height, 1.75, 1.75);
  }

  // Retention ring
  translate([0, 0, -1]) difference() {
    cylinder(1, in_ring_r, in_ring_r);
    translate([0, 0, -0.1]) cylinder(1.2, in_ring_pitch_r-1.25*in_mod, in_ring_pitch_r-1.25*in_mod);
  }
}

// Output set
translate([0, 0, -2*thickness]) {
  herringbone_planetary_gear_set(sun_teeth=out_sun_teeth, ring_teeth=out_ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=out_mod, thickness=2*thickness, backlash=backlash, helix_angle=helix_angle, translate_planets=translate_planets, translate_sun=[-80, 0, 0], ring_thickness_offset=0.01, evenly_space_planets=true);

  difference() {
    translate([0, 0, 0.01]) herringbone_gear(num_teeth=outer_teeth, pressure_angle=pressure_angle, mod=out_mod, thickness=2*thickness-0.02, backlash=backlash, helix_angle=helix_angle);
    cylinder(2*thickness, out_ring_r, out_ring_r);
  }
}

// Rack
translate([0, -center_height - 2*rack_base, -2*thickness]) herringbone_rack(length=PI*20, width=thickness*2, base_thickness=rack_base, pressure_angle=pressure_angle, mod=out_mod, backlash=backlash, helix_angle=-helix_angle);
