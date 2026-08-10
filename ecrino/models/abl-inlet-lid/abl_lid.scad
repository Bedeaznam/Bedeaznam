// Replacement hinged lid for ABL-Sursum 1154-210 flush-mount 16 A caravan inlet.
// Original spare part: ABL art. E154200 (Klappdeckel, series 1154).
//
// Shape follows the original: a shallow cover (not a flat plate) with a smooth,
// slightly proud outer face, a chamfered edge rolling into a perimeter skirt,
// stiffening ribs on the INSIDE, hinge notches in the two top corners and drain
// slots along the bottom edge.
//
// Reference data (ABL / Eurotech):
//   flange (front plate) 115 h x 105 w x 95 d
//   wall cut out          90 h x  80 w x 80 d
// The lid is not dimensioned in any public datasheet, so the values marked
// MEASURE must be checked against the original part.

// ---------------------------------------------------------------- parameters
lid_w      = 105;   // MEASURE outer width  (across the hinge)
lid_h      = 100;   // MEASURE outer height (top edge to bottom edge)
depth      =  11;   // MEASURE how far the lid stands off the flange
wall       =   2.4; // skirt wall thickness
face_t     =   2.4; // front face thickness
corner_r   =   8;   // outer corner radius
cham       =   3;   // 45 deg chamfer at the face edge (prints face-down, no support)

// hinge: notches in the top corners for the flange lugs + knuckles for the pin
notch_w    =  20;   // MEASURE width of one top-corner notch
notch_d    =   7;   // MEASURE how deep the notch cuts into the lid
pin_d      =   3.2; // MEASURE hinge pin diameter + 0.2 clearance
knuckle_w  =  14;
knuckle_cc =  85;   // MEASURE centre-to-centre spacing of the hinge knuckles
                    // (defaults to the centres of the two top-corner notches)
knuckle_t  =   7;
pin_up     =   3.5; // pin axis above the lid top edge

// inside ribs, as on the original
ribs_n     =   4;
rib_len    =  70;
rib_w      =   6;
rib_h      =   2.0;
rib_pitch  =  11;
rib_y0     =  20;   // first rib, from the top edge

// bottom edge details
slots_n    =   3;   // drain slots
slot_w     =   6;
slot_h     =   1.6;
slot_cc    =  16;
grip_w     =  26;   // finger recess in the bottom skirt
grip_d     =   1.6;

$fn = 64;
eps = 0.05;

// ---------------------------------------------------------------- helpers
module rrect(w, h, r) {
    rr = max(0.5, r);
    offset(r = rr) offset(delta = -rr) square([w, h], center = true);
}

// shallow cover shell: chamfer from the face up into a vertical skirt
module shell(w, h, r, d, c) {
    hull() {
        linear_extrude(0.1) rrect(w - 2*c, h - 2*c, r - c);
        translate([0, 0, c]) linear_extrude(max(0.1, d - c)) rrect(w, h, r);
    }
}

module cover_solid() {
    shell(lid_w, lid_h, corner_r, depth, cham);
}

module cover_cavity() {
    translate([0, 0, face_t])
        shell(lid_w - 2*wall, lid_h - 2*wall, corner_r - wall, depth, cham);
}

module inside_ribs() {
    for (i = [0 : ribs_n - 1])
        translate([0, lid_h/2 - rib_y0 - i * rib_pitch, face_t - eps])
            hull() {
                translate([-rib_len/2 + rib_w/2, 0, 0]) cylinder(r = rib_w/2, h = rib_h);
                translate([ rib_len/2 - rib_w/2, 0, 0]) cylinder(r = rib_w/2, h = rib_h);
            }
}

// top-corner notches that clear the hinge lugs of the flange
module hinge_notches() {
    for (s = [-1, 1])
        translate([s * (lid_w/2 - notch_w/2), lid_h/2 - notch_d/2 + eps, -1])
            cube([notch_w + eps, notch_d, depth + 2], center = true);
}

// knuckles sit in the notches; the pin bore lies in the lid plane so the part
// prints flat with no support and the bore needs no drilling
module knuckles() {
    for (i = [0 : 1]) {
        x = -knuckle_cc/2 + i * knuckle_cc;
        translate([x, 0, 0]) difference() {
            hull() {
                translate([-knuckle_w/2, lid_h/2 - notch_d - 4, 0])
                    cube([knuckle_w, 6, knuckle_t]);
                translate([0, lid_h/2 + pin_up, knuckle_t/2])
                    rotate([0, 90, 0]) cylinder(r = knuckle_t/2, h = knuckle_w, center = true);
            }
            translate([0, lid_h/2 + pin_up, knuckle_t/2])
                rotate([0, 90, 0]) cylinder(d = pin_d, h = knuckle_w + 2, center = true);
        }
    }
}

module bottom_details() {
    // drain slots through the bottom skirt
    for (i = [0 : slots_n - 1])
        translate([(i - (slots_n - 1)/2) * slot_cc, -lid_h/2, depth - slot_h/2 - 1.5])
            cube([slot_w, wall * 4, slot_h], center = true);
    // finger recess
    translate([0, -lid_h/2 + grip_d/2 - eps, depth/2 + cham/2])
        cube([grip_w, grip_d, depth], center = true);
}

// ---------------------------------------------------------------- assembly
module abl_lid() {
    difference() {
        union() {
            difference() {
                cover_solid();
                cover_cavity();
                hinge_notches();
            }
            inside_ribs();
            knuckles();
        }
        bottom_details();
    }
}

abl_lid();
