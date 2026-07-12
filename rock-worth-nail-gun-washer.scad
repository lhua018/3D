// Parametric Nail Gun Valve Piston (v14 - Straight Inner Stem) - WITH MEASUREMENT LABELS

// --- DIMENSIONS ---
total_height = 22.5;         // USER MEASUREMENT: Total height of the outer part
stem_height = 28.5;          // MATCHES TOP RING: Stem goes all the way to the top
outer_cylinder_od = 25.0;    // Outer diameter of the straight cylinder above taper
outer_wall_thickness = 2.0;  // USER MEASUREMENT: 2mm thick wall
stem_diameter = 15.0;        // USER MEASUREMENT: Diameter of the straight inner stem
stem_inner_diameter = 4.5;   // USER MEASUREMENT: Top hole diameter
stem_hole_depth = 12.0;      // USER MEASUREMENT: Top hole depth
base_taper_start_d = 18.0;   // USER MEASUREMENT: Very bottom diameter
base_taper_height = 8.5;     // USER MEASUREMENT: Running distance of the taper
floor_thickness = 8.5;       // Thickness of the floor connecting inner stem to outer wall
top_ring_diameter = 33.0;    // USER MEASUREMENT: Diameter of the ring on top
top_ring_thickness = 3.0;    // GUESS: Thickness (height) of the top ring
max_outside_diameter = 30.0; // USER MEASUREMENT: Tip-to-tip fin diameter
tab_width = 3.0;             // Thickness of each fin
number_of_tabs = 6;          // Number of fins around the perimeter
base_inner_diameter = 12.0;  // Estimate for hollow cup underneath the part
base_recess_depth = 6.0;     // Estimate for hollow cup depth

// --- TOGGLE LABELS ---
show_labels = true;          // Set to false to hide 3D measurement labels before exporting STL

// --- RESOLUTION ---
$fn = 120;

// --- MODEL GENERATION ---
module Piston() {
    difference() {
        union() {
            // --- INNER STEM & FLOOR ---
            // Bounded by the outer profile so the floor doesn't poke out of the taper
            intersection() {
                union() {
                    // Solid floor spanning the entire inside width
                    cylinder(h=floor_thickness, d=outer_cylinder_od);
                    
                    // Straight inner stem from the bottom all the way to the top
                    cylinder(h=stem_height, d=stem_diameter);
                }
                // Bounding Outer Profile to prevent bulging
                union() {
                    cylinder(h=base_taper_height, d1=base_taper_start_d, d2=outer_cylinder_od);
                    translate([0, 0, base_taper_height])
                        cylinder(h=total_height, d=outer_cylinder_od);
                }
            }
            
            // --- OUTER CYLINDER, TAPER & TABS ---
            difference() {
                union() {
                    // Tapered base: 18mm flaring out to seamlessly meet the cylinder
                    cylinder(h=base_taper_height, d1=base_taper_start_d, d2=outer_cylinder_od);
                    
                    // Straight outer cylinder above the taper
                    translate([0, 0, base_taper_height])
                        cylinder(h=total_height - base_taper_height, d=outer_cylinder_od);
                    
                    // --- TABS (Conforming to the taper) ---
                    for (i = [0 : number_of_tabs - 1]) {
                        rotate([0, 0, i * (360 / number_of_tabs)])
                            rotate([90, 0, 0])
                            linear_extrude(height=tab_width, center=true)
                            polygon(points=[
                                [base_taper_start_d/2 - 0.5, 0], // Overlap inner base
                                [base_taper_start_d/2, 0],       // Outer tip at very bottom
                                [max_outside_diameter/2, base_taper_height], // Outer tip at end of taper
                                [max_outside_diameter/2, total_height],      // Outer tip at top
                                [outer_cylinder_od/2 - 0.5, total_height],   // Overlap inner top
                                [outer_cylinder_od/2 - 0.5, base_taper_height] // Overlap inner taper end
                            ]);
                    }
                }
                
                // Hollow out the straight section above the taper
                translate([0, 0, base_taper_height])
                    cylinder(h=total_height, d=outer_cylinder_od - (outer_wall_thickness * 2));
                
                // Hollow out the tapered section
                hollow_start_d = base_taper_start_d + (outer_cylinder_od - base_taper_start_d) * (floor_thickness / base_taper_height) - (outer_wall_thickness * 2);
                
                translate([0, 0, floor_thickness])
                    cylinder(h=base_taper_height - floor_thickness + 0.01, 
                             d1=hollow_start_d, 
                             d2=outer_cylinder_od - (outer_wall_thickness * 2));
            }
            
            // --- TOP RING (FLANGE) ---
            translate([0, 0, total_height - top_ring_thickness])
                difference() {
                    // Create the wider ring
                    cylinder(h=top_ring_thickness, d=top_ring_diameter);
                    // Hollow out the center so it matches the gap
                    translate([0, 0, -0.1])
                        cylinder(h=top_ring_thickness + 0.2, d=outer_cylinder_od - (outer_wall_thickness * 2));
                }
        }
        
        // --- CUTOUTS ---
        // Top hole in the inner stem
        translate([0, 0, stem_height - stem_hole_depth + 0.1])
            cylinder(h=stem_hole_depth, d=stem_inner_diameter);
        
        // Cup recess underneath the base
        translate([0, 0, -0.01])
            cylinder(h=base_recess_depth, d=base_inner_diameter);
    }
}

// --- DISPLAY ---
// Render the physical part
Piston();

// Render the visual measurement labels
if (show_labels) {
    color("red") {
        // Total Height Label
        translate([max_outside_diameter/2 + 5, 0, total_height]) 
            rotate([90, 0, 0]) 
            linear_extrude(0.5) text(str("Total H: ", total_height), size=1.5);
            
        // Stem Height Label
        translate([-max_outside_diameter/2 - 20, 0, stem_height]) 
            rotate([90, 0, 0]) 
            linear_extrude(0.5) text(str("Stem H: ", stem_height), size=1.5);

        // Outer Diameter Label
        translate([outer_cylinder_od/2 + 5, 0, base_taper_height + 5]) 
            rotate([90, 0, 0]) 
            linear_extrude(0.5) text(str("Outer OD: ", outer_cylinder_od), size=1.5);
            
        // Top Ring Diameter
        translate([top_ring_diameter/2 + 5, 0, total_height - top_ring_thickness]) 
            rotate([90, 0, 0]) 
            linear_extrude(0.5) text(str("Ring OD: ", top_ring_diameter), size=1.5);
            
        // Inner Stem Diameter
        translate([stem_diameter/2 + 2, 0, total_height + 2])
            rotate([90, 0, 0])
            linear_extrude(0.5) text(str("Stem OD: ", stem_diameter), size=1.5);
    }
}