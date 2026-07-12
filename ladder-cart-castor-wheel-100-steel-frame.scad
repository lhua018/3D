// 70kg Parameterized Captive Hoist Carriage
// Ultra-Low Profile: Factory 100mm Bunnings Castors mounted INTERNALLY to 40x40mm Custom Frame

$fn = 60;

// ==========================================
// --- 1. TRACK LADDER DIMENSIONS ---
// ==========================================
ladder_outer_width = 355;
// Width of the track ladder the cart climbs up
ladder_beam_width = 35;
// Width of the track ladder aluminum beams
ladder_beam_depth = 120;
// Depth of the track ladder beams

// ==========================================
// --- 2. WHEEL SIZES (100mm FACTORY CASTOR) ---
// ==========================================
main_wheel_track = ladder_outer_width - ladder_beam_width;
// Fixed wheel centerline to dynamically match track (320mm)
main_wheel_d = 100;              // 100mm Wheel diameter
main_wheel_w = 30;
// Wheel tread width

// Exact Factory Dimensions for Easyroll 100mm 100kg Heavy Duty Fixed Castor
castor_overall_h = 135;
// Total height from wheel bottom to top plate face
castor_plate_l = 100;            // Length of the mounting plate
castor_plate_w = 80;
// Width of the mounting plate
castor_plate_th = 5;             // Thick steel plate housing

small_wheel_d = 55;              
small_wheel_w = 24;
small_axle_d = 8;                

// ==========================================
// --- 3. CUSTOM CARRIAGE FRAME (40x40mm) ---
// ==========================================
carriage_frame_outer_width = 490; 
// 490mm completely boxes in the castors and allows the drop brackets to mount internally
tube_width = 40;              
tube_height = 40;
frame_length = 600;       
crossbar_size = 40;                  

drop_bracket_th = 25;            // Aluminum drop bracket plate thickness
drop_bracket_w = 60;

// ==========================================
// --- 4. POSITION CONTROLS (X & Y AXIS) ---
// ==========================================
wheel_x_pos = 220;               

// Automatically places side wheels to roll against the OUTSIDE edge of the 355mm track ladder with a 2mm clearance
side_wheel_y_pos = (ladder_outer_width / 2) + (small_wheel_d / 2) + 2; 

frame_side_y_pos = (carriage_frame_outer_width / 2) - (tube_width / 2); // Dynamic rail center

// Shift the side wheels along the X-axis so they sit beside the drop bracket instead of merging into it.
side_wheel_x_offset = -60;

// ==========================================
// --- 5. DROP BRACKET & AXLE OPTIONS ---
// ==========================================
bracket_mount_style = 1;
// 1 = Clamps flat to the INSIDE face of the wide frame rail

bottom_axle_style = 1;
// 1 = Continuous Through-Axle, 2 = Stub Axles

bracket_spacer_th = 0;
// Set to 0. Wide frame means spacers are no longer needed.

// ==========================================
// --- CALCULATIONS (LOW PROFILE MODELING) ---
// ==========================================
main_wheel_y = main_wheel_track / 2;

// CRITICAL MATH CHANGE: Forces the castor top plate flush against the TOP face of the 40mm frame
main_wheel_z = (tube_height / 2) - (castor_overall_h - (main_wheel_d / 2));

// All lower clearances adjust dynamically to follow the ultra-low wheel placement
beam_top_z = main_wheel_z - (main_wheel_d / 2);
beam_bottom_z = beam_top_z - ladder_beam_depth;              

side_wheel_z = beam_top_z - (small_wheel_d / 2) - 10; 
bottom_wheel_y = main_wheel_y;
bottom_wheel_z = beam_bottom_z - (small_wheel_d / 2) - 2; 

// Dynamic Drop Bracket Y-Position 
drop_bracket_y_pos = 
    (bracket_mount_style == 1) ?
    frame_side_y_pos - (tube_width / 2) - (drop_bracket_th / 2) - bracket_spacer_th : 
    (bracket_mount_style == 2) ?
    frame_side_y_pos + (tube_width / 2) + (drop_bracket_th / 2) + bracket_spacer_th : 
    frame_side_y_pos;

drop_bracket_z_offset = (bracket_mount_style == 3) ? -(tube_height / 2) : 0;

// Dynamic X positions based on offset
side_wheel_front_x = wheel_x_pos + side_wheel_x_offset;
side_wheel_rear_x = -wheel_x_pos - side_wheel_x_offset;

// Bounding Box Calculations for Labels
total_outer_length = frame_length;
total_outer_width = carriage_frame_outer_width;
max_z_point = (tube_height / 2) + castor_plate_th; // Peak point is now top of the castor plate
min_z_point = bottom_wheel_z - (small_wheel_d / 2);
total_outer_height = max_z_point - min_z_point; 

// ==========================================
// --- MODULES ---
// ==========================================

module factory_fixed_castor() {
    color("grey") rotate([90, 0, 0]) cylinder(h=main_wheel_w, d=main_wheel_d, center=true);
    plate_z_offset = (castor_overall_h - (main_wheel_d/2)) - (castor_plate_th/2);
    color("silver") translate([0, 0, plate_z_offset]) cube([castor_plate_l, castor_plate_w, castor_plate_th], center=true);
    fork_h = plate_z_offset;
    color("lightgray") {
        translate([0, (main_wheel_w/2) + 3, fork_h/2]) cube([50, 5, fork_h], center=true);
        translate([0, -(main_wheel_w/2) - 3, fork_h/2]) cube([50, 5, fork_h], center=true);
    }
}

