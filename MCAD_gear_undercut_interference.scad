use <MCAD/involute_gears.scad>

$fn=50;

// 6 tooth gear: pitch diameter = 6/0.5 = 12
// 99 tooth gear: pitch diameter = 99/0.5 = 198

difference() {
  rotate(45) gear(number_of_teeth=6,
    diametral_pitch=0.5,
    gear_thickness=1,
    rim_thickness=1,
    hub_thickness=1,
    bore_diameter=0,
    backlash=1/128,
    clearance=0,
    pressure_angle=20);

  translate([105, 0, -0.1]) rotate(-2.72727) gear(number_of_teeth=99,
    diametral_pitch=0.5,
    gear_thickness=1.2,
    rim_thickness=1.2,
    hub_thickness=1.2,
    bore_diameter=0,
    backlash=1/128,
    clearance=0,
    pressure_angle=20);
}

difference() {
  translate([105, 0, 0]) rotate(-2.72727) gear(number_of_teeth=99,
    diametral_pitch=0.5,
    gear_thickness=1,
    rim_thickness=1,
    hub_thickness=1,
    bore_diameter=0,
    backlash=1/128,
    clearance=0,
    pressure_angle=20);

  translate([0, 0, -0.1]) rotate(45) gear(number_of_teeth=6,
    diametral_pitch=0.5,
    gear_thickness=1.2,
    rim_thickness=1.2,
    hub_thickness=1.2,
    bore_diameter=0,
    backlash=1/128,
    clearance=0,
    pressure_angle=20);
}
