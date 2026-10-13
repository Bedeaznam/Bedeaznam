// Replacement hinged lid for ABL-Sursum 1154-210 flush-mount 16 A caravan inlet.
// Original spare part: ABL art. E154200 (Klappdeckel, series 1154).
//
// Shape taken from photos of the original: a shallow "pillow" cover - gently
// crowned outer face, fully radiused edge rolling into a perimeter skirt, a
// raised strip along the top edge between the two hinge lugs, ribs on the
// INSIDE only, and drain slots plus a finger recess along the bottom edge.
//
// Reference data (ABL / Eurotech):
//   flange (front plate) 115 h x 105 w x 95 d
//   wall cut out          90 h x  80 w x 80 d
// The lid is not dimensioned in any public datasheet; values marked MEASURE
// must be checked against the original part.

// ---------------------------------------------------------------- parameters
lid_w      = 105;   // MEASURE outer width  (across the hinge)
lid_h      = 100;   // MEASURE outer height (top edge to bottom edge)
depth      =  11;   // MEASURE how far the lid stands off the flange
wall       =   2.4; // skirt wall thickness
face_t     =   2.4; // face thickness
corner_r   =   7;   // outer corner radius
edge_r     =   5;   // radius rolling from the face into the skirt
crown      =   1.2; // how much the face bulges outward
crown_in   =  12;   // how far the crown starts in from the edge (total, both sides)

// hinge
lug_w      =  12;   // MEASURE clearance notch for one flange hinge lug
lug_d      =   5;   // MEASURE depth of that notch
pin_d      =   3.2; // MEASURE hinge pin diameter + 0.2 clearance
knuckle_w  =  14;
knuckle_cc =  60;   // MEASURE centre-to-centre spacing of the hinge knuckles
knuckle_r  =   3.5; // material around the pin bore
pin_back   =   4;   // pin axis in from the top edge / down from the rim

band       =   0;   // the strip seen above the lid on photos belongs to the flange, not the lid
band_h     =   9;
band_deep  =   0.8;

// inside ribs
ribs_n     =   4;
rib_len    =  70;
rib_w      =   6;
rib_h      =   2.0;
rib_pitch  =  11;
rib_y0     =  22;

// bottom edge
slots_n    =   2;
slot_w     =   5;
slot_h     =   1.6;
slot_cc    =  18;
grip_w     =  26;
grip_d     =   1.6;

$fn   = 64;
steps = 8;          // slices used for the rolled edge
eps   = 0.05;

// ---------------------------------------------------------------- helpers
module rrect(w, h, r) {
    rr = max(0.5, r);
    offset(r = rr) offset(delta = -rr) square([w, h], center = true);
}

// one horizontal slice of the rolled edge, k = 0..steps
module roll_slice(w, h, rc, re, k) {
    a   = k * 90 / steps;
    z   = re * (1 - cos(a));
    ins = re * (1 - sin(a));
    translate([0, 0, z]) linear_extrude(0.01) rrect(w - 2*ins, h - 2*ins, rc - ins);
}

// rolled edge from the face plane (z = 0) up to z = re
module rolled_edge(w, h, rc, re) {
    for (k = [0 : steps - 1])
        hull() { roll_slice(w, h, rc, re, k); roll_slice(w, h, rc, re, k + 1); }
}

// gently crowned face, bulging towards -z (cr = 0 gives a flat face)
module crowned_face(w, h, rc, re, cr) {
    ins = re;   // outline at the face plane
    hull() {
        translate([0, 0, -cr]) linear_extrude(0.01)
            rrect(max(4, w - 2*ins - crown_in), max(4, h - 2*ins - crown_in), rc - ins);
        roll_slice(w, h, rc, re, 0);
    }
}

module cover(w, h, rc, re, d, cr) {
    union() {
        crowned_face(w, h, rc, re, cr);
        rolled_edge(w, h, rc, re);
        translate([0, 0, re]) linear_extrude(max(0.1, d - re)) rrect(w, h, rc);
    }
}

module inside_ribs() {
    for (i = [0 : ribs_n - 1])
        translate([0, lid_h/2 - rib_y0 - i * rib_pitch, face_t - eps])
            hull() {
                translate([-rib_len/2 + rib_w/2, 0, 0]) cylinder(r = rib_w/2, h = rib_h);
                translate([ rib_len/2 - rib_w/2, 0, 0]) cylinder(r = rib_w/2, h = rib_h);
            }
}

// shallow recess across the top edge, between the two hinge lugs
module top_band() {
    bw = lid_w - 2 * lug_w - 4;
    translate([0, lid_h/2 - band_h/2 - 2, -band_deep - 1])
        linear_extrude(band_deep + 1) rrect(bw, band_h, 3);
}

// small clearance notches for the flange hinge lugs
module lug_notches() {
    for (s = [-1, 1])
        translate([s * (lid_w/2 - lug_w/2 + eps), lid_h/2 - lug_d/2 + eps, depth/2 - 1])
            cube([lug_w, lug_d, depth + 6], center = true);
}

// knuckles sit inside, against the top wall, so nothing protrudes past the
// outline; the pin bore is horizontal in the print -> no support, no drilling
module knuckles() {
    for (i = [0 : 1]) {
        x  = -knuckle_cc/2 + i * knuckle_cc;
        yb = lid_h/2 - wall - pin_back;
        translate([x, 0, 0]) difference() {
            hull() {
                translate([-knuckle_w/2, yb - 1, face_t - eps])
                    cube([knuckle_w, pin_back + 1, depth - face_t]);
                translate([0, yb, depth - pin_back])
                    rotate([0, 90, 0])
                        cylinder(r = knuckle_r, h = knuckle_w, center = true);
            }
            translate([0, yb, depth - pin_back])
                rotate([0, 90, 0])
                    cylinder(d = pin_d, h = knuckle_w + 2, center = true);
        }
    }
}

module bottom_details() {
    for (i = [0 : slots_n - 1])
        translate([(i - (slots_n - 1)/2) * slot_cc, -lid_h/2, depth - slot_h/2 - 1.5])
            cube([slot_w, wall * 4, slot_h], center = true);
    translate([0, -lid_h/2 + grip_d/2 - eps, depth/2 + edge_r/2])
        cube([grip_w, grip_d, depth], center = true);
}

// ---------------------------------------------------------------- assembly
module abl_lid() {
    difference() {
        union() {
            difference() {
                cover(lid_w, lid_h, corner_r, edge_r, depth, crown);
                if (band) top_band();
                // inner cavity is kept flat so the ribs always sit on the floor
                translate([0, 0, face_t])
                    cover(lid_w - 2*wall, lid_h - 2*wall, corner_r - wall, edge_r, depth, 0);
                lug_notches();
            }
            inside_ribs();
            knuckles();
        }
        bottom_details();
    }
}

abl_lid();
