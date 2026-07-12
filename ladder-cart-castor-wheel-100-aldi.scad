// 70kg Parameterized Captive Hoist Carriage
// Ultra-Low Profile: Factory 100mm Bunnings Castors mounted to the TOP face of ALDI Ladder Frame

$fn = 60;

// ==========================================
// --- 1. TRACK LADDER DIMENSIONS ---
// ==========================================
ladder_top_outer_width = 320;    // Width of the track ladder the cart climbs up
ladder_bottom_outer_width = 355; // Width of the bottom rail track
ladder_beam_width = 35;          // Width of the track ladder aluminum beams
ladder_beam_depth = 120;         // Depth of the track ladder beams

// ==========================================
// --- 2. WHEEL SIZES (100mm FACTORY CASTOR) ---
// ==========================================
main_wheel_track = ladder_top_outer_width - ladder_beam_width; // Fixed wheel centerline
main_wheel_d = 100;              // 100mm Wheel diameter
main_wheel_w = 30;               // Wheel tread width

// --- SIDE WHEEL TOGGLES ---
enable_internal_side_wheels = true;  
enable_external_side_wheels = false; 

// Exact Factory Dimensions for Easyroll 100mm 100kg Heavy Duty Fixed Castor
castor_overall_h = 135;          
castor_plate_l = 100;            
castor_plate_w = 80;             
castor_plate_th = 5;             

small_wheel_d = 55;              
small_wheel_w = 24;              
small_axle_d = 8;                

// ==========================================
// --- 3. ALDI LADDER FRAME SPECIFICATIONS ---
// ==========================================
ladder_frame_outer_width = 410;  
ladder_rail_w = 25;              
ladder_rail_h = 60;              
ladder_frame_length = 600;       
rung_spacing = 280;              
rung_size = 30;                  

// Remap variables for historical logic compatibility
tube_width = ladder_rail_w;      
tube_height = ladder_rail_h;     
drop_bracket_th = 40;            
drop_bracket_w = 40;             

// ==========================================
// --- 4. POSITION CONTROLS (X & Y AXIS) ---
// ==========================================
wheel_x_pos = 220;               
frame_cross_x_pos = 140;         
frame_side_y_pos = (ladder_frame_outer_width / 2) - (ladder_rail_w / 2); 

// EXTERNAL side wheel offset
side_wheel_x_offset = -60;       

// INTERNAL side wheel structural positioning
// 0 aligns perfectly with main wheels to share castor bolts. e.g., -80 aligns with rungs.
int_side_x_offset = 10;           
// 0 mounts flush on top of aluminum rail. -30 drops it down to bolt through rungs.
int_side_mount_z_offset = 10;     

// ==========================================
// --- 5. DROP BRACKET & AXLE OPTIONS ---
// ==========================================
bracket_mount_style = 2;         
bottom_axle_style = 2;           
bracket_spacer_th = 0;           

// ==========================================
// --- CALCULATIONS (LOW PROFILE MODELING) ---
// ==========================================
main_wheel_y = main_wheel_track / 2; 
main_wheel_z = (ladder_rail_h / 2) - (castor_overall_h - (main_wheel_d / 2)); 

beam_top_z = main_wheel_z - (main_wheel_d / 2); 
beam_bottom_z = beam_top_z - ladder_beam_depth;              

// --- INTERNAL SIDE WHEEL MATH ---
int_side_wheel_y_pos = (ladder_bottom_outer_width / 2) - ladder_beam_width - (small_wheel_d / 2) - 2;
// Adjusts the X position dynamically based on user offset
int_sw_front_x = wheel_x_pos + int_side_x_offset;
int_sw_rear_x = -wheel_x_pos - int_side_x_offset;
// Calculates where the bracket bolts to the frame
int_sw_mount_z = (ladder_rail_h / 2) + int_side_mount_z_offset; 
// Calculates where the wheel axle sits relative to the shifted bracket
int_side_wheel_z = beam_top_z - (small_wheel_d / 2) + int_side_mount_z_offset; 