module custom_carriage_chassis() {
    // 1. Dual 40x40 Longitudinal Side Rails
    translate([0, frame_side_y_pos, 0]) cube([frame_length, tube_width, tube_height], center=true);
    translate([0, -frame_side_y_pos, 0]) cube([frame_length, tube_width, tube_height], center=true);
    
    // 2. Transverse Square Crossbars (Aligned with wheels for mounting support)
    crossbar_inner_length = carriage_frame_outer_width - (tube_width * 2);
    for (x = [-wheel_x_pos, 0, wheel_x_pos]) {
        translate([x, 0, 0])
            cube([crossbar_size, crossbar_inner_length, crossbar_size], center=true);
    }
    
    // 3. Internal Caster Mounting Plates (Representing welded steel plates on the crossbars)
    plate_l = castor_plate_l + 20;
    plate_w = castor_plate_w;
    color("darkslategray") {
        translate([wheel_x_pos, main_wheel_y, (tube_height/2) - 2.5]) cube([plate_l, plate_w, 5], center=true);
        translate([wheel_x_pos, -main_wheel_y, (tube_height/2) - 2.5]) cube([plate_l, plate_w, 5], center=true);
        translate([-wheel_x_pos, main_wheel_y, (tube_height/2) - 2.5]) cube([plate_l, plate_w, 5], center=true);
        translate([-wheel_x_pos, -main_wheel_y, (tube_height/2) - 2.5]) cube([plate_l, plate_w, 5], center=true);
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
    translate([0, y_center, z_pos]) cube([drop_bracket_w, span, tab_thickness], center=true);
}

module bottom_support_block(side_sign) {
    b_y = drop_bracket_y_pos * side_sign;
    w_y = bottom_wheel_y * side_sign;
    bracket_inner_y = b_y - (drop_bracket_th / 2) * side_sign;
    wheel_outer_y = w_y + ((small_wheel_w / 2) + 2) * side_sign;
    block_len = abs(bracket_inner_y - wheel_outer_y);
    
    // Only generate if there is an actual gap to fill
    if (block_len > 0.5) {
        y_center = (bracket_inner_y + wheel_outer_y) / 2;
        translate([0, y_center, bottom_wheel_z]) cube([drop_bracket_w, block_len, drop_bracket_w], center=true);
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

// 1. Custom Carriage Frame
color("silver") custom_carriage_chassis();

// 2. Main Top Wheels (Mounted internally on the crossbar plates)
translate([wheel_x_pos, main_wheel_y, main_wheel_z]) factory_fixed_castor();
translate([wheel_x_pos, -main_wheel_y, main_wheel_z]) factory_fixed_castor();
translate([-wheel_x_pos, main_wheel_y, main_wheel_z]) factory_fixed_castor();
translate([-wheel_x_pos, -main_wheel_y, main_wheel_z]) factory_fixed_castor();

// 3. Side Guide Wheels (Orange) 
color("orange") {
    translate([side_wheel_front_x, side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
    translate([side_wheel_front_x, -side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
    translate([side_wheel_rear_x, side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
    translate([side_wheel_rear_x, -side_wheel_y_pos, side_wheel_z]) small_guide_wheel();
}

// 4. Bottom Captive Wheels (Red)
color("red") {
    translate([wheel_x_pos, bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
    translate([wheel_x_pos, -bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
    translate([-wheel_x_pos, bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
    translate([-wheel_x_pos, -bottom_wheel_y, bottom_wheel_z]) small_captive_wheel();
}

// 5. Drop Brackets & Support Tabs
color("darkgray") {
    translate([wheel_x_pos, drop_bracket_y_pos, 0]) drop_bracket();
    translate([wheel_x_pos, -drop_bracket_y_pos, 0]) drop_bracket();
    translate([-wheel_x_pos, drop_bracket_y_pos, 0]) drop_bracket();
    translate([-wheel_x_pos, -drop_bracket_y_pos, 0]) drop_bracket();

    translate([side_wheel_front_x, 0, 0]) side_wheel_mounting_tab();
    translate([side_wheel_front_x, 0, 0]) scale([1, -1, 1]) side_wheel_mounting_tab();
    translate([side_wheel_rear_x, 0, 0]) side_wheel_mounting_tab();
    translate([side_wheel_rear_x, 0, 0]) scale([1, -1, 1]) side_wheel_mounting_tab();

    if (bottom_axle_style == 2) {
        translate([wheel_x_pos, 0, 0]) bottom_support_block(1);
        translate([wheel_x_pos, 0, 0]) bottom_support_block(-1);
        translate([-wheel_x_pos, 0, 0]) bottom_support_block(1);
        translate([-wheel_x_pos, 0, 0]) bottom_support_block(-1);
    }
}

// 6. Lower Axles
color("dimgray") {
    translate([side_wheel_front_x, side_wheel_y_pos, side_wheel_z]) side_axle();
    translate([side_wheel_front_x, -side_wheel_y_pos, side_wheel_z]) side_axle();
    translate([side_wheel_rear_x, side_wheel_y_pos, side_wheel_z]) side_axle();
    translate([side_wheel_rear_x, -side_wheel_y_pos, side_wheel_z]) side_axle();

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