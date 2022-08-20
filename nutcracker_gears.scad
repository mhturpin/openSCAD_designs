use <MCAD/involute_gears.scad>

$fn=50;

difference() {
    gear(number_of_teeth=115,
        diametral_pitch=10,
        gear_thickness=1,
        rim_thickness=1,
        hub_thickness=1,
        bore_diameter=0,
        backlash=0,
        clearance=0,
        pressure_angle=20);
    translate([-5, 0, 0]) cube([20, 20, 3], center=true);
    translate([5, 3.3125, 0]) cube([2, 2, 3], center=true);
    translate([5, -3.3125, 0]) cube([2, 2, 3], center=true);
}

translate([6.4, 0, 0]) gear(number_of_teeth=13,
    diametral_pitch=10,
    gear_thickness=1,
    rim_thickness=1,
    hub_thickness=1,
    bore_diameter=5/16,
    backlash=1/128,
    clearance=0,
    pressure_angle=20);
