$fn = $preview ? 50 : 200;

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
screw_hole_radius = 1_inch/8;
advance = 3; // How much the blade advances per turn
wall_thickness = 1_inch/4;

// Calculated values
dowel_radius = dowel_diameter/2;
recess_depth = (blade_height - 1_inch/2)/sqrt(2); // Leave 1/2" of the blade protruding
stock_tube_radius = stock_radius + wall_thickness; // Outer radius of stock guide
dowel_tube_radius = dowel_radius + wall_thickness; // Outer radius of dowel guide
tube_length = 3*dowel_diameter;

//width = max(2*min_distance, blade_width + min_wall_thickness*2); // Ensure the body is wide enough for the blade
//height = recess_depth + radius + min_distance;
//length = 1.5*width;
//blade_offset = blade_thickness*sqrt(2) + 1; // Shift the blade to accomodate its thickness, and a gap for shavings
//blade_angle = atan(advance/(PI*diameter));

module tube(length, outer_radius, inner_radius) {
  difference() {
    cylinder(length, outer_radius, outer_radius);
    translate([0, 0, -1]) cylinder(length + 2, inner_radius, inner_radius);
  }
}

module guide_tube() {
  difference() {
    union() {
      tube(tube_length, stock_tube_radius, stock_radius);
      translate([0, 0, -tube_length]) tube(tube_length, dowel_tube_radius, dowel_radius);
    }
    
    blade_slot_negative();
  }
}

module blade_slot_negative() {
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
}



guide_tube();






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
