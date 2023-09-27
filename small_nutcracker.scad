include <../libraries/BOSL2/std.scad>
include <../libraries/BOSL2/threading.scad>
use <involute_gears.scad>

$fn = $preview ? 20 : 200;
$vpd = 700;
$vpr = [0, 0, 0];
$vpt = [0, -10, 0];

// Parameters
1_inch = 25.4;
thickness = 1_inch*3/4;
pressure_angle = 28;
mod = 3;
clearance = 0.2;
handle_teeth = 8;
center_gear_teeth = 56;
pivot_radius = ((5/16)*1_inch + clearance)/2;
handle_connecter_length = 30;
support_width = pivot_radius*4;

// Calculated variables
// Pitch diameter = module*teeth
handle_pitch_radius = mod*handle_teeth/2;
handle_root_radius = handle_pitch_radius - 1.25*mod;
center_pitch_radius = mod*center_gear_teeth/2;
center_root_radius = center_pitch_radius - 1.25*mod;
half_gear = thickness/2;
pivot_height = (center_pitch_radius + mod)/sqrt(2);
handle_pivot_distance = center_pitch_radius + handle_pitch_radius;
jaw_bolt_offset = pivot_radius + 1_inch/4 + 1;
base_width = thickness + support_width;
base_length = pivot_height + 3*1_inch + support_width/2 + handle_pivot_distance + 1.5*support_width;


module center_gear_piece() {
  difference() {
    union() {
      difference() {
        intersection() {
          gear(pressure_angle=pressure_angle, mod=mod, num_teeth=center_gear_teeth, thickness=thickness, backlash=clearance);

          root_point = [center_root_radius, 0];
          double_root_point = [center_root_radius*2, 0];

          mask_points = [
            [-pivot_radius*2, -20],
            rotate_point(root_point, -22.5),
            rotate_point(double_root_point, -22.5),
            rotate_point(double_root_point, 22.5),
            rotate_point(root_point, 22.5),
            [0, pivot_radius*2],
            [-pivot_radius*2, 0]
          ];
          linear_extrude(thickness) polygon(mask_points);
        }

        // Remove mass from the center of the gear
        translate([0, 0, -1]) rotate(-15) part_cylinder(center_root_radius - 10, 30, thickness + 2);
      }

      // Add thickness around pivot
      cylinder(thickness, pivot_radius*2, pivot_radius*2);
    }

    // Gear pivot hole
    pivot_cylinder(thickness);

    // Jaw bolt hole (1/2 13)
    translate([1_inch/2 - pivot_radius*2 - 0.01, -jaw_bolt_offset, thickness/2]) rotate([0, 90, 0]) threaded_rod(1_inch/2 + 2*clearance, 1_inch, 1_inch/13);
  }
}

module handle_piece() {
  difference() {
    union() {
      // Gear part
      intersection() {
        rotate(180/handle_teeth) gear(pressure_angle=pressure_angle, mod=mod, num_teeth=handle_teeth, thickness=thickness, backlash=clearance);
        rotate(360/handle_teeth) handle_gear_mask();
      }

      // Handle part
      translate([handle_root_radius, 0, thickness/2]) rotate([0, 90, 0]) difference() {
        hull() {
          cube([thickness, handle_root_radius*2, 0.001], center=true);
          translate ([0, 0, handle_connecter_length]) linear_extrude (0.001) circle (handle_root_radius);
        }

        // Hole for handle connection (1/4 20 threaded rod)
        // Outer diameter, length, thread width (length/# threads)
        translate([0, 0, handle_connecter_length/2]) threaded_rod(1_inch/4 + 2*clearance, handle_connecter_length + 0.1, 1_inch/20);
      }

      // Connect gear to tapered section
      translate ([0, -handle_root_radius, 0]) cube([handle_root_radius, handle_root_radius*2, thickness]);
    }

    // Gear center hole
    pivot_cylinder(thickness);
  }
}

module handle_gear_mask() {
  outer_radius = 3*handle_teeth/2 + 3;
  cylinder(thickness+1, handle_root_radius, handle_root_radius);
  // Keep half the teeth
  part_cylinder(outer_radius, 4*360/handle_teeth, thickness+1);
}

module base() {
  // Two sides
  translate([0, 0, -support_width/2]) base_side();
  translate([0, 0, thickness]) base_side();
  // Connect handle supports
  translate([handle_pivot_distance - support_width/2, -pivot_height, 0]) cube([2*support_width, support_width, thickness]);

