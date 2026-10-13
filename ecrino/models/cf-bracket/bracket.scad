// ============================================================
// Y7 — Structural L-bracket (tuned for PAHT-CF / carbon-fibre nylon)
// Stiff, heat-resistant load bracket with gusset ribs + bolt holes.
// Print flat on the outside of the L, no supports. Units: mm.
// ============================================================

leg_a    = 60;    // length of leg A
leg_b    = 60;    // length of leg B
width    = 40;    // bracket width
thick    = 6;     // plate thickness
bolt_d   = 6.5;   // clearance for M6
rib_t    = 5;     // gusset rib thickness
ribs     = 2;     // number of stiffening ribs
$fn      = 48;
eps      = 0.05;

module bolt(x, z) {
    translate([x, -eps, z]) rotate([-90, 0, 0]) cylinder(h = thick + 2*eps, r = bolt_d/2);
}

module bracket() {
    difference() {
        union() {
            // leg A (vertical)
            cube([width, thick, leg_a]);
            // leg B (horizontal)
            cube([width, leg_b, thick]);
            // gusset ribs (triangular) spanning the inner corner
            for (i = [0 : ribs - 1]) {
                x = width/(ribs+1) * (i+1) - rib_t/2;
                translate([x, thick, thick])
                    rotate([90, 0, 90])
                        linear_extrude(height = rib_t)
                            polygon([[0,0],[leg_b-thick,0],[0,leg_a-thick]]);
            }
        }
        // bolt holes in leg A (front face)
        bolt(width*0.30, leg_a*0.62);
        bolt(width*0.70, leg_a*0.62);
        // bolt holes in leg B (through the flat, drilled from top)
        translate([width*0.30, leg_b*0.62, -eps]) cylinder(h = thick + 2*eps, r = bolt_d/2);
        translate([width*0.70, leg_b*0.62, -eps]) cylinder(h = thick + 2*eps, r = bolt_d/2);
    }
}

bracket();
