$fn = $preview ? 50 : 200;
$vpd = 600;
$vpr = [80, 0, 0];
$vpt = [90, 0, 40];

// Round teeth
// Calculate handle angle based on length and backstop height
// Fix handle intereference with moving jaw
// Fix teeth intereference with moving jaw
// Create sliding stop
// Bevel corners
// Figure out max opening, set length based on desired opening?


length = 200;
d = 10; // The core dimension
th = d*2; // The base thickness
width = d*4;
linkage_length = 40;
1_inch = 25.4;
pivot_radius = 3/16*1_inch;
tolerance = 0.2;
tooth_height = d/2;
tooth_width = 2*tooth_height;
num_teeth = (length - th - linkage_length)/tooth_width;
rack_length = 2*tooth_height*num_teeth;
linkage_height = th + tooth_height + d;


module base() {
  // Base
  cube([length, width, th]);

  // Backstop rounded transition
  difference() {
    cube(width);
    translate([width, -1, width]) rotate([-90, 0, 0]) cylinder(width + 2, th, th);
  }
  // Backstop rounded top
  translate([0, th, th*2]) rotate([0, 90, 0]) cylinder(th, width/2, width/2);

  // Teeth
  translate([0, 0, th]) for (i = [1:num_teeth]) {
    translate([length - i*tooth_width, 0, 0]) rack_tooth();
  }
}

module rack_tooth() {
  points = [
    [tooth_height/3, 0], 
    [0, tooth_height*4/5], 
    [0, tooth_height], 
    [tooth_height/3, tooth_height], 
    [tooth_width, 0]
  ];

  translate([0, width, 0]) rotate([90, 0, 0]) linear_extrude(width) polygon(points);
}

module moving_jaw() {
  rotate([0, 90, 0]) difference() {
    hull() {
      // Tapered part
      cylinder(th, th*0.75, d);
      // Rounded back
      translate([0, d, th]) rotate([90, 0, 0]) cylinder(th, d, d);
    }

    // Flats for attaching the linkage
    translate([-th, 0, d]) {
      translate([0, d, 0]) cube(d*4);
      translate([0, -2.5*th, 0]) cube(th*2);
    }

    // Hole for the linkage pin
    translate([0, d + 1, th]) rotate([90, 0, 0]) cylinder(th + 2, pivot_radius, pivot_radius);
  }
}

module handle() {
  rotate([90, 0, 180]) difference() {
    union() {
      // Long bar
      rotate([0, 0, 15]) translate([0, -d, 0]) cube([length, th, th]);
      // Linkage part
      translate([0, -d, 0]) cube([linkage_length, th, th]);
      // Rounded ends
      cylinder(th, d, d);
      translate([linkage_length, 0, 0]) cylinder(th, d, d);
    }

    // Pivot holes
    translate([0, 0, -1]) {
      cylinder(th + 2, pivot_radius, pivot_radius);
      translate([linkage_length, 0, 0]) cylinder(th + 2, pivot_radius, pivot_radius);
    }
  }
}

module linkage() {
  rotate([90, 0, 0]) difference() {
    union() {
      // Bar
      translate([0, -d, 0]) cube([linkage_length, th, d]);
      // Rounded ends
      cylinder(d, d, d);
      translate([linkage_length, 0, 0]) cylinder(d, d, d);
    }

    // Pivot holes
    translate([0, 0, -1]) {
      cylinder(d + 2, pivot_radius, pivot_radius);
      translate([linkage_length, 0, 0]) cylinder(d + 2, pivot_radius, pivot_radius);
    }
  }
}


union() {
  base();

  translate([0, 0, linkage_height]) {
    first_pivot = length - d;
    third_pivot = first_pivot - 2*linkage_length;

    translate([first_pivot, d, 0]) handle();
    translate([third_pivot, d, 0]) {
      linkage();
      translate([0, d*3, 0]) linkage();
    }
    translate([third_pivot - th, th, 0]) moving_jaw();
  }
}
*base();
*moving_jaw();
*handle();
*linkage();
*rack_tooth();


max_opening = length - rack_length - linkage_length - d*2;
echo("Min opening: ", max_opening - rack_length);
echo("Max opening: ", max_opening);
