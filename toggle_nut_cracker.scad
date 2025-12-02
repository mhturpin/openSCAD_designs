use <involute_gears.scad>

$fn = $preview ? 50 : 200;
$vpd = 600;
$vpr = [80, 0, 0];
$vpt = [90, 0, 40];


// Figure out rail length and total length based on linkage size
// Figure out handle pivot hight discrepency



length = 200;
thickness = 20;
width = thickness*2;
linkage_length = 40;
linkage_height = thickness*2;
1_inch = 25.4;
pivot_radius = 3/16*1_inch;
pressure_angle = 20;
mod = 1;
tolerance = 0.2;
handle_gear_teeth = 24;
handle_pitch_radius = handle_gear_teeth*mod/2;
handle_pitch_height = linkage_height - handle_pitch_radius;
handle_pivot_height_above_rack = handle_pitch_radius + 1.25*mod;
rack_teeth = 22;
rack_length = PI*mod*rack_teeth;
rack_angle = asin((handle_pitch_height - mod*1.25 - thickness)/(rack_length/2));
rack_horizontal_length = cos(rack_angle)*rack_length;
rack_vertical_length = sin(rack_angle)*rack_length;
rack_vertical_offset = handle_pitch_height - mod*1.25 + rack_vertical_length/2; // The amount we have to move the rack up so that the pitch lines touch
handle_offset = rack_horizontal_length/2; // Center the back handle pivot on the rack

module base() {
  // Base
  cube([length, width, thickness]);

  // Backstop
  translate([0, thickness, 2*thickness]) rotate([0, 90, 0]) cylinder(thickness, width/2, width/2);
  cube([thickness, width, 2*thickness]);

  // Rack
  translate([length, 0, rack_vertical_offset]) {
    rotate([90, rack_angle, 180]) {
      rack(length=rack_length, width=width, pressure_angle=pressure_angle, mod=mod, base_thickness=0);
      
      // Rails for handle
      handle_rail();
      translate([0, 0, 0.75*width]) handle_rail();
    }

    // Rack angled platform
    rotate([-90, 0, 0]) linear_extrude(width) polygon([[0, 0], [0, rack_vertical_length], [-rack_horizontal_length, rack_vertical_length]]);
  }
}

module handle_rail() {
  difference() {
    union() {
      cube([rack_length, handle_pivot_height_above_rack, width/4]);
      translate([thickness/2, 0, 0]) cube([rack_length - thickness, handle_pivot_height_above_rack + thickness/2, width/4]);
      translate([thickness/2, handle_pivot_height_above_rack, 0]) cylinder(width/4, thickness/2, thickness/2);
      translate([rack_length - thickness/2, handle_pivot_height_above_rack, 0]) cylinder(width/4, thickness/2, thickness/2);
    }

    // Slot for pivot
    translate([thickness/2, handle_pivot_height_above_rack - pivot_radius, -0.5]) {
      cube([rack_length - thickness, pivot_radius*2, width/4 + 1]);
      translate([0, pivot_radius, 0]) cylinder(width/4 + 1, pivot_radius, pivot_radius);
      translate([rack_length - thickness, pivot_radius, 0]) cylinder(width/4 + 1, pivot_radius, pivot_radius);
    }
  }
}

module moving_jaw() {
  rotate([0, 90, 0]) difference() {
    hull() {
      // Tapered part
      #cylinder(thickness, thickness*0.75, thickness/2);
      // Rounded back
      translate([0, thickness/2, thickness]) rotate([90, 0, 0]) cylinder(thickness, thickness/2, thickness/2);
    }

    // Flats for attaching the linkage
    translate([-thickness, 0, thickness/2]) {
      translate([0, thickness/2, 0]) cube(2*thickness);
      translate([0, -2.5*thickness, 0]) cube(2*thickness);
    }

    // Hole for the linkage pin
    translate([0, thickness/2 + 1, thickness]) rotate([90, 0, 0]) cylinder(thickness + 2, pivot_radius, pivot_radius);
  }
}

module handle() {
  difference() {
    union() {
      // Long bar
      rotate([0, 0, 15]) translate([0, -thickness/2, 0]) cube([length, thickness, thickness]);
      // Linkage part
      translate([0, -thickness/2, 0]) cube([rack_length, thickness, thickness]);
      // Rounded ends
      cylinder(thickness, thickness/2, thickness/2);
      translate([rack_length, 0, 0]) cylinder(thickness, thickness/2, thickness/2);
      // Teeth
      gear_section_angle = 360*6.5/handle_gear_teeth;
      intersection() {
        gear(num_teeth=handle_gear_teeth, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=tolerance);
        rotate([0, 0, -gear_section_angle]) translate([0, 0, -0.5]) part_cylinder(20, gear_section_angle, thickness + 1);
      }
      root_radius = handle_gear_teeth*mod/2 - mod*1.25;
      angle = gear_section_angle - 90;
      linear_extrude(thickness) polygon([[0, 0], [-thickness/2, 0], [-sin(angle)*root_radius, -cos(angle)*root_radius]]);
    }

    // Pivot holes
    translate([0, 0, -0.5]) {
      cylinder(thickness + 1, pivot_radius, pivot_radius);
      translate([rack_length, 0, 0]) cylinder(thickness + 1, pivot_radius, pivot_radius);
    }
  }
}

module linkage() {
  difference() {
    union() {
      translate([0, -thickness/2, 0]) cube([linkage_length, thickness, width/4]);
      cylinder(width/4, thickness/2, thickness/2);
      translate([linkage_length, 0, 0]) cylinder(width/4, thickness/2, thickness/2);
    }

    // Pivot holes
    translate([0, 0, -1]) {
      cylinder(thickness + 2, pivot_radius, pivot_radius);
      translate([linkage_length, 0, 0]) cylinder(thickness + 2, pivot_radius, pivot_radius);
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
  first_pivot_x_offset = length - handle_offset - rack_length - linkage_length;

  base();
  translate([first_pivot_x_offset - thickness, thickness, linkage_height]) moving_jaw();
  translate([length - handle_offset, thickness/2, linkage_height]) rotate([90, 0, 180]) handle();
  translate([first_pivot_x_offset, thickness/2, linkage_height]) {
    rotate([90, 0, 0]) linkage();
    translate([0, 1.5*thickness, 0]) rotate([90, 0, 0]) linkage();
  }
}
*base();
*moving_jaw();
*handle();
*linkage();

max_opening = length - rack_length - linkage_length - thickness;
echo("Min opening: ", max_opening - rack_horizontal_length);
echo("Max opening: ", max_opening);