// --- FILTERMASTER GASKET NEGATIVE MOLD GENERATOR ---
// Measure your original part in millimeters and adjust the numbers below!

outer_diameter = 155;      // Outer diameter of the entire gasket
rim_width = 4;             // Width of the outer ring wall
hub_diameter = 34;         // Outer diameter of the center solid circle
hole_diameter = 26;        // Diameter of the empty hole in the center
spoke_width = 4;           // Width of the 6 connecting spokes
height = 7;                // Total Z-height (thickness) of the dome
num_spokes = 6;            // Number of spokes

// --- MOLD SPECIFIC SETTINGS ---
mold_base_thickness = 3;   // Thickness of the solid bottom of the mold
mold_wall_thickness = 5;   // Thickness of the outer walls of the mold

$fn = 120;                 // Resolution/smoothness of the curves

// --- DO NOT EDIT BELOW THIS LINE ---

// 1. 2D Profile for the domed rings
module half_oval(w, h) {
    intersection() {
        scale([w, h * 2]) circle(d=1);
        translate([-w/2, 0]) square([w, h * 2]);
    }
}

// 2. The Gasket shape wrapped in a module so we can subtract it
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

// 3. Create the Negative Mold (Boolean Difference)
difference() {
    // Step A: Create the solid mold box (a cylinder slightly larger than the gasket)
    cylinder(d=outer_diameter + (mold_wall_thickness * 2), h=height + mold_base_thickness);
    
    // Step B: Subtract the gasket
    // We rotate it 180 degrees so the dome points down into the mold.
    // We then move it UP so the flat part is perfectly flush with the top of the mold.
    translate([0, 0, height + mold_base_thickness])
        rotate([180, 0, 0])
            gasket();
}
