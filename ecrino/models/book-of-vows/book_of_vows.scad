// ============================================================
// Ecrino — "Book of Vows" engagement ring box
// Parametric, FDM-friendly (Bambu Lab H2S). Units: millimetres.
//
// Prints as two parts + an optional insert core:
//   part = "base"   -> book body / tray (holds the velvet insert)
//   part = "cover"  -> front cover with engraved "VOWS" + border
//   part = "insert" -> printable core you flock/wrap in velvet
//   part = "assembly" -> both, for preview only (do NOT print)
//
// Hinge: glue a thin fabric/leather strip across the spine recess
// (like a real book box). Two magnets snap the cover shut.
// ============================================================

part = "assembly";   // "base" | "cover" | "insert" | "assembly"

// ---- Outer book dimensions ----
L        = 90;   // cover height (spine length), X
W        = 62;   // cover width, Y
corner_r = 4;    // rounded corners

// ---- Walls / structure ----
floor_t    = 3;    // base floor thickness
wall       = 3.2;  // side walls
spine_wall = 6;    // thicker wall on the hinge (spine) side, X=0
cavity_d   = 20;   // interior depth (insert sits here)
base_h     = floor_t + cavity_d;
cover_h    = 7;

// ---- Magnets (6 mm dia x 2 mm) ----
magnet_d = 6.4;
magnet_h = 2.3;
mag_wall = 1.2;    // material kept over the magnet pocket

// ---- Spine hinge recess (for glued fabric strip) ----
spine_recess_d = 1.2;
spine_recess_w = 14;

// ---- Insert core ----
insert_clear = 0.6;
slot_w       = 2.6;   // ring band slot width
slot_len     = 26;    // slot length
slot_depth   = 13;

// ---- Cover engraving ----
engrave_d   = 0.8;
border_in   = 6;      // border inset from edge
vows_text   = "VOWS";
vows_size   = 14;
vows_font   = "Liberation Serif:style=Bold";

eps = 0.01;
$fn = 64;

// ---------- helpers ----------
module rrect(l, w, r) {
    // rounded rectangle in XY, origin at (0,0)
    hull() {
        translate([r, r])         circle(r);
        translate([l - r, r])     circle(r);
        translate([r, w - r])     circle(r);
        translate([l - r, w - r]) circle(r);
    }
}

module rbox(l, w, h, r) {
    linear_extrude(height = h) rrect(l, w, r);
}

// magnet pocket positions on the opening (front) edge
mag_x = L - wall - magnet_d/2 - 1.5;
mag_y1 = W * 0.28;
mag_y2 = W * 0.72;

// ---------- BASE ----------
module base() {
    difference() {
        union() {
            difference() {
                // solid body
                rbox(L, W, base_h, corner_r);

                // inner cavity
                translate([spine_wall, wall, floor_t])
                    rbox(L - spine_wall - wall,
                         W - 2*wall,
                         cavity_d + eps,
                         max(0.5, corner_r - 2));

                // page-line grooves on the three non-spine faces
                page_grooves();

                // spine recess for glued hinge strip (outer X=0 face)
                translate([-eps, (W - spine_recess_w)/2, base_h*0.15])
                    cube([spine_recess_d + eps, spine_recess_w, base_h*0.7]);
            }

            // bosses that carry the magnet pockets through the cavity
            for (my = [mag_y1, mag_y2])
                translate([mag_x, my, floor_t - eps])
                    cylinder(d = magnet_d + 2*mag_wall, h = cavity_d + eps);
        }

        // magnet pockets, open upward so the magnets can be pressed in
        for (my = [mag_y1, mag_y2])
            translate([mag_x, my, base_h - magnet_h])
                cylinder(d = magnet_d, h = magnet_h + eps);
    }
}

module page_grooves() {
    n = 14;
    for (i = [1 : n]) {
        z = floor_t + i * (base_h - floor_t) / (n + 1);
        // front face (X = L)
        translate([L - 0.6, -1, z]) cube([1.2, W + 2, 0.5], center = false);
        // side faces (Y = 0 and Y = W)
        translate([spine_wall, -0.6, z]) cube([L - spine_wall + 1, 1.2, 0.5]);
        translate([spine_wall, W - 0.6, z]) cube([L - spine_wall + 1, 1.2, 0.5]);
    }
}

// ---------- COVER ----------
module cover() {
    difference() {
        rbox(L, W, cover_h, corner_r);

        // engraved gold border groove (top face)
        translate([0, 0, cover_h - engrave_d])
            linear_extrude(engrave_d + eps)
                difference() {
                    offset(-border_in) rrect(L, W, corner_r);
                    offset(-border_in - 1.1) rrect(L, W, corner_r);
                }

        // corner flourishes (small engraved scroll dots)
        for (cx = [border_in + 5, L - border_in - 5])
            for (cy = [border_in + 5, W - border_in - 5])
                translate([cx, cy, cover_h - engrave_d])
                    linear_extrude(engrave_d + eps)
                        flourish();

        // VOWS text, centered
        translate([L/2, W/2, cover_h - engrave_d])
            linear_extrude(engrave_d + eps)
                text(vows_text, size = vows_size, font = vows_font,
                     halign = "center", valign = "center");

        // spine recess on cover outer face too (X = 0)
        translate([-eps, (W - spine_recess_w)/2, cover_h*0.15])
            cube([spine_recess_d + eps, spine_recess_w, cover_h*0.7]);

        // magnet pockets underside (align with base)
        for (my = [mag_y1, mag_y2])
            translate([mag_x, my, -eps])
                cylinder(d = magnet_d, h = magnet_h + eps);
    }
}

module flourish() {
    // simple engraved corner ornament
    for (a = [0, 45, 90])
        rotate(a)
            translate([0, 1.6])
                square([0.9, 4], center = true);
    circle(1.2);
}

// ---------- INSERT CORE (flock or wrap in velvet) ----------
module insert() {
    il = L - spine_wall - wall - 2*insert_clear;
    iw = W - 2*wall - 2*insert_clear;
    ih = cavity_d - insert_clear;
    difference() {
        rbox(il, iw, ih, max(0.5, corner_r - 2.5));
        // ring band slot
        translate([il/2 - slot_w/2, (iw - slot_len)/2, ih - slot_depth])
            cube([slot_w, slot_len, slot_depth + eps]);
        // clearance for the magnet bosses in the base
        for (my = [mag_y1, mag_y2])
            translate([mag_x - spine_wall - insert_clear,
                       my - wall - insert_clear, -eps])
                cylinder(d = magnet_d + 2*mag_wall + 0.8, h = ih + 2*eps);
    }
}

// ---------- layout ----------
if (part == "base") base();
else if (part == "cover") cover();
else if (part == "insert") insert();
else {
    // assembly preview
    base();
    // insert seated in cavity
    color("Crimson")
        translate([spine_wall + insert_clear, wall + insert_clear, floor_t])
            insert();
    // cover shown open, rotated about the spine top edge
    color("Sienna")
        translate([0, 0, base_h])
            rotate([0, -110, 0])
                translate([0, 0, 0])
                    cover();
}
