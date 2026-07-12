// 70kg Parameterized Captive Hoist Carriage
// Adapted to use an ALDI Workzone Aluminum Ladder Section as the Main Chassis Frame

$fn = 60;

// ==========================================
// --- 1. TRACK LADDER DIMENSIONS ---
// ==========================================
ladder_outer_width = 320;        // Width of the track ladder the cart climbs up
ladder_beam_depth = 150;         

// ==========================================
// --- 2. MAIN TRACKING WHEELS (125mm) ---
// ==========================================
main_wheel_track = 285;          // Fixed wheel centerline to match track
main_wheel_d = 125;              // 125mm Through-Axle Wheels
main_wheel_w = 30;               
main_axle_d = 12.7;              // 1/2 inch continuous solid axle rod

small_wheel_d = 55;              
small_wheel_w = 24;              
small_axle_d = 8;                

// ==========================================
// --- 3. ALDI WORKZONE LADDER FRAME SPECIFICATIONS ---
// ==========================================
ladder_frame_outer_width = 380;  // Outer width of wide ALDI ladder section
ladder_rail_w = 25;              // Aluminum side rail wall thickness profile
ladder_rail_h = 60;              // Aluminum side rail height profile
ladder_frame_length = 600;       // Total length of cut section used for the cart
rung_spacing = 280;              // Standard ALDI center-to-center rung spacing
rung_size = 30;                  // Square dimension of corrugated rungs

// Remap old tube variables so all downstream mathematical calculations remain fully intact
tube_width = ladder_rail_w;                 
tube_height = ladder_rail_h;                

drop_bracket_th = 5;            // Steel drop bracket plate thickness
drop_bracket_w = 40;             

// ==========================================
// --- 4. POSITION CONTROLS (X & Y AXIS) ---
// ==========================================
wheel_x_pos = 220;               
frame_cross_x_pos = 140;         

side_wheel_y_pos = 173;          
frame_side_y_pos = (ladder_frame_outer_width / 2) - (ladder_rail_w / 2); // Dynamic rail center

// ==========================================
// --- 5. DROP BRACKET & AXLE OPTIONS ---
// ==========================================
bracket_mount_style = 2;         // 2 = Clamps flat to the OUTSIDE face of the ALDI rail
bottom_axle_style = 1;           // 1 = Continuous Through-Axle (Highly Recommended)

// ==========================================
// --- CALCULATIONS ---
// ==========================================
main_wheel_y = main_wheel_track / 2;
main_wheel_z = 0;              

beam_top_z = -(main_wheel_d / 2);              
beam_bottom_z = beam_top_z - ladder_beam_depth;
side_wheel_z = beam_top_z - (small_wheel_d / 2) - 10; 
bottom_wheel_y = main_wheel_y;
bottom_wheel_z = beam_bottom_z - (small_wheel_d / 2) - 2; 

// Dynamic Drop Bracket Y-Position
drop_bracket_y_pos = 
    (bracket_mount_style == 1) ? frame_side_y_pos - (tube_width / 2) - (drop_bracket_th / 2) : 
    (bracket_mount_style == 2) ? frame_side_y_pos + (tube_width / 2) + (drop_bracket_th / 2) : 
    frame_side_y_pos; 

drop_bracket_z_offset = (bracket_mount_style == 3) ? -(tube_height / 2) : 0;

// Flat-Bar Canopy Guard Position Math
guard_th = 5; 
guard_z = (main_wheel_z + main_wheel_d/2) + 8; // 8mm running clearance above wheel crown

// Bounding Box Calculations for Labels
total_outer_length = ladder_frame_length; 
total_outer_width = (bracket_mount_style == 2) ? (frame_side_y_pos * 2) + tube_width + (drop_bracket_th * 2) : (frame_side_y_pos * 2) + tube_width; 

max_z_point = guard_z + (guard_th / 2);
min_z_point = bottom_wheel_z - (small_wheel_d / 2);
total_outer_height = max_z_point - min_z_point; 

// ==========================================
// --- MODULES ---
// ==========================================

module main_flat_wheel() {
    rotate([90, 0, 0])
        difference() {
            cylinder(h=main_wheel_w, d=main_wheel_d, center=true);
            cylinder(h=main_wheel_w + 2, d=main_axle_d, center=true);
        }
}

// Simple Flat Bar Roof: Bolts to top face of aluminum rail, projects inward over internal wheel
module simple_flat_bar_guard(side_sign) {
    guard_length = main_wheel_d + 20; 
    
    frame_outer_y = (frame_side_y_pos + (tube_width / 2)) * side_sign;
    wheel_inner_y = (main_wheel_y - (main_wheel_w / 2) - 10) * side_sign; 
    
    guard_width = abs(frame_outer_y - wheel_inner_y);
    y_center = (frame_outer_y + wheel_inner_y) / 2;
    
    translate([0, y_center, guard_z])
        cube([guard_length, guard_width, guard_th], center=true);
}

