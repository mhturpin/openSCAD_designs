$fn = $preview ? 50 : 200;
$vpd = 600;
$vpr = [80, 0, 0];
$vpt = [90, 0, 40];


// Figure out linkage bolt clearance
// Round teeth
// Bevel corners
// Figure out max opening, set length based on desired opening?


length = 200;
d = 10; // The core dimension
th = d*2; // The base thickness
width = d*4;
linkage_length = 25;
linkage_height = 2*th;
ram_length = 6*d;
1_inch = 25.4;
pivot_radius = 3/16*1_inch;
tolerance = 0.2;
tooth_height = d/2;
tooth_width = 2*tooth_height;
num_teeth = (length - th - linkage_length)/tooth_width;
rack_length = 2*tooth_height*num_teeth;
carriage_length = ram_length + 2*linkage_length + d - 10; // -10 to give space for ram to retract
carriage_width = width + 2*d;


module base() {
  // Base
  cube([length, width, th]);

  // Backstop rounded transition
  difference() {
    cube([1.5*th, width, 1.5*th]);
    translate([1.5*th, -1, 1.5*th]) rotate([-90, 0, 0]) cylinder(width + 2, d, d);
  }

  // Backstop rounded top
  translate([0, d, 0]) cube([th, th, 5*d]); // Middle
  cube([th, width, 2*th]); // Wide section
  translate([0, d, 4*d]) rotate([0, 90, 0]) cylinder(th, d, d); // Corner
  translate([0, 3*d, 4*d]) rotate([0, 90, 0]) cylinder(th, d, d); // Corner

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
  rotate([-90, 180, 0]) difference() {
    union() {
      // Rounded back
      cylinder(th, d, d);
      // Ram
      translate([0, -d, 0]) cube([ram_length, th, th]);
    }

    // Hole for the linkage pin
    translate([0, 0, -1]) pivot(th + 2);
  }
}

module handle() {
  rotate([90, 0, 180]) difference() {
    union() {
      // Long bar
      translate([0, d, 0]) cube([length, th, th]);
      // Linkage part
      translate([0, -d, 0]) cube([linkage_length, th, th]);
      // Rounded back
      translate([0, d, 0]) cylinder(th, th, th);
      // Front
      translate([linkage_length, 0, 0]) {
        cube([d, th, th]);
        cylinder(th, d, d);
      }
    }

    // Pivot holes
    translate([0, 0, -1]) {
      pivot(th + 2);
      translate([linkage_length, 0, 0]) pivot(th + 2);
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
      pivot(d + 2);
      translate([linkage_length, 0, 0]) pivot(d + 2);
    }
  }
}


module carriage() {
  difference() {
    // Main body
    cube([carriage_length, carriage_width, 5*d]);
    
    // Subtract base
    translate([-1, d, -1]) cube([length + 2, width, th + 1]);

    // Subtract teeth
    for (i = [0:num_teeth]) {
      translate([i*tooth_width, d, th - 0.01]) rack_tooth();
    }

    // Subtract handle and ram
    translate([-1, 2*d, linkage_height - d]) cube([carriage_length + 2, th, th + 1]);

    // Slot for cam part of handle
    translate([carriage_length - th, 2*d, th - 1]) cube([th + 1, th, linkage_height - th]);

    // Subtract linkages
    translate([ram_length - d - 10, d, linkage_height - d]) {
      // Linkage body
      cube([linkage_length + 2*d, width, th + 1]);

      // Angled transitions
      rotate([0, -30, 0]) cube(width); // Front
      translate([linkage_length + 2*d, 0, 0]) rotate([0, -60, 0]) cube(width); // Back

      // Slot for front pivot
      translate([d, -d - 1, d]) {
        translate([0, 0, -pivot_radius]) cube([linkage_length/2, carriage_width + 2, 2*pivot_radius]);
        rotate([-90, 0, 0]) pivot(carriage_width + 2);
        translate([linkage_length/2, 0, 0]) rotate([-90, 0, 0]) pivot(carriage_width + 2);
      }
    }

 

    // Clearance for middle pivot

    // Back pivot
    translate([carriage_length - d, -1, linkage_height]) rotate([-90, 0, 0]) pivot(carriage_width + 2);
  }
}

module pivot(pivot_len) {
  cylinder(pivot_len, pivot_radius, pivot_radius);
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
    translate([third_pivot, d, 0]) moving_jaw();
  }
}
*base();
*moving_jaw();
*handle();
*linkage();
*rack_tooth();
translate([length - carriage_length, -2*width, 0]) carriage();


max_opening = length - rack_length - linkage_length - d*2;
echo("Min opening: ", max_opening - rack_length);
echo("Max opening: ", max_opening);