// --- EXTERNAL SIDE WHEEL MATH ---
ext_side_wheel_y_pos = (ladder_bottom_outer_width / 2) + (small_wheel_d / 2) + 2;                     
ext_side_wheel_z = beam_top_z - (small_wheel_d / 2) - 10; 
ext_sw_front_x = wheel_x_pos + side_wheel_x_offset; 
ext_sw_rear_x = -wheel_x_pos - side_wheel_x_offset; 

// --- BOTTOM WHEEL MATH ---
bottom_wheel_track = ladder_bottom_outer_width - ladder_beam_width;
bottom_wheel_y = bottom_wheel_track / 2; 
bottom_wheel_z = beam_bottom_z - (small_wheel_d / 2) - 2; 

// Dynamic Drop Bracket Y-Position
drop_bracket_y_pos = 
    (bracket_mount_style == 1) ? 
        frame_side_y_pos - (tube_width / 2) - (drop_bracket_th / 2) - bracket_spacer_th :  
    (bracket_mount_style == 2) ? 
        frame_side_y_pos + (tube_width / 2) + (drop_bracket_th / 2) + bracket_spacer_th :  
    frame_side_y_pos; 
drop_bracket_z_offset = (bracket_mount_style == 3) ? -(tube_height / 2) : 0; 

// Bounding Box Calculations for Labels
total_outer_length = ladder_frame_length; 
total_outer_width = (bracket_mount_style == 2) ? 
    (frame_side_y_pos * 2) + tube_width + (drop_bracket_th * 2) + (bracket_spacer_th * 2) : (frame_side_y_pos * 2) + tube_width; 
max_z_point = (ladder_rail_h / 2) + castor_plate_th; 
min_z_point = bottom_wheel_z - (small_wheel_d / 2); 
total_outer_height = max_z_point - min_z_point; 

// ==========================================
// --- MODULES ---
// ==========================================

module factory_fixed_castor() { 
    color("grey") 
        rotate([90, 0, 0]) cylinder(h=main_wheel_w, d=main_wheel_d, center=true); 
    plate_z_offset = (castor_overall_h - (main_wheel_d/2)) - (castor_plate_th/2); 
    color("silver") 
        translate([0, 0, plate_z_offset]) cube([castor_plate_l, castor_plate_w, castor_plate_th], center=true); 
    fork_h = plate_z_offset; 
    color("lightgray") { 
        translate([0, (main_wheel_w/2) + 3, fork_h/2]) cube([50, 5, fork_h], center=true); 
        translate([0, -(main_wheel_w/2) - 3, fork_h/2]) cube([50, 5, fork_h], center=true); 
    } 
}

