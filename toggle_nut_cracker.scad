use <involute_gears.scad>

$fn = $preview ? 50 : 200;
$vpd = 600;
$vpr = [80, 0, 0];
$vpt = [90, 0, 40];


// Figure out rail length and total length based on linkage size
// Figure out handle pivot hight discrepency



length = 200;
d = 10; // The base dimension
width = d*4;
1_inch = 25.4;
pivot_radius = 3/16*1_inch;
pressure_angle = 20;
mod = 2;
tolerance = 0.2;
rack_teeth = 10;
rack_length = PI*mod*rack_teeth;
handle_gear_teeth = 24;
handle_pitch_radius = handle_gear_teeth*mod/2;
handle_pivot_height = handle_pitch_radius + 1.25*mod; // The height above the base of the rack
linkage_length = 40;
linkage_height = d*2 + handle_pivot_height;


module base() {
  // Base
  cube([length, width, d*2]);

  // Backstop
  translate([0, d*2, d*4]) rotate([0, 90, 0]) cylinder(d*2, width/2, width/2);
  cube([d*2, width, d*4]);

  // Rack
  translate([length, 0, d*2]) {
    rotate([90, 0, 180]) {
      rack(length=rack_length, width=width, pressure_angle=pressure_angle, mod=mod, base_thickness=0);

      // Rails for handle
      handle_rail();
      translate([0, 0, 0.75*width]) handle_rail();
    }
  }
}

module handle_rail() {
  difference() {
    union() {
      cube([rack_length, handle_pivot_height, d]);
      translate([d, 0, 0]) cube([rack_length - d*2, handle_pivot_height + d, d]);
      translate([d, handle_pivot_height, 0]) cylinder(d, d, d);
      translate([rack_length - d, handle_pivot_height, 0]) cylinder(d, d, d);
    }

    // Slot for pivot
    translate([d, handle_pivot_height - pivot_radius, -0.5]) {
      cube([rack_length - d*2, pivot_radius*2, d + 1]);
      translate([0, pivot_radius, 0]) cylinder(d + 1, pivot_radius, pivot_radius);
      translate([rack_length - d*2, pivot_radius, 0]) cylinder(d + 1, pivot_radius, pivot_radius);
    }
  }
}

module moving_jaw() {
  rotate([0, 90, 0]) difference() {
    hull() {
      // Tapered part
      cylinder(d*2, d*2*0.75, d);
      // Rounded back
      translate([0, d, d*2]) rotate([90, 0, 0]) cylinder(d*2, d, d);
    }

    // Flats for attaching the linkage
    translate([-d*2, 0, d]) {
      translate([0, d, 0]) cube(d*4);
      translate([0, -5*d, 0]) cube(d*4);
    }

    // Hole for the linkage pin
    translate([0, d + 1, d*2]) rotate([90, 0, 0]) cylinder(d*2 + 2, pivot_radius, pivot_radius);
  }
}

module handle() {
  difference() {
    union() {
      // Long bar
      rotate([0, 0, 15]) translate([0, -d, 0]) cube([length, d*2, d*2]);
      // Linkage part
      translate([0, -d, 0]) cube([rack_length, d*2, d*2]);
      // Rounded ends
      cylinder(d*2, d, d);
      translate([rack_length, 0, 0]) cylinder(d*2, d, d);
      // Teeth
      gear_section_angle = 360*6.5/handle_gear_teeth;
      intersection() {
        gear(num_teeth=handle_gear_teeth, pressure_angle=pressure_angle, mod=mod, thickness=d*2, backlash=tolerance);
        rotate([0, 0, -gear_section_angle]) translate([0, 0, -0.5]) part_cylinder(20, gear_section_angle, d*2 + 1);
      }
      root_radius = handle_gear_teeth*mod/2 - mod*1.25;
      angle = gear_section_angle - 90;
      linear_extrude(d*2) polygon([[0, 0], [-d, 0], [-sin(angle)*root_radius, -cos(angle)*root_radius]]);
    }

    // Pivot holes
    translate([0, 0, -0.5]) {
      cylinder(d*2 + 1, pivot_radius, pivot_radius);
      translate([rack_length, 0, 0]) cylinder(d*2 + 1, pivot_radius, pivot_radius);
    }
  }
}

module linkage() {
  difference() {
    union() {
      translate([0, -d, 0]) cube([linkage_length, d*2, d]);
      cylinder(d, d, d);
      translate([linkage_length, 0, 0]) cylinder(d, d, d);
    }

    // Pivot holes
    translate([0, 0, -1]) {
      cylinder(d*2 + 2, pivot_radius, pivot_radius);
      translate([linkage_length, 0, 0]) cylinder(d*2 + 2, pivot_radius, pivot_radius);
    }
  }
}

// Wedge section of a cylinder
module part_cylinder(r, angle, height, center=false) {
  intersection() {
    cylinder(height, r, r, center=center);

    double_radius_point = [r*2, 0];
    mask_points = [
      [0, 0],
      each [for (i = 0; i < angle; i = i + 90) rotate_point(double_radius_point, i)],
      rotate_point(double_radius_point, angle)
    ];
    translate([0, 0, -height*(center ? 1 : 0)/2]) linear_extrude(height) polygon(mask_points);
  }
}

union() {
  first_pivot_x_offset = length - rack_length/2 - rack_length - linkage_length;

  base();
  translate([first_pivot_x_offset - d*2, d*2, linkage_height]) moving_jaw();
  translate([length - rack_length/2, d, linkage_height]) rotate([90, 0, 180]) handle();
  translate([first_pivot_x_offset, d, linkage_height]) {
    rotate([90, 0, 0]) linkage();
    translate([0, d*3, 0]) rotate([90, 0, 0]) linkage();
  }
}
*base();
*moving_jaw();
*handle();
*linkage();

max_opening = length - rack_length - linkage_length - d*2;
echo("Min opening: ", max_opening - rack_length);
echo("Max opening: ", max_opening);
