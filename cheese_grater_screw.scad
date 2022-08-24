$fn=100;

thread_tip_width = 1;
thread_base_width = 1.5;
thread_height = 1.5;
core_radius = 4.5;
thread_starts = 2;
thread_turns = 2;
length = 15;
bore_radius = 2;

outer_radius = core_radius + thread_height;
// The angle that the inside of the thread intercepts the cross section
thread_core_angle = lead_angle(core_radius, length/thread_turns);
// The angle that the tip of the thread intercepts the cross section
thread_outer_angle = lead_angle(outer_radius, length/thread_turns);
// The length of the curve the inside of the thread makes in the cross section
thread_base_length = thread_base_width/sin(thread_core_angle); 
// The length of the curve the tip of the thread makes in the cross section
thread_tip_length = thread_tip_width/sin(thread_outer_angle);
thread_base_arc_angle = to_deg(thread_base_length/core_radius);
thread_tip_arc_angle = to_deg(thread_tip_length/outer_radius);
tip_angle_offset = (thread_base_arc_angle - thread_tip_arc_angle)/2;

// Get the [x, y] coordinates for a point on a circle at a given angle
function point_on_circle(radius, angle) = [radius*cos(angle), radius*sin(angle)];

// Get the lead angle
function lead_angle(radius, length) = atan(length/(2*radius*PI));

// Radians to degrees
function to_deg(t) = t*180/PI;

module screw() {
  linear_extrude(height = length, twist = -720, convexity = 10) {
    difference() {
      circle(core_radius);
      circle(bore_radius);
    }

    for (i = [0:360/thread_starts:360]) {
      rotate(i) thread_cross_section();
    }
  }
}

module circular_segment(radius, angle) {
  move_distance = radius*(1 - cos(angle/2));
  move_to = point_on_circle(move_distance, 180 + angle/2);

  difference() {
    circle(radius);
    translate([move_to[0], move_to[1], 0]) rotate(angle/2) square(radius*2, center = true);
  }
}

module thread_cross_section() {
  base_1 = [core_radius, 0];
  base_2 = point_on_circle(core_radius, thread_base_arc_angle);
  tip_1 = point_on_circle(outer_radius, tip_angle_offset);
  tip_2 = point_on_circle(outer_radius, thread_tip_arc_angle + tip_angle_offset);

  polygon([base_1, base_2, tip_2, tip_1]);
  rotate(tip_angle_offset) circular_segment(outer_radius, thread_tip_arc_angle);
}

// Only does up to 180 degrees
module ring_arc(r_inner, r_outer, height, angle) {
  difference() {
    cylinder(height, r_outer, r_outer);
    translate([0, 0, -1]) cylinder(height+2, r_inner, r_inner);
    rotate(angle) translate([-r_outer - 1, 0, -1]) cube([2*r_outer + 2, r_outer + 1, height + 2]);
    rotate(180) translate([-r_outer - 1, 0, -1]) cube([2*r_outer + 2, r_outer + 1, height + 2]);
  }
}

difference() {
  screw();
  translate([0, 0, 13.0001]) cylinder(2, 1.5, 2.5);
  translate([0, 0, length-1.9]) ring_arc(core_radius, outer_radius + 1, 2, thread_base_arc_angle);
  rotate(180) translate([0, 0, length-1.9]) ring_arc(core_radius, outer_radius + 1, 2, thread_base_arc_angle);
  rotate(45, [1, 0, 0]) cube([outer_radius*2, core_radius*sqrt(2), core_radius*sqrt(2)], center=true);
}
