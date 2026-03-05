$fn = $preview ? 50 : 200;

// Pin spacing block
module spacing_block() {
  difference() {
    cube([30, 13, 3]);

    // Key body cutout
    translate([-1, 2, -1]) {
      cube([32, 8.9, 2]);
      cube([32, 5.1, 3]);
    }

    // Pin locations
    translate([-5.867 - 0.5, 7.1, 1]) {
      for (i = [0:5]) {
        translate([30 - 3.967*i, 0, 0]) cube([1.5, 6, 3]);
      }
    }
  }
}

module depth_guide_base() {
  difference() {
    cube([24, 14.5, 4]);
    translate([2.9, -1, -1]) cube([18.2, 12.5, 4.13]);
  }
}

module depth_guides() {
  for (i = [0:9]) {
    translate([25*i, 0, 0]) {
      back_of_tool_to_cutter = 13.47;
      // increment*i + smallest (9) depth + tolerance
      root_depth = 0.381*i + 5.08 + 0.1;
      stop_offset = root_depth - (back_of_tool_to_cutter - 11.5);

      // Key stop
      translate([0, stop_offset, 4]) difference() {
        cube([24, 14.5 - stop_offset, 2]);
        translate([10, 1.5, 1.6]) linear_extrude(0.5) text(str(i), 5);
      }

      depth_guide_base();
    }
  }
}



translate([0, 0, 3]) rotate([180, 0, 0]) spacing_block();
translate([0, 1, 14.5]) rotate([-90, 0, 0]) depth_guides();
