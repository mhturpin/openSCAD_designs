$fn = $preview ? 50 : 200;
$vpd = 200;
$vpr = [45, 0, 30];
$vpt = [20, -30, 30];

// Screw diameter
// Instead of starting with a block and trimming, build up components
// Dowel exit cylinder
// Stock entrance cylinder
// Flat surface for clamping (same as blade bed?)
// Blade bed






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

// Calculated values
dowel_radius = dowel_diameter/2;
recess_depth = (blade_height - 1_inch/2)/sqrt(2); // Leave 1/2" of the blade protruding
stock_tube_radius = stock_radius + wall_thickness; // Outer radius of stock guide
dowel_tube_radius = dowel_radius + wall_thickness; // Outer radius of dowel guide
tube_length = 2*dowel_diameter;

//width = max(2*min_distance, blade_width + min_wall_thickness*2); // Ensure the body is wide enough for the blade
//height = recess_depth + radius + min_distance;
//length = 1.5*width;
blade_offset = advance + 1; // Shift the blade to accomodate the advancing stock, and a gap for shavings
blade_angle = atan(advance/(PI*dowel_diameter));


module dowel_guide() {
  difference() {
    union() {
      // Stock entrance guide
      rotate([0, 90, 0]) cylinder(tube_length, stock_tube_radius, stock_tube_radius);
      // Dowel exit guide
      rotate([0, -90, 0]) cylinder(tube_length, dowel_tube_radius, dowel_tube_radius);
      // Center block
      cube([blade_width/2, blade_width, 2*stock_tube_radius], center=true);
      
      // taper center block to allow printing
    
    }
    
    // Hollow out tubes
    rotate([0, 90, 0]) translate([0, 0, -1]) cylinder(tube_length + 2, stock_radius, stock_radius);
    rotate([0, -90, 0]) translate([0, 0, -1]) cylinder(tube_length + 2, dowel_radius, dowel_radius);
    
    position_blade() blade_with_screw();
  }
}

module blade_with_screw() {
  // Blade
  cube([blade_height, blade_width + clearance, blade_thickness]);
  // Screw hole
  translate([blade_height/2, blade_width/2, blade_thickness]) cylinder(0.75*1_inch, screw_hole_radius, screw_hole_radius);
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



dowel_guide();






*difference() {
  // Body
  translate([-min_distance, -min_distance, -length/2]) cube([width, height, length]);

  // Exit hole (final diameter)
  cylinder(length + 1, radius + clearance/2, radius + clearance/2, center=true);

  // Entrance hole
  cylinder(width + 1, stock_radius + clearance/2, stock_radius + clearance/2);

  // Blade slot
  translate([0, radius, blade_offset]) { // Raise blade to the dowel radius, and shift back for the offset
    rotate([-45, blade_angle, 0]) { // Rotate 45 for blade angle and blade_angle so it advances
      translate([-stock_radius, 0, 0]) { // Shift blade to intersect the dowel
        // Blade recess, translate down to give room to adjust blade depth
        translate([0, 0, -1_inch/8]) cube([blade_width + clearance, blade_height, blade_height]);
        // Screw hole
        translate([blade_width/2, 0.1, blade_height/2]) rotate([90, 0, 0]) cylinder(1.5*1_inch, screw_hole_radius, screw_hole_radius);
      }
    }
  }

  // Surface perpendicular to the blade for hammer adjusting
  translate([-min_distance - 1, stock_radius, length/2 + 10]) rotate([-45, blade_angle, 0]) cube([2*width, height + 2, length + 2]);

  // Reduce the volume to make printing faster and use less material
  translate([-min_distance - 1, min_distance, -length/2 - 1]) cube([width + 2, height, length/2 + 1]);
  translate([-min_distance - 1, min_distance, 0]) rotate([-30, 0, 0]) cube([width + 2, height, height]);
  translate([min_distance, -min_distance - 1, -length/2]) rotate([0, 30, 0]) cube([width, height, length]);
}
