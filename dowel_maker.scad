$fn = $preview ? 50 : 200;
$vpd = 200;
$vpr = [45, 0, 30];
$vpt = [20, -30, 30];



// TODO
// * Cut outs on guide tube to reduce printing?
// * Add size labels to guides
// Squares stick out on dowel guide
// Make stock tube so it doesn't need printing supports
// Stock tube cut 45 based on blade position


// Constants, base measurement is mm
1_inch = 25.4;
clearance = 0.25;

// Setings
dowel_diameter = 5/8*1_inch;
blade_width = 55;
blade_height = 50;
blade_thickness = 2;
adjustment_hole_center = 9;
screw_hole_radius = 2 - clearance;
screw_head_radius = 4.15;
advance = 3; // How much the blade advances per turn
wall_thickness = 1_inch/4;
alignment_pin_radius = 1_inch/8;

// Calculated values
dowel_radius = dowel_diameter/2;
stock_radius = dowel_radius + 1_inch/4; // Maximum stock dimension
dowel_outer_radius = dowel_radius + wall_thickness;
stock_outer_radius = stock_radius + wall_thickness;
recess_depth = (blade_height - 1_inch/2)/sqrt(2); // Leave 1/2" of the blade protruding
tube_length = 3*dowel_diameter;
blade_offset = advance + 1; // Shift the blade to accomodate the advancing stock, and a gap for shavings
blade_angle = atan(advance/(PI*dowel_diameter));
blade_height_shadow = blade_height/sqrt(2); // The length of the blade after it's tilted 45
blade_holder_height = blade_height_shadow;
blade_holder_length = 2*blade_holder_height;
blade_holder_width = blade_width + 2*wall_thickness;
chip_exit_radius = 1.5*blade_offset;


module dowel_guide_tube() {
  difference() {
    translate([-2*blade_offset, 0, 0]) rotate([0, -90, 0]) difference() {
      union() {
        // Tube
        cylinder(tube_length, dowel_outer_radius, dowel_outer_radius);

        // Attachment block
        block_height = stock_outer_radius + dowel_outer_radius;
        translate([-block_height/2 + dowel_outer_radius, 0, alignment_pin_radius*2]) cube_with_relief(block_height, blade_holder_width, alignment_pin_radius*4);

        // Fill in corners below dowel holes
        translate([dowel_outer_radius - wall_thickness, blade_holder_width/2, 0]) rotate(225) cube([wall_thickness*sqrt(2), wall_thickness*sqrt(2), alignment_pin_radius*4]);
        translate([dowel_outer_radius - wall_thickness, -blade_holder_width/2, 0]) rotate(45) cube([wall_thickness*sqrt(2), wall_thickness*sqrt(2), alignment_pin_radius*4]);

        // Holes to align with stock tube
        tube_alignment_blocks();
        
        // Support nub for the end of the tube
        nub_points = [
          [0, 0],
          [wall_thickness, 0],
          [stock_outer_radius + wall_thickness, stock_outer_radius],
          [0, stock_outer_radius],
        ];
        translate([-stock_outer_radius, wall_thickness/2, tube_length]) rotate([0, 90, -90]) linear_extrude(wall_thickness) polygon(nub_points);
      }

      // Remove the center
      translate([0, 0, -1]) cylinder(tube_length + 2, dowel_radius, dowel_radius);
      
      // Dowel alignment holes
      translate([dowel_outer_radius, 0, 2*alignment_pin_radius]) rotate([0, 90, 0]) alignment_pins();
    }
  }
}

module cube_with_relief(x, y, z) {
  difference() {
    // Cube
    cube([x, y, z], center=true);

    // Remove center
    cube([x - 2*wall_thickness, y - 2*wall_thickness, z + 2], center=true);
  }

  // Ensure the center has support
  cube([x, 2*wall_thickness, z], center=true);
}

module stock_guide_tube() {
  translate([0, 0, 0]) rotate([0, 90, 0]) difference() {
    union() {
      // Tube
      cylinder(tube_length + 1_inch/2, stock_outer_radius, stock_outer_radius);

      // Support block
      linear_extrude(wall_thickness) polygon([[0, 0], [stock_outer_radius, stock_outer_radius], [stock_outer_radius, -stock_outer_radius]]);

      // Holes to align with dowel tube
      tube_alignment_blocks();

      // Flat spot for clamping
      translate([0, 0, tube_length]) cube([2*stock_outer_radius, 1_inch, 1_inch], center=true);
    }

    // Remove the center
    translate([0, 0, -1]) cylinder(tube_length  + 1_inch/2 + 2, stock_radius, stock_radius);
    
    // Relief for blade holder
    rotate([0, -135, 0]) translate([0, -blade_holder_width/2 - 1, 0]) cube([2*stock_outer_radius, blade_holder_width + 2, 2*stock_outer_radius]);

    // Remove alignment pin holes that got filled in by the tube
    translate([0, stock_outer_radius, 0]) alignment_pin();
    translate([0, -stock_outer_radius, 0]) alignment_pin();
  }
}

