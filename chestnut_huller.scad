$fn = $preview ? 50 : 100;

1_inch = 25.4;
disk_thickness = 0.5*1_inch;
axel_r = 10;
flange_width = 0.5*1_inch;
disk_r = flange_width + axel_r + 1_inch;
screw_r = 3/32*1_inch - 0.2;
screw_head_r = 4.7;
screw_head_depth = 5.5;
root_r = 1_inch/4;
tooth_depth = root_r*3;
num_teeth = 7;
tip_r = 1_inch/4;
tip_base_r = disk_r - tip_r;


module disk() {
  difference() {
    //Disk
    rotate_extrude() {
      difference() {
        square([tip_base_r, disk_thickness]);
        *polygon([
          [0,0],
          [disk_r, 0],
          [disk_r, tip_r],
          [axel_r + flange_width, disk_thickness],
          [0, disk_thickness]
        ]);
        // Circle to scoop out angled portion
        diag_h = disk_thickness - tip_r;
        diag_w = tip_base_r - flange_width - axel_r;
        a = 90 - atan(diag_h/diag_w);
        diag_l = sqrt(diag_h^2 + diag_w^2);
        circle_r = (diag_l/2)/cos(a);
        
        translate([tip_base_r, circle_r + tip_r]) circle(circle_r);
      }
      translate([tip_base_r, 0]) circle(tip_r);
    }
    // Remove underhanging circle
    translate([0, 0, -2*tip_r]) cylinder(2*tip_r, 2*disk_r, 2*disk_r);

    translate([0, 0, -1]) {
      // Axel hole
      cylinder(1_inch, axel_r, axel_r);
      // Screw holes
      for (i = [0:5]) {
        rotate(60*i) translate([axel_r + flange_width/2, 0, 0]) {
          cylinder(1_inch, screw_r, screw_r);
        }
      }
      // Tooth notches
      for (i = [0:num_teeth-1]) {
        rotate((360/num_teeth)*i) translate([disk_r - tooth_depth + root_r, root_r, 0]) {
          // Remove rounded root
          cylinder(2*disk_thickness, root_r, root_r);
          // Cut off hook
          translate([0, -root_r, 0]) cube([tooth_depth, 2*root_r, disk_thickness]);
          // Slope back of tooth
          a = 10;
          y_offset = sin(a)*root_r;
          x_offset = cos(a)*root_r;
          translate([-x_offset, y_offset, 0]) rotate(-a) cube(50);
        }
      }
    }
    // Mark the first tooth
    translate([axel_r + flange_width, 0, 0]) sphere(1);
  }
}

module countersink() {
  for (i = [0:5]) {
    rotate(60*i) translate([axel_r + flange_width/2, 0, 0]) {
      translate([0, 0, disk_thickness + 1]) {
        translate([0, 0, -1]) cylinder(2, screw_head_r, screw_head_r);
        translate([0, 0, -screw_head_depth]) cylinder(screw_head_depth - 0.9, screw_r, screw_head_r);
      }
    }
  }
}



difference() {
  disk();
  *countersink();
}

translate([0, 0, -disk_thickness - 10]) difference() {
  mirror([1, 0, 0]) disk();
  *countersink();
}

