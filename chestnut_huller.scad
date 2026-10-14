$fn = $preview ? 50 : 100;

1_inch = 25.4;
disk_thickness = 0.5*1_inch;
axel_r = 10;
flange_width = (3/8)*1_inch;
tooth_depth = 1_inch;
round_r = 1_inch/6;
disk_r = axel_r + flange_width + tooth_depth;
root_cir_x = axel_r + flange_width + round_r;
screw_r = (3/32)*1_inch - 0.2;
screw_head_r = 4.7;
screw_head_depth = 5.5;
num_screws = 4;
num_teeth = 6;
tooth_degrees = 360/num_teeth;
tip_base_r = disk_r - round_r;


module disk() {
  difference() {
    //Disk
    rotate_extrude() {
      difference() {
        square([tip_base_r, disk_thickness]);

        // Circle to scoop out angled portion
        diag_h = disk_thickness - round_r;
        diag_w = tooth_depth - round_r;
        a = 90 - atan(diag_h/diag_w);
        diag_l = sqrt(diag_h^2 + diag_w^2);
        circle_r = (diag_l/2)/cos(a);

        translate([tip_base_r, circle_r + round_r]) circle(circle_r);
      }
      translate([tip_base_r, 0]) circle(round_r);
    }
    // Remove underhanging circle
    translate([0, 0, -2*round_r]) cylinder(2*round_r, 2*disk_r, 2*disk_r);

    translate([0, 0, -1]) {
      // Axel hole
      cylinder(1_inch, axel_r, axel_r);
      // Screw holes
      for (i = [0:num_screws-1]) {
        rotate((360/num_screws)*i) translate([axel_r + flange_width/2, 0, 0]) {
          cylinder(1_inch, screw_r, screw_r);
        }
      }
      // Tooth notches
      for (i = [0:num_teeth-1]) {
        rotate(tooth_degrees*i) {
          translate([root_cir_x, round_r, 0]) {
            // Remove rounded root
            cylinder(2*disk_thickness, round_r, round_r);

            // Round off sharp corner
            translate([tooth_depth - 2*round_r, -2*round_r, 0]) difference() {
              cube(2*round_r);
              cylinder(2*round_r + 2, round_r, round_r);
            }
          }

          // Remove material between teeth
          // Find the tip circle center
          tip_cir_x = tip_base_r*cos(tooth_degrees) + round_r*sin(tooth_degrees);
          tip_cir_y = tip_base_r*sin(tooth_degrees) - round_r*cos(tooth_degrees);
          // Find the root circle tangent that intersects the tip center
          root_cir_y = round_r;
          center_dist = distance([root_cir_x, root_cir_y], [tip_cir_x, tip_cir_y]);
          centers_angle = atan((tip_cir_y - root_cir_y)/(tip_cir_x - root_cir_x));
          line_angle = centers_angle - asin(round_r/center_dist);
          root_tan_point = [root_cir_x - round_r*sin(line_angle), root_cir_y + round_r*cos(line_angle)];

          linear_extrude(2*disk_thickness) polygon([
            [root_cir_x, 0],
            [2*disk_r, 0],
            [2*tip_cir_x - root_tan_point[0], 2*tip_cir_y - root_tan_point[1]],
            root_tan_point
          ]);
        }
      }
    }
    // Mark the first tooth
    translate([axel_r + flange_width, 0, 0]) sphere(1.5);
    translate([axel_r + flange_width, 0, disk_thickness]) sphere(1.5);
  }
}

module countersink() {
  for (i = [0:num_screws-1]) {
    rotate((360/num_screws)*i) translate([axel_r + flange_width/2, 0, 0]) {
      translate([0, 0, disk_thickness + 1]) {
        translate([0, 0, -1.2]) cylinder(2, screw_head_r, screw_head_r);
        translate([0, 0, -screw_head_depth]) cylinder(screw_head_depth - 1.1, screw_r, screw_head_r);
      }
    }
  }
}

function distance(p1, p2) = sqrt((p1[0] - p2[0])^2 + (p1[1] - p2[1])^2);


difference() {
  disk();
  countersink();
}

translate([0, 0, -10]) difference() {
  mirror([0, 0, 1]) disk();
  translate([0, 0, -disk_thickness]) countersink();
}

