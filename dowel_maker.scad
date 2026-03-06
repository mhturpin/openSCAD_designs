$fn = $preview ? 50 : 200;
$vpd = 200;
$vpr = [45, 0, 30];
$vpt = [20, -30, 30];

// Screw diameter






// Constants, base measurement is mm
1_inch = 25.4;
clearance = 0.2;

// Setings
dowel_diameter = 5/8*1_inch;
stock_radius = (dowel_diameter + (3/8)*1_inch)/2; // Maximum stock dimension
blade_width = 55;
blade_height = 50;
blade_thickness = 2;
screw_hole_radius = 1;
advance = 3; // How much the blade advances per turn
wall_thickness = 1_inch/4;
alignment_pin_depth = 1_inch/2;

// Calculated values
dowel_radius = dowel_diameter/2;
recess_depth = (blade_height - 1_inch/2)/sqrt(2); // Leave 1/2" of the blade protruding
stock_tube_radius = stock_radius + wall_thickness; // Outer radius of stock guide
dowel_tube_radius = dowel_radius + wall_thickness; // Outer radius of dowel guide
tube_length = 2*dowel_diameter;
blade_offset = advance + 1; // Shift the blade to accomodate the advancing stock, and a gap for shavings
blade_angle = atan(advance/(PI*dowel_diameter));
blade_wall_thickness = 1_inch/2;
blade_holder_x = (blade_height - 1_inch/2)/sqrt(2);
blade_holder_y = blade_width + 2*blade_wall_thickness;
blade_holder_z = 20;


module dowel_guide() {
  difference() {
    union() {
      // Stock entrance guide
      rotate([0, 90, 0]) cylinder(tube_length, stock_tube_radius, stock_tube_radius);
      // Dowel exit guide
      rotate([0, -90, 0]) cylinder(tube_length, dowel_tube_radius, dowel_tube_radius);
      // Center block
      block_points = [
        [stock_tube_radius, stock_tube_radius],
        [stock_tube_radius, -stock_tube_radius],
        [-stock_tube_radius + alignment_pin_depth, -blade_holder_y/2],
        [-stock_tube_radius, -blade_holder_y/2],
        [-stock_tube_radius, blade_holder_y/2],
        [-stock_tube_radius + alignment_pin_depth, blade_holder_y/2]
      ];
      rotate([0, 90, 0]) linear_extrude(blade_holder_x) polygon(block_points);
      
    }

    // Hollow out tubes
    rotate([0, 90, 0]) translate([0, 0, -1]) cylinder(tube_length + 2, stock_radius, stock_radius);
    rotate([0, -90, 0]) translate([0, 0, -1]) cylinder(tube_length + 2, dowel_radius, dowel_radius);
    // Remove the blade recess, plus 3mm extra adjustment depth
    position_blade() translate([-3, 0, 0]) cube([blade_height, blade_width + clearance, 100]);
    // Alignment pins
    translate([0, 0, stock_tube_radius - alignment_pin_depth]) alignment_pins();

    // Slot/relief for screw and washer
    
    
  }
}

module blade_holder() {
  difference() {
    // Block
    translate([0, -blade_holder_y/2, stock_tube_radius]) cube([blade_holder_x, blade_holder_y, blade_holder_z]);

    // Remove the blade, screw, and anything below
    position_blade() {
      // Blade and below
      translate([0, 0, blade_thickness - 50]) cube([blade_height, blade_width + clearance, 50]);
      // Screw hole
      translate([blade_height/2, blade_width/2, blade_thickness - 0.1]) cylinder(18, screw_hole_radius, screw_hole_radius);
    }
    // Alignment pins
    translate([0, 0, stock_tube_radius - alignment_pin_depth]) alignment_pins();
  }
}

module position_blade() {
  translate([blade_offset, 0, dowel_radius]) { // Raise blade to the dowel radius, and shift back for the offset
    rotate([0, -45, blade_angle]) { // Rotate 45 for blade angle and blade_angle so it advances
      translate([0, -(blade_width + clearance)/2, -blade_thickness]) { // Shift blade to intersect the origin
        children();
      }
    }
  }
}

module alignment_pins() {
  pin_x_1 = 1_inch/4;
  pin_y = blade_holder_y/2 - 1_inch/4;
  translate([pin_x_1, pin_y, 0]) alignment_pin();
  translate([pin_x_1, -pin_y, 0]) alignment_pin();
  pin_x_2 = blade_holder_x - 1_inch/4;
  translate([pin_x_2, pin_y, 0]) alignment_pin();
  translate([pin_x_2, -pin_y, 0]) alignment_pin();
}

module alignment_pin() {
  cylinder(2*alignment_pin_depth, 1_inch/8, 1_inch/8);
}



dowel_guide();
translate([0, 0, 5]) blade_holder();