module aldi_ladder_chassis() { 
    translate([0, frame_side_y_pos, 0]) cube([ladder_frame_length, ladder_rail_w, ladder_rail_h], center=true); 
    translate([0, -frame_side_y_pos, 0]) cube([ladder_frame_length, ladder_rail_w, ladder_rail_h], center=true); 
    rung_inner_length = ladder_frame_outer_width - (ladder_rail_w * 2); 
    for (x = [-rung_spacing, 0, rung_spacing]) { 
        translate([x, 0, 0]) cube([rung_size, rung_inner_length, rung_size], center=true); 
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

module drop_bracket_spacer() { 
    y_center = (bracket_mount_style == 2)  
        ? frame_side_y_pos + (tube_width / 2) + (bracket_spacer_th / 2)  
        : frame_side_y_pos - (tube_width / 2) - (bracket_spacer_th / 2); 
    translate([0, y_center, 0]) 
        cube([drop_bracket_w, bracket_spacer_th, tube_height], center=true); 
} 

module external_side_wheel_mounting_tab(sw_y_pos, sw_z_pos) { 
    tab_thickness = 8;  
    bracket_face_offset = drop_bracket_th / 2; 
    span = abs(drop_bracket_y_pos - sw_y_pos) + bracket_face_offset; 
    y_center = (drop_bracket_y_pos + sw_y_pos) / 2; 
    z_pos = sw_z_pos + (small_wheel_w / 2) + (tab_thickness / 2); 
    translate([0, y_center, z_pos]) 
        cube([drop_bracket_w, span, tab_thickness], center=true); 
} 

// NEW: Structural Internal Bracket (Aligns with main bolts or rungs)
module internal_side_bracket(sw_y_pos, sw_z_pos, mount_z) { 
    plate_thickness = 8; 
    bracket_width = 80; // Matches castor plate width for shared bolting

    // 1. Horizontal Anchor Plate (Mounts to chassis rail or rung)
    // Runs from the center of the chassis rail inward to the drop leg
    span_len = abs(frame_side_y_pos - sw_y_pos);
    y_center = frame_side_y_pos - (span_len / 2);
    translate([0, y_center, mount_z - (plate_thickness / 2)]) 
        cube([bracket_width, span_len + 15, plate_thickness], center=true); 

    // 2. Heavy Drop Leg 
    drop_z_len = abs(mount_z - sw_z_pos) + 20; 
    vertical_y = sw_y_pos + (small_wheel_w / 2) + (plate_thickness / 2) + 2; 
    translate([0, vertical_y, mount_z - (drop_z_len / 2)]) 
        cube([bracket_width, plate_thickness, drop_z_len], center=true); 

    // 3. Solid Web Gusset (Prevents inward bending)
    inner_edge_y = frame_side_y_pos - (ladder_rail_w / 2);
    hull() { 
        translate([0, inner_edge_y, mount_z - plate_thickness - 2]) 
            cube([bracket_width, 2, 2], center=true); 
        translate([0, vertical_y + 2, mount_z - plate_thickness - 2]) 
            cube([bracket_width, 2, 2], center=true); 
        translate([0, vertical_y + 2, sw_z_pos + 15]) 
            cube([bracket_width, 2, 2], center=true); 
    } 
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

color("silver") aldi_ladder_chassis(); 

translate([wheel_x_pos, main_wheel_y, main_wheel_z]) factory_fixed_castor(); 
translate([wheel_x_pos, -main_wheel_y, main_wheel_z]) factory_fixed_castor(); 
translate([-wheel_x_pos, main_wheel_y, main_wheel_z]) factory_fixed_castor(); 
translate([-wheel_x_pos, -main_wheel_y, main_wheel_z]) factory_fixed_castor(); 

color("orange") { 
    if (enable_internal_side_wheels) {
        translate([int_sw_front_x, int_side_wheel_y_pos, int_side_wheel_z]) small_guide_wheel(); 
        translate([int_sw_front_x, -int_side_wheel_y_pos, int_side_wheel_z]) small_guide_wheel(); 
        translate([int_sw_rear_x, int_side_wheel_y_pos, int_side_wheel_z]) small_guide_wheel(); 
        translate([int_sw_rear_x, -int_side_wheel_y_pos, int_side_wheel_z]) small_guide_wheel(); 
    }
    if (enable_external_side_wheels) {
        translate([ext_sw_front_x, ext_side_wheel_y_pos, ext_side_wheel_z]) small_guide_wheel(); 
        translate([ext_sw_front_x, -ext_side_wheel_y_pos, ext_side_wheel_z]) small_guide_wheel(); 
        translate([ext_sw_rear_x, ext_side_wheel_y_pos, ext_side_wheel_z]) small_guide_wheel(); 
        translate([ext_sw_rear_x, -ext_side_wheel_y_pos, ext_side_wheel_z]) small_guide_wheel(); 
    }
} 

color("red") { 
    translate([wheel_x_pos, bottom_wheel_y, bottom_wheel_z]) small_captive_wheel(); 
    translate([wheel_x_pos, -bottom_wheel_y, bottom_wheel_z]) small_captive_wheel(); 
    translate([-wheel_x_pos, bottom_wheel_y, bottom_wheel_z]) small_captive_wheel(); 
    translate([-wheel_x_pos, -bottom_wheel_y, bottom_wheel_z]) small_captive_wheel(); 
} 

color("darkgray") { 
    translate([wheel_x_pos, drop_bracket_y_pos, 0]) drop_bracket(); 
    translate([wheel_x_pos, -drop_bracket_y_pos, 0]) drop_bracket(); 
    translate([-wheel_x_pos, drop_bracket_y_pos, 0]) drop_bracket(); 
    translate([-wheel_x_pos, -drop_bracket_y_pos, 0]) drop_bracket(); 
    
    translate([wheel_x_pos, 0, 0]) drop_bracket_spacer(); 
    translate([wheel_x_pos, 0, 0]) scale([1, -1, 1]) drop_bracket_spacer(); 
    translate([-wheel_x_pos, 0, 0]) drop_bracket_spacer(); 
    translate([-wheel_x_pos, 0, 0]) scale([1, -1, 1]) drop_bracket_spacer(); 
    
    // Internal Side Wheel Mounts (Top-Hung Brackets)
    if (enable_internal_side_wheels) {
        translate([int_sw_front_x, 0, 0]) internal_side_bracket(int_side_wheel_y_pos, int_side_wheel_z, int_sw_mount_z); 
        translate([int_sw_front_x, 0, 0]) scale([1, -1, 1]) internal_side_bracket(int_side_wheel_y_pos, int_side_wheel_z, int_sw_mount_z); 
        translate([int_sw_rear_x, 0, 0]) internal_side_bracket(int_side_wheel_y_pos, int_side_wheel_z, int_sw_mount_z); 
        translate([int_sw_rear_x, 0, 0]) scale([1, -1, 1]) internal_side_bracket(int_side_wheel_y_pos, int_side_wheel_z, int_sw_mount_z); 
    }
    
    // External Side Wheel Mounts
    if (enable_external_side_wheels) {
        translate([ext_sw_front_x, 0, 0]) external_side_wheel_mounting_tab(ext_side_wheel_y_pos, ext_side_wheel_z); 
        translate([ext_sw_front_x, 0, 0]) scale([1, -1, 1]) external_side_wheel_mounting_tab(ext_side_wheel_y_pos, ext_side_wheel_z); 
        translate([ext_sw_rear_x, 0, 0]) external_side_wheel_mounting_tab(ext_side_wheel_y_pos, ext_side_wheel_z); 
        translate([ext_sw_rear_x, 0, 0]) scale([1, -1, 1]) external_side_wheel_mounting_tab(ext_side_wheel_y_pos, ext_side_wheel_z); 
    }
    
    if (bottom_axle_style == 2) { 
        translate([wheel_x_pos, 0, 0]) bottom_support_block(1); 
        translate([wheel_x_pos, 0, 0]) bottom_support_block(-1); 
        translate([-wheel_x_pos, 0, 0]) bottom_support_block(1); 
        translate([-wheel_x_pos, 0, 0]) bottom_support_block(-1); 
    } 
} 

color("dimgray") { 
    if (enable_internal_side_wheels) {
        translate([int_sw_front_x, int_side_wheel_y_pos, int_side_wheel_z]) side_axle(); 
        translate([int_sw_front_x, -int_side_wheel_y_pos, int_side_wheel_z]) side_axle(); 
        translate([int_sw_rear_x, int_side_wheel_y_pos, int_side_wheel_z]) side_axle(); 
        translate([int_sw_rear_x, -int_side_wheel_y_pos, int_side_wheel_z]) side_axle(); 
    }
    if (enable_external_side_wheels) {
        translate([ext_sw_front_x, ext_side_wheel_y_pos, ext_side_wheel_z]) side_axle(); 
        translate([ext_sw_front_x, -ext_side_wheel_y_pos, ext_side_wheel_z]) side_axle(); 
        translate([ext_sw_rear_x, ext_side_wheel_y_pos, ext_side_wheel_z]) side_axle(); 
        translate([ext_sw_rear_x, -ext_side_wheel_y_pos, ext_side_wheel_z]) side_axle(); 
    }
    
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

translate([0, -total_outer_width/2 - 60, max_z_point]) 
    visual_dimension_line(str("LENGTH: ", total_outer_length, "mm"), total_outer_length); 
translate([total_outer_length/2 + 60, 0, max_z_point]) 
    rotate([0, 0, 90]) 
        visual_dimension_line(str("WIDTH: ", total_outer_width, "mm"), total_outer_width); 
translate([-total_outer_length/2 - 60, -total_outer_width/2 - 10, (max_z_point + min_z_point)/2]) 
    rotate([0, -90, 0]) 
        visual_dimension_line(str("HEIGHT: ", total_outer_height, "mm"), total_outer_height);