$fn = $preview ? 50 : 200;

// Constants, base measurement is mm
1_inch = 25.4;
clearance = 0.2;

// Settings
dowel_diameter = 5/8 * 1_inch;
stock_radius   = (dowel_diameter + 1_inch/4) / sqrt(2); // Inscribed radius for square stock
blade_width     = 55;
blade_height    = 50;
blade_thickness = 2;
screw_hole_radius = 1_inch / 8;
advance        = 3; // mm of axial advance per full rotation
wall_thickness = 1_inch / 4;

// Calculated values
dowel_radius = dowel_diameter / 2;
blade_angle  = atan(advance / (PI * dowel_diameter)); // Helix angle

// --- Coordinate system ---
// X = tube axis  (stock enters from +X, exits toward -X)
// Z = vertical   (up = +Z; blade holder sits on top)
// Y = horizontal, perpendicular to tube
//
// The dowel cylinder has its axis along X, centered on the X axis.
// The blade edge is tangent to the top of the dowel cylinder at (x_cut, 0, dowel_radius).

// Derived dimensions
tube_length    = 3 * dowel_diameter;
entrance_or    = stock_radius + wall_thickness;      // entrance tube outer radius
exit_or        = dowel_radius + wall_thickness;      // exit tube outer radius
blade_y_start  = dowel_radius - blade_width/2;       // canonical Y of blade -Y edge (centered over dowel)
blade_y_center = 0;                                  // blade world-Y midpoint (centered on dowel axis)
holder_width   = blade_width + 4 * (1_inch/4);       // blade width plus 4x alignment pin diameter (1/4")
section_length = blade_height * sin(45) + 2 * wall_thickness;
pin_r          = 1_inch/8 + clearance;           // hole radius for 1/4" alignment pin (slip fit)
pin_depth      = 10;
// The blade spans world x in [1, 1 + blade_height*sin(45)].  Centering the section
// on that span (with wall_thickness on each X side) keeps the blade pocket fully
// inside the section.  The leading "1" matches the offset in blade_transform.
section_x_center = 1 + blade_height * sin(45) / 2;
// Holder must reach from entrance_or up to the blade top (dowel_radius +
// blade_height*cos(45)), with wall_thickness above that.
holder_height    = dowel_radius + blade_height * cos(45) + wall_thickness - entrance_or;

// --- blade_transform ---
//
// Transforms children from blade-canonical space into world space.
// Used as a negative (inside difference()) to cut the blade slot in the base
// piece and the blade pocket in the blade holder.
//
// Blade-canonical coordinate system:
//   Origin        : corner of the cutting edge — the end that sits dowel_radius
//                   to the -Y side of the tangent point
//   Y axis        : along the cutting edge, toward the far end of the blade
//   Z axis        : up the blade face (perpendicular to the edge, away from it)
//   -X axis       : flat back / top surface normal (faces upward in world)
//
//   Blade body    : x in [-blade_thickness, 0], y in [0, blade_width], z in [0, blade_height]
//   Flat back     : x = -blade_thickness  (world normal: upward + toward exit)
//   Bevel side    : x = 0                 (world normal: downward + toward entrance)
//   Cutting edge  : x = -blade_thickness, z = 0  -- on the flat back (bevel-down)
//   Tangent point : canonical (-blade_thickness, dowel_radius, 0)  ->  world (1, 0, dowel_radius)
//   Corner        : canonical (-blade_thickness, 0, 0)             ->  world (1, -dowel_radius, dowel_radius)
//
// The blade is bevel-down: the flat back (top surface) faces upward into the blade
// holder, with the cutting edge at its lower end tangent to the dowel cylinder.
// The bevel faces down toward the incoming stock.
//
// Transform steps (innermost -> outermost):
//   1. translate([blade_thickness, -dowel_radius, 0])
//         Shifts so the cutting-edge tangent point, at canonical
//         (-blade_thickness, dowel_radius, 0), lands at the intermediate origin.
//   2. rotate([0, 45, 0])
//         Tilts the blade so "up the blade face" (+Z canonical) becomes the
//         direction (1/sqrt(2), 0, 1/sqrt(2)) in world -- 45 deg from the tube
//         axis, pointing toward the stock entrance (+X) and upward (+Z).
//   3. rotate([0, 0, blade_angle])
//         Skews the blade around the radius vector (Z axis through the tangent
//         point) by the helix angle. This gives the cutting edge a slight axial
//         component so the blade drives the stock to rotate and advance.
//   4. translate([1, 0, dowel_radius])
//         Raises the tangent point to the top of the dowel cylinder, then offsets
//         1 mm toward the entrance (+X) so shavings have room to escape between
//         the blade edge and the exit bore.
//
// To position the blade at a specific x along the tube axis, wrap with:
//   translate([x_cut, 0, 0]) blade_transform() { ... }
module blade_transform() {
    translate([1, 0, dowel_radius])
        rotate([0, 0, blade_angle])
            rotate([0, 45, 0])
                translate([blade_thickness, -dowel_radius, 0])
                    children();
}

