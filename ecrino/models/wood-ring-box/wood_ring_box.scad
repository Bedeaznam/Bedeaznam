// ============================================================
// Ecrino / Y7 — Wooden ring box (tuned for PLA Wood)
// Parametric, FDM-friendly. Units: millimetres.
//
//   part = "base"   -> tray with cavity, magnet pockets, hinge knuckles
//   part = "lid"    -> beveled lid with engraved tree-of-life, magnets, hinge
//   part = "insert" -> velvet/flock insert core with ring slot
//   part = "assembly" -> preview (lid shown open) — do NOT print as one
//
// Hinge: separate parts joined by a 1.75 mm filament off-cut as the pin
// (great fit for a 3D-print shop). Two magnets snap the front shut.
// PLA Wood notes: thicker walls, no supports, prints flat; sand + oil/stain
// afterwards for a real-wood finish.
// ============================================================

part = "assembly";   // "base" | "lid" | "insert" | "assembly"

// ---- outer size ----
L        = 62;   // X
W        = 58;   // Y (hinge is at the +Y / back edge)
corner_r = 9;

// ---- structure (a touch thicker for wood-fill PLA) ----
floor_t  = 3.4;
wall     = 3.4;
cavity_d = 18;
base_h   = floor_t + cavity_d;   // 21.4
lid_h    = 15;
lid_bevel = 3;   // top edge bevel

// ---- magnets (6 mm dia x 2 mm), front edge ----
magnet_d = 6.4;
magnet_h = 2.3;
mag_wall = 1.1;

// ---- hinge (1.75 mm filament pin) ----
pin_d      = 1.95;
knuckle_r  = 4.2;
hinge_span = 40;   // total width across X
knuckle_clear = 0.4;
hinge_y = W + knuckle_r - 1.2;   // axis sits just behind the back wall
hinge_z = base_h;

// ---- insert / ring slot ----
insert_clear = 0.6;
slot_w   = 2.6;
slot_len = 26;
slot_depth = 12;

// ---- engraving ----
engrave_d = 0.9;

eps = 0.01;
$fn = 72;

// ---------- helpers ----------
module rrect(l, w, r) {
    hull() {
        translate([r, r])         circle(r);
        translate([l - r, r])     circle(r);
        translate([r, w - r])     circle(r);
        translate([l - r, w - r]) circle(r);
    }
}
module rbox(l, w, h, r) { linear_extrude(height = h) rrect(l, w, r); }

mag_y = wall + magnet_d/2 + 1.0;          // near front edge (Y=0)
mag_x1 = L * 0.30;
mag_x2 = L * 0.70;

// hinge knuckle X-centres: 3 knuckles (base, lid, base)
kw = hinge_span / 3;                      // nominal knuckle width
kc = [ L/2 - kw, L/2, L/2 + kw ];         // centres of the 3 knuckles

module knuckle(cx, width, solid=true) {
    translate([cx - width/2, hinge_y, hinge_z])
        rotate([0, 90, 0])
            cylinder(h = width, r = knuckle_r);
}
module pin_hole() {
    translate([L/2 - hinge_span/2 - 2, hinge_y, hinge_z])
        rotate([0, 90, 0])
            cylinder(h = hinge_span + 4, r = pin_d/2);
}

// ---------- BASE ----------
module base() {
    difference() {
        union() {
            rbox(L, W, base_h, corner_r);
            // base gets the two OUTER knuckles (index 0 and 2)
            for (i = [0, 2]) knuckle(kc[i], kw - knuckle_clear);
            // webs joining outer knuckles to the back wall
            for (i = [0, 2])
                translate([kc[i] - (kw-knuckle_clear)/2, W - wall, 0])
                    cube([kw - knuckle_clear, hinge_y - (W - wall) + eps, hinge_z]);
        }
        // cavity
        translate([wall, wall, floor_t])
            rbox(L - 2*wall, W - 2*wall, cavity_d + eps, max(1, corner_r - 3));
        // magnet pockets (open upward)
        for (mx = [mag_x1, mag_x2])
            translate([mx, mag_y, base_h - magnet_h - mag_wall])
                cylinder(d = magnet_d, h = magnet_h + eps);
        pin_hole();
    }
}

// ---------- LID ----------
module lid_solid() {
    // beveled slab: bottom footprint = full, top slightly inset
    hull() {
        rbox(L, W, 0.1, corner_r);
        translate([lid_bevel, lid_bevel, lid_h - 0.1])
            rbox(L - 2*lid_bevel, W - 2*lid_bevel, 0.1, max(1, corner_r - lid_bevel));
    }
}

module tree_of_life() {
    // stylised engraved tree inside a ring
    difference() { circle(15); circle(13.6); }        // outer ring
    // trunk
    translate([-1.4, -13]) square([2.8, 12]);
    // branches / canopy (simple radiating strokes + dots)
    for (a = [-60, -30, 0, 30, 60])
        rotate(a) translate([0, 2]) square([1.6, 12], center = true);
    for (a = [-70, -35, 0, 35, 70])
        rotate(a) translate([0, 12.5]) circle(1.8);
}

module lid() {
    difference() {
        union() {
            lid_solid();
            // lid gets the MIDDLE knuckle (index 1)
            knuckle(kc[1], kw - knuckle_clear);
            translate([kc[1] - (kw-knuckle_clear)/2, W - wall, 0])
                cube([kw - knuckle_clear, hinge_y - (W - wall) + eps, hinge_z]);
        }
        // hollow underside so it caps the base rim
        translate([wall*0.6, wall*0.6, -eps])
            rbox(L - 1.2*wall, W - 1.2*wall, lid_h - 2.6, max(1, corner_r - 2));
        // engraved tree on top
        translate([L/2, W/2 + 3, lid_h - engrave_d])
            linear_extrude(engrave_d + eps) tree_of_life();
        // magnet pockets (underside, align with base)
        for (mx = [mag_x1, mag_x2])
            translate([mx, mag_y, -eps])
                cylinder(d = magnet_d, h = magnet_h + eps);
        pin_hole();
    }
}

// ---------- INSERT ----------
module insert() {
    il = L - 2*wall - 2*insert_clear;
    iw = W - 2*wall - 2*insert_clear;
    ih = cavity_d - insert_clear;
    difference() {
        rbox(il, iw, ih, max(1, corner_r - 3.5));
        translate([il/2 - slot_w/2, (iw - slot_len)/2, ih - slot_depth])
            cube([slot_w, slot_len, slot_depth + eps]);
    }
}

// ---------- layout ----------
if (part == "base") base();
else if (part == "lid") lid();
else if (part == "insert") insert();
else {
    base();
    color("Sienna")
        translate([wall + insert_clear, wall + insert_clear, floor_t]) insert();
    // lid rotated open about the hinge axis
    color("BurlyWood")
        translate([0, hinge_y, hinge_z])
            rotate([105, 0, 0])
                translate([0, -hinge_y, -hinge_z])
                    lid();
}