module tube_alignment_blocks() {
  difference() {
    union() {
      // Connector block to ensure attachment
      translate([-alignment_pin_radius, dowel_radius + wall_thickness/2, 0]) cube([2*alignment_pin_radius, 2*alignment_pin_radius, 3*alignment_pin_radius]);
      translate([-alignment_pin_radius, -dowel_radius - wall_thickness/2 - 2*alignment_pin_radius, 0]) cube([2*alignment_pin_radius, 2*alignment_pin_radius, 3*alignment_pin_radius]);

      // Cylinders for alignment pins
      translate([0, stock_outer_radius, 0]) cylinder(3*alignment_pin_radius, 2*alignment_pin_radius, 2*alignment_pin_radius);
      translate([0, -stock_outer_radius, 0]) cylinder(3*alignment_pin_radius, 2*alignment_pin_radius, 2*alignment_pin_radius);
    }

    // Remove alignment pin holes
    translate([0, stock_outer_radius, 0]) alignment_pin();
    translate([0, -stock_outer_radius, 0]) alignment_pin();
  }
}

module blade_holder() {
  difference() {
    // Block
    translate([-blade_holder_length/2, -blade_holder_width/2, 0]) cube([blade_holder_length, blade_holder_width, blade_holder_height]);

    position_blade() {
      // Blade slot
      translate([-blade_offset, 0, -(blade_height - blade_thickness)]) cube([2*blade_height, blade_width + 2*clearance, blade_height]);

      // Remove the wings
      translate([0, -blade_width/2, -blade_height]) cube([2*blade_height, 2*blade_width, blade_height]);

      // Attachment screw hole
      translate([blade_width/2, blade_width/2, 0]) cylinder(blade_holder_height/2, screw_hole_radius, screw_hole_radius);

      // Adjustment screw holes
      translate([blade_height - 1_inch/4 + 1, adjustment_hole_center, screw_head_radius + blade_thickness/4]) rotate([0, -90, 0]) cylinder(blade_holder_height/2, screw_hole_radius, screw_hole_radius);
      translate([blade_height - 1_inch/4 + 1, blade_width - adjustment_hole_center, screw_head_radius + blade_thickness/4]) rotate([0, -90, 0]) cylinder(blade_holder_height/2, screw_hole_radius, screw_hole_radius);

      translate([0, -wall_thickness - 1, 0]) {
      // Adjustment screw chamfer
      translate([blade_height - 1_inch/4, -2, -1]) rotate([0, 0, 0]) cube([blade_holder_height, blade_holder_width + 4, blade_holder_height]);

      // Gap for chips
        translate([-chip_exit_radius, 0, -1]) cube([2*chip_exit_radius, blade_holder_width + 2, 2*chip_exit_radius + 1]);
        translate([chip_exit_radius, 0, chip_exit_radius]) rotate([-90, 0, 0]) cylinder(blade_holder_width + 2, chip_exit_radius, chip_exit_radius);
      }
    }

    // Remove section to sit on top of dowel guide
    translate([-blade_holder_length/2, -blade_holder_width/2 - 1, -1]) cube([blade_holder_length, blade_holder_width + 2, wall_thickness + 1]);

    // Holes for alignment pins
    translate([-2*blade_offset - 2*alignment_pin_radius, 0, wall_thickness]) alignment_pins();

    // Reduce mass for printing
    translate([-blade_holder_length/2, 0, 0]) rotate(60) cube(2*blade_holder_height);
    translate([-blade_holder_length/2, 0, 0]) rotate(-150) cube(2*blade_holder_height);
  }
}

module position_blade() {
  rotate([0, -45, blade_angle]) { // Rotate 45 for blade angle and blade_angle so it advances
    translate([0, -blade_width/2 + clearance, -blade_thickness]) { // Shift blade to intersect the origin
      children();
    }
  }
}

module alignment_pins() {
  pin_distance = blade_holder_width/2 - 2*alignment_pin_radius;

  translate([0, pin_distance, 0]) alignment_pin();
  translate([0, -pin_distance, 0]) alignment_pin();
}

module alignment_pin() {
  cylinder(4*alignment_pin_radius, alignment_pin_radius, alignment_pin_radius, center=true);
}







union() {
  stock_guide_tube();
  dowel_guide_tube();

  translate([0, 0, dowel_radius + 10]) {
    // Blade for visualization purposes
    *#position_blade() cube([blade_height, blade_width, blade_thickness]);
    blade_holder();
  }
}