// NEW MODULE: Models the actual ALDI Workzone ladder section frame geometries
module aldi_ladder_chassis() {
    // 1. Dual Aluminum Longitudinal Side Rails
    translate([0, frame_side_y_pos, 0]) cube([ladder_frame_length, ladder_rail_w, ladder_rail_h], center=true);
    translate([0, -frame_side_y_pos, 0]) cube([ladder_frame_length, ladder_rail_w, ladder_rail_h], center=true);
    
    // 2. Transverse Square Rungs (Centered loop layout)
    rung_inner_length = ladder_frame_outer_width - (ladder_rail_w * 2);
    for (x = [-rung_spacing, 0, rung_spacing]) {
        translate([x, 0, 0])
            cube([rung_size, rung_inner_length, rung_size], center=true);
    }
}

module small_guide_wheel() {
    difference() {
        cylinder(h=small_wheel_w, d=small_wheel_d, center=true);
        cylinder(h=small_wheel_w + 2, d=small_axle_d, center=true);
    }
}

module small_captive_wheel() {
    rotate([90, 0, 0])
        difference() {
            cylinder(h=small_wheel_w, d=small_wheel_d, center=true);
            cylinder(h=small_wheel_w + 2, d=small_axle_d, center=true);
        }
}

module drop_bracket() {
    drop_length = abs(bottom_wheel_z) + (tube_height/2) + 20;
    translate([0, 0, -(drop_length/2) + (tube_height/2) + drop_bracket_z_offset])
        cube([drop_bracket_w, drop_bracket_th, drop_length], center=true);
}

module side_wheel_mounting_tab() {
    tab_thickness = 8; 
    bracket_face_offset = drop_bracket_th / 2;
    span = abs(drop_bracket_y_pos - side_wheel_y_pos) + bracket_face_offset;
    y_center = (drop_bracket_y_pos + side_wheel_y_pos) / 2;
    z_pos = side_wheel_z + (small_wheel_w / 2) + (tab_thickness / 2);
    
    translate([0, y_center, z_pos])
        cube([drop_bracket_w, span, tab_thickness], center=true);
}

module bottom_support_block(side_sign) {
    b_y = drop_bracket_y_pos * side_sign;
    w_y = bottom_wheel_y * side_sign;
    bracket_inner_y = b_y - (drop_bracket_th / 2) * side_sign;
    wheel_outer_y = w_y + ((small_wheel_w / 2) + 2) * side_sign; 
    block_len = abs(bracket_inner_y - wheel_outer_y);
    y_center = (bracket_inner_y + wheel_outer_y) / 2;
    
    translate([0, y_center, bottom_wheel_z])
        cube([drop_bracket_w, block_len, drop_bracket_w], center=true);
}

// Axles
module main_axle() {
    axle_len = (frame_side_y_pos * 2) + tube_width + 10;
    rotate([90, 0, 0]) {
        cylinder(h=axle_len, d=main_axle_d, center=true);
        translate([0, 0, axle_len/2]) cylinder(h=8, d=main_axle_d * 1.5, $fn=6, center=true);
        translate([0, 0, -axle_len/2]) cylinder(h=8, d=main_axle_d * 1.5, $fn=6, center=true);
    }
}

module side_axle() {
    axle_len = small_wheel_w + 30;
    cylinder(h=axle_len, d=small_axle_d, center=true);
    translate([0, 0, axle_len/2]) cylinder(h=5, d=small_axle_d * 2, $fn=6, center=true);
    translate([0, 0, -axle_len/2]) cylinder(h=5, d=small_axle_d * 2, $fn=6, center=true);
}

module bottom_axle(is_continuous=false) {
    if (is_continuous) {
        axle_len = (max(drop_bracket_y_pos, bottom_wheel_y) * 2) + drop_bracket_th + 20;
        rotate([90, 0, 0]) {
            cylinder(h=axle_len, d=small_axle_d, center=true);
            translate([0, 0, axle_len/2]) cylinder(h=5, d=small_axle_d * 2, $fn=6, center=true);
            translate([0, 0, -axle_len/2]) cylinder(h=5, d=small_axle_d * 2, $fn=6, center=true);
        }
    } else {
        axle_len = drop_bracket_th + small_wheel_w + 20;
        rotate([90, 0, 0]) {
            cylinder(h=axle_len, d=small_axle_d, center=true);
            translate([0, 0, axle_len/2]) cylinder(h=5, d=small_axle_d * 2, $fn=6, center=true);
            translate([0, 0, -axle_len/2]) cylinder(h=5, d=small_axle_d * 2, $fn=6, center=true);
        }
    }
}

module visual_dimension_line(label_text, distance, text_size=20) {
    color("black") {
        cube([distance, 1.5, 1.5], center=true);
        translate([distance/2, 0, 0]) cube([1.5, 12, 8], center=true);
        translate([-distance/2, 0, 0]) cube([1.5, 12, 8], center=true);
        translate([0, 12, -text_size/2])
            rotate([90, 0, 0]) 
                linear_extrude(height = 1.5)
                    text(label_text, size = text_size, font = "Liberation Sans:style=Bold", halign = "center");
    }
}

// ==========================================
// --- FINAL ASSEMBLY ---
// ==========================================

// 1. ALDI Ladder Chassis (Silver Aluminum)
color("silver") aldi_ladder_chassis();