  // Stop with threaded hole
  translate([-3*1_inch - support_width/2, 0, -support_width/2]) back_stop();
}

module base_side() {
  // Handle support
  translate([handle_pivot_distance, 0, 0]) handle_support();

  // Center gear support
  vertical_support();

  // Center pivot brace
  difference() {
    center_pivot_brace();
    pivot_cylinder(support_width/2);
  }

  translate([0, -pivot_height, 0]) cube([handle_pivot_distance, support_width, support_width/2]);
}

module handle_support() {
  difference() {
    union() {
      cylinder(support_width/2, support_width/2, support_width/2);
      translate([support_width, -support_width*sqrt(3), 0]) cylinder(support_width/2, support_width/2, support_width/2);
      support_points = [
        [0, 0],
        [0, -pivot_height],
        [2*support_width, -pivot_height],
        [2*support_width, -support_width*sqrt(3)],
        [support_width*(1.5 + cos(30)/2), support_width*(sin(30)/2 - sqrt(3))],
        [support_width*(.5 + cos(30)/2), support_width*(sin(30)/2)]
      ];

      translate([-support_width/2, 0, 0]) linear_extrude(support_width/2) polygon(support_points);
    }

    // Remove the slot
    pivot_cylinder(support_width/2);
    translate([support_width, -support_width*sqrt(3), 0]) pivot_cylinder(support_width/2);
    rotate(-60) translate([0, -support_width/4, -1]) cube([2*support_width, 2*pivot_radius, support_width/2 + 2]);
  }
}

module vertical_support() {
  difference() {
    union() {
      cylinder(support_width/2, support_width/2, support_width/2);
      translate([-support_width/2, -pivot_height, 0]) cube([support_width, pivot_height, support_width/2]);
    }

    pivot_cylinder(support_width/2);
  }
}

module center_pivot_brace() {
  // Bottom left corner of the handle support
  handle_support_corner = [handle_pivot_distance - support_width/2, -pivot_height];
  // Distance to handle_support_corner from the center pivot
  handle_support_corner_distance = sqrt((handle_support_corner[0])^2 + (handle_support_corner[1])^2);

  // Rectangle with middle of left side on the center of the center gear pivot and
  // bottom right corner on the handle_support_bottom_left point
  brace_length = sqrt(handle_support_corner_distance^2 - (support_width/2)^2);

  handle_support_corner_angle = abs(atan(handle_support_corner[0]/handle_support_corner[1]));
  brace_angle = 90 - (asin(support_width/2/handle_support_corner_distance) + handle_support_corner_angle);
  rotate(-brace_angle) translate([0, -support_width/2, 0]) cube([brace_length, support_width, support_width/2]);
}

module back_stop() {
  difference() {
    union() {
      stop_points = [
        [0, 0],
        [0, -pivot_height],
        [-pivot_height, -pivot_height],
        [-pivot_height, -pivot_height + 1_inch/2],
        [-pivot_height + 1_inch/2*(1 - 1/sqrt(2)), -pivot_height + 1_inch/2*(1 + 1/sqrt(2))],
        [-1_inch/2*(1 + 1/sqrt(2)), 1_inch/2*(1/sqrt(2) - 1)],
        [-1_inch/2, 0],
      ];
      linear_extrude(base_width) polygon(stop_points);

      translate([-pivot_height + 1_inch/2, -pivot_height + 1_inch/2, 0]) cylinder(thickness + support_width, 1_inch/2, 1_inch/2);
      translate([-1_inch/2, -1_inch/2, 0]) cylinder(thickness + support_width, 1_inch/2, 1_inch/2);
      translate([0, -pivot_height, 0]) cube([3*1_inch, 1_inch, base_width]);
      translate([3*1_inch, -pivot_height, support_width/2]) cube([support_width, 1_inch, thickness]);
    }

    // Bolt hole (1/2 13)
    translate([-19, -jaw_bolt_offset, base_width/2]) rotate([0, 90, 0]) threaded_rod(1_inch/2 + 2*clearance, 40, 1_inch/13);

    // TODO: bolt holes on the bottom
  }
}

module pivot_cylinder(height) {
  translate([0, 0, -1]) cylinder(height + 2, pivot_radius, pivot_radius);
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

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

union() {
  center_gear_piece();
  translate([center_pitch_radius + handle_pitch_radius, 0, 0]) handle_piece();
  base();
}

echo(base_length);
echo(base_length/1_inch);














