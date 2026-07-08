// --- CONFORMAL NEGATIVE MOLD (MATERIAL SAVING) ---
// Updated with your exact dimensions!

outer_diameter = 155;      // Outer diameter of the entire gasket
rim_width = 4;             // Width of outer ring (Assuming 4mm to match spokes)
hub_diameter = 34;         // Outer diameter of the center solid circle
hole_diameter = 26;        // Diameter of the empty hole in the center
spoke_width = 4;           // Width of the 6 connecting spokes
height = 7;                // Total Z-height (thickness) of the dome
num_spokes = 6;            // Number of spokes

// --- MOLD SPECIFIC SETTINGS ---
mold_base_thickness = 2;   // Minimized to 2mm to save plastic
mold_wall_thickness = 3;   // Minimized to 3mm walls hugging the gasket

$fn = 120;                 // Resolution/smoothness of the curves

// --- DO NOT EDIT BELOW THIS LINE ---

// 1. 2D Profile for the domed rings
module half_oval(w, h) {
    intersection() {
        scale([w, h * 2]) circle(d=1);
        translate([-w/2, 0]) square([w, h * 2]);
    }
}

// 2. The Gasket Shape
module gasket() {
    union() {
        // Outer Ring (Domed)
        rotate_extrude() {
            translate([(outer_diameter - rim_width)/2, 0, 0])
                half_oval(rim_width, height);
        }
        
        // Center Hub Ring (Domed)
        rotate_extrude() {
            translate([(hub_diameter + hole_diameter)/4, 0, 0])
                half_oval((hub_diameter - hole_diameter)/2, height);
        }
        
        // Spokes (Domed)
        for (i = [0 : num_spokes - 1]) {
            rotate([0, 0, i * (360 / num_spokes)])
                translate([hole_diameter/2, 0, 0])
                intersection() {
                    rotate([0, 90, 0])
                        scale([height*2, spoke_width, 1]) 
                            cylinder(d=1, h=(outer_diameter - hole_diameter)/2);
                    translate([0, -spoke_width, 0]) 
                        cube([outer_diameter, spoke_width*2, height*2]);
                }
        }
    }
}

// 3. Material-Saving Mold Shell (Trough Style)
module mold_shell() {
    union() {
        // Outer ring trough
        difference() {
            cylinder(d=outer_diameter + (mold_wall_thickness * 2), h=height + mold_base_thickness);
            translate([0, 0, -1])
                cylinder(d=outer_diameter - (rim_width * 2) - (mold_wall_thickness * 2), h=height + mold_base_thickness + 2);
        }
        
        // Hub trough
        difference() {
            cylinder(d=hub_diameter + (mold_wall_thickness * 2), h=height + mold_base_thickness);
            // Cut out the very center to save even more material
            translate([0, 0, -1])
                cylinder(d=max(0, hole_diameter - (mold_wall_thickness * 2)), h=height + mold_base_thickness + 2);
        }
        
        // Spoke troughs
        for (i = [0 : num_spokes - 1]) {
            rotate([0, 0, i * (360 / num_spokes)])
                translate([0, -(spoke_width + (mold_wall_thickness * 2))/2, 0])
                    cube([outer_diameter/2, spoke_width + (mold_wall_thickness * 2), height + mold_base_thickness]);
        }
    }
}

// 4. Create the Mold Cavity
difference() {
    // Start with the tight-fitting shell
    mold_shell();
    
    // Subtract the inverted gasket
    translate([0, 0, height + mold_base_thickness])
        rotate([180, 0, 0])
            gasket();
}
// --- SHOW THE ORIGINAL GASKET NEXT TO THE MOLD ---
if ($preview) {
    // Move the gasket off to the right side
    translate([outer_diameter + 15, 0, 0]) {
        
        // Draw the gasket in green
        color("green", 0.9) 
            gasket();
        
        // Add a label above it
        translate([0, (outer_diameter/2) + 8, height + 15]) 
            color("blue", 0.7)
                linear_extrude(1) 
                    text("Original Gasket", size=5, halign="center");
    }
}

// --- FLOATING BLUE MEASUREMENT LABEL ---
// --- ALL PARAMETER MEASUREMENT LABELS (TOP-VIEW OPTIMIZED) ---
if ($preview) {
    color("blue", 0.7) 
    // Lift all labels 15mm into the air so they float perfectly flat above the mold
    translate([0, 0, height + mold_base_thickness + 15]) {
        
        // 1. Outer Diameter (Placed at the top edge)
        translate([0, (outer_diameter/2) + 8, 0]) {
            cube([outer_diameter, 1, 1], center=true);
            translate([0, 3, 0]) 
                linear_extrude(1) text(str("Outer: ", outer_diameter, " mm"), size=5, halign="center");
        }

        // 2. Hub Diameter (Placed just above the center)
        translate([0, (hub_diameter/2) + 6, 0]) {
            cube([hub_diameter, 1, 1], center=true);
            translate([0, 2, 0]) 
                linear_extrude(1) text(str("Hub: ", hub_diameter, " mm"), size=4, halign="center");
        }
        
        // 3. Hole Diameter (Placed exactly in the center hole)
        translate([0, -2, 0]) {
            cube([hole_diameter, 1, 1], center=true);
            translate([0, 2, 0]) 
                linear_extrude(1) text(str("Hole: ", hole_diameter, " mm"), size=4, halign="center");
        }

        // 4. Spoke Width (Hovering over the right-side horizontal spoke)
        translate([outer_diameter/3, 0, 0]) {
            // Draws a small line across the width of the spoke
            cube([1, spoke_width, 1], center=true); 
            translate([0, (spoke_width/2) + 3, 0]) 
                linear_extrude(1) text(str("Spoke: ", spoke_width, " mm"), size=4, halign="center");
        }

        // 5. Z-Height Callout (Placed off to the bottom-right corner)
        translate([(outer_diameter/2) + 5, -(outer_diameter/2) + 10, 0]) {
            linear_extrude(1) text(str("Dome Height: ", height, " mm"), size=5, halign="left");
        }
    }
}