// Base slot shape: blade swept in canonical -X — removes everything the blade
// intersects as it slides toward the flat-back side.  Open on the -X (flat-back) face.
module blade_shape_base(extra = clearance) {
    translate([-(blade_thickness + extra + 200), blade_y_start - extra, -extra])
        cube([blade_thickness + extra + 200,
              blade_width     + 2*extra,
              blade_height    + 2*extra]);
}

// Holder pocket shape: blade swept in canonical +X — removes everything the blade
// intersects as it slides toward the bevel side.  Open on the +X (bevel) face.
module blade_shape_holder(extra = clearance) {
    translate([-blade_thickness, blade_y_start - extra, -extra])
        cube([blade_thickness + extra + 200,
              blade_width     + 2*extra,
              blade_height    + 2*extra]);
}

// --- Base piece ---
//
// Two-tube body (entrance + exit) bridged by a rectangular middle section.
// Coordinate layout:
//   +X end : entrance (stock enters here, larger bore)
//   -X end : exit     (finished dowel exits here, smaller bore)
//   x = 0  : bore transition; blade is at x = 1 mm (blade_transform offset)
//
// The section is offset in X so the blade span sits centred within it, giving
// wall_thickness on each X side.  The blade holder rests on the section top
// face (+Z) and is aligned by 4 slip-fit 1/4" dowel pins (2 on each Y side).
module base_piece() {
    sx_start = section_x_center - section_length/2;
    sx_end   = section_x_center + section_length/2;

    difference() {
        // ----- Solid body -----
        union() {
            // Rectangular middle section (height = entrance tube OD)
            translate([sx_start, -holder_width/2, -entrance_or])
                cube([section_length, holder_width, 2 * entrance_or]);

            // Entrance tube (+X side)
            translate([sx_end, 0, 0])
                rotate([0, 90, 0])
                    cylinder(r = entrance_or, h = tube_length);

            // Exit tube (-X side)
            translate([sx_start - tube_length, 0, 0])
                rotate([0, 90, 0])
                    cylinder(r = exit_or, h = tube_length);
        }

        // ----- Bores -----
        // Entrance bore: stock radius, from x = 0 to the entrance end
        rotate([0, 90, 0])
            cylinder(r = stock_radius, h = sx_end + tube_length + 1);

        // Exit bore: dowel radius, from the exit end to x = 0
        // h = -sx_start (positive, since sx_start < 0) + tube_length + 2
        translate([sx_start - tube_length - 1, 0, 0])
            rotate([0, 90, 0])
                cylinder(r = dowel_radius, h = -sx_start + tube_length + 2);

        // ----- Blade slot -----
        blade_transform()
            blade_shape_base();

        // ----- Alignment pin holes -----
        // 4 vertical holes in the top face (going in -Z), 2 on each Y side.
        // X positions are at the ±X ends of the section, clear of the blade slot
        // (blade slot at z = entrance_or is only at x ∈ [15, 18] mm; pins are at
        // x ≈ section_x_center ± 18 mm, i.e., x ≈ 1 mm and x ≈ 36 mm).
        for (sx = [-1, 1], sy = [-1, 1])
            translate([
                section_x_center + sx * (section_length/2 - wall_thickness),
                blade_y_center + sy * (holder_width/2 - wall_thickness),
                entrance_or - pin_depth
            ])
                cylinder(r = pin_r, h = pin_depth + 1);
    }
}

// --- Blade holder ---
//
// Rectangular block that sits on the section top face (+Z).  Contains the
// blade pocket, the screw hole, and matching alignment pin holes.
// The flat top face is for clamping the assembly to a table.
module blade_holder() {
    sx_start = section_x_center - section_length/2;

    difference() {
        // ----- Solid block -----
        translate([sx_start, -holder_width/2, entrance_or])
            cube([section_length, holder_width, holder_height]);

        // ----- Blade pocket -----
        blade_transform()
            blade_shape_holder();

        // ----- Screw hole -----
        // Cylinder through the blade centre, oriented along the canonical X axis
        // (perpendicular to the blade face).  In world space this runs in the
        // direction (1/sqrt(2), 0, -1/sqrt(2)) — toward the entrance and downward.
        // The screw passes through the holder and through a hole in the blade.
        blade_transform()
            translate([-blade_thickness/2, blade_width/2, blade_height/2])
                rotate([0, 90, 0])
                    cylinder(r = screw_hole_radius + clearance,
                             h = section_length + holder_height,
                             center = true);

        // ----- Alignment pin holes -----
        // Matching holes in the bottom face, same XY positions as the base piece.
        // Open at z = entrance_or, extend upward pin_depth into the holder body.
        for (sx = [-1, 1], sy = [-1, 1])
            translate([
                section_x_center + sx * (section_length/2 - wall_thickness),
                blade_y_center + sy * (holder_width/2 - wall_thickness),
                entrance_or - 1
            ])
                cylinder(r = pin_r, h = pin_depth + 1);
    }
}

// --- Blade visualization ---
// Shows the blade as a transparent ghost in the assembly preview.
module blade_viz() {
    % blade_transform()
        translate([-blade_thickness, blade_y_start, 0])
            cube([blade_thickness, blade_width, blade_height]);
}

// --- Assembly preview ---
base_piece();
*blade_holder();
blade_viz();