// 2. Main Top Wheels (125mm Dark Slate - Seated inside the ladder bay)
color("darkslategray") {
    translate([wheel_x_pos, main_wheel_y, main_wheel_z]) main_flat_wheel();
    translate([wheel_x_pos, -main_wheel_y, main_wheel_z]) main_flat_wheel();
    translate([-wheel_x_pos, main_wheel_y, main_wheel_z]) main_flat_wheel();
    translate([-wheel_x_pos, -main_wheel_y, main_wheel_z]) main_flat_wheel();
}

// 3. Simple Flat-Bar Canopy Protection Plates (Bolted over top of rails)
color("gray") {
    translate([wheel_x_pos, 0, 0]) simple_flat_bar_guard(1);
    translate([wheel_x_pos, 0, 0]) simple_flat_bar_guard(-1);
    translate([-wheel_x_pos, 0, 0]) simple_flat_bar_guard(1);
    translate([-wheel_x_pos, 0, 0]) simple_flat_bar_guard(-1);
}

// 4. Side Guide Wheels (Orange)
color("orange") {
    translate([wheel_x_pos, side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
    translate([wheel_x_pos, -side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
    translate([-wheel_x_pos, side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
    translate([-wheel_x_pos, -side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
}

// 5. Bottom Captive Wheels (Red)
color("red") {
    translate([wheel_x_pos, bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
    translate([wheel_x_pos, -bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
    translate([-wheel_x_pos, bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
    translate([-wheel_x_pos, -bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
}

// 6. Drop Brackets & Support Tabs (Steel Parts - Bolted to outside faces of ladder)
color("darkgray") {
    translate([wheel_x_pos, drop_bracket_y_pos, 0]) drop_bracket();
    translate([wheel_x_pos, -drop_bracket_y_pos, 0]) drop_bracket();
    translate([-wheel_x_pos, drop_bracket_y_pos, 0]) drop_bracket();
    translate([-wheel_x_pos, -drop_bracket_y_pos, 0]) drop_bracket();
    
    // Side Wheel Upper Shelves
    translate([wheel_x_pos, 0, 0]) side_wheel_mounting_tab();
    translate([wheel_x_pos, 0, 0]) scale([1, -1, 1]) side_wheel_mounting_tab();
    translate([-wheel_x_pos, 0, 0]) side_wheel_mounting_tab();
    translate([-wheel_x_pos, 0, 0]) scale([1, -1, 1]) side_wheel_mounting_tab();
    
    if (bottom_axle_style == 2) {
        translate([wheel_x_pos, 0, 0]) bottom_support_block(1);
        translate([wheel_x_pos, 0, 0]) bottom_support_block(-1);
        translate([-wheel_x_pos, 0, 0]) bottom_support_block(1);
        translate([-wheel_x_pos, 0, 0]) bottom_support_block(-1);
    }
}

// 7. Axles with Bolt Heads (Dark Gray Continuous rods piercing the ladder)
color("dimgray") {
    translate([wheel_x_pos, 0, main_wheel_z]) main_axle();
    translate([-wheel_x_pos, 0, main_wheel_z]) main_axle();
    
    translate([wheel_x_pos, side_wheel_y_pos, side_wheel_z]) side_axle();
    translate([wheel_x_pos, -side_wheel_y_pos, side_wheel_z]) side_axle();
    translate([-wheel_x_pos, side_wheel_y_pos, side_wheel_z]) side_axle();
    translate([-wheel_x_pos, -side_wheel_y_pos, side_wheel_z]) side_axle();
    
    if (bottom_axle_style == 1) {
        translate([wheel_x_pos, 0, bottom_wheel_z]) bottom_axle(is_continuous=true);
        translate([-wheel_x_pos, 0, bottom_wheel_z]) bottom_axle(is_continuous=true);
    } else {
        translate([wheel_x_pos, bottom_wheel_y + (10 * 1), bottom_wheel_z]) bottom_axle(is_continuous=false);
        translate([wheel_x_pos, -bottom_wheel_y + (10 * -1), bottom_wheel_z]) bottom_axle(is_continuous=false);
        translate([-wheel_x_pos, bottom_wheel_y + (10 * 1), bottom_wheel_z]) bottom_axle(is_continuous=false);
        translate([-wheel_x_pos, -bottom_wheel_y + (10 * -1), bottom_wheel_z]) bottom_axle(is_continuous=false);
    }
}

// ==========================================
// --- RENDERED DIMENSION LABELS ---
// ==========================================
translate([0, -total_outer_width/2 - 60, max_z_point])
    visual_dimension_line(str("LENGTH: ", total_outer_length, "mm"), total_outer_length);

translate([total_outer_length/2 + 60, 0, max_z_point])
    rotate([0, 0, 90])
        visual_dimension_line(str("WIDTH: ", total_outer_width, "mm"), total_outer_width);

translate([-total_outer_length/2 - 60, -total_outer_width/2 - 10, (max_z_point + min_z_point)/2])
    rotate([0, -90, 0])
        visual_dimension_line(str("HEIGHT: ", total_outer_height, "mm"), total_outer_height);