// ============================================================
// Y7 — Mask holder wand (TPU, prints on Bambu AMS)
// A long flexible handle with a jaw at the tip that pinches the
// edge of a mask from the side. Units: millimetres.
//
//   printable = false -> EXACT spec: mouth 0.2 -> inner 0.1, relief 0.2
//   printable = true  -> FDM-safe slot that a 0.4 mm nozzle can resolve
//
// NOTE: a 0.1-0.2 mm slot is below FDM resolution; use printable=true
// for a wand that actually grips. TPU (95A) keeps the jaws springy so
// they flex open, grab the fabric, then hold it.
// ============================================================

printable = false;

// ---- handle (the "stick") ----
rod_len = 210;      // >= 200 mm as requested
rod_d   = 9;        // TPU flexes; 9 mm keeps it from being too floppy
end_knob = 11;      // rounded grip knob at the far end

// ---- jaw / clip head ----
clip_w  = 34;       // span of mask edge it grabs
clip_th = 6;        // total jaw thickness (two springy lips)
clip_h  = 22;

// ---- gripping slot ----
funnel_w = 3.0;     // lead-in V mouth so the fabric guides in
funnel_h = 2.0;
slot_depth = 12;    // how deep the mask sits

// exact spec vs printable
mouth_gap  = printable ? 0.7  : 0.2;   // opening at the mouth
inner_gap  = printable ? 0.35 : 0.1;   // pinch point deep inside
relief_gap = printable ? 1.4  : 0.2;   // internal relief so fabric locks

eps = 0.01;
$fn = 72;

top_z = rod_len + clip_h;

module rrect(l, w, r) {
    offset(r = r) offset(delta = -r) square([l, w], center = true);
}

module clip_block() {
    translate([0, 0, rod_len])
        linear_extrude(clip_h) rrect(clip_th, clip_w, 1.5);
}

module slot_box(w, z) {
    translate([0, 0, z]) cube([w, clip_w + 2, eps], center = true);
}

module slot_cutter() {
    union() {
        // lead-in funnel
        hull() { slot_box(funnel_w, top_z + eps); slot_box(mouth_gap, top_z - funnel_h); }
        // tapered pinch
        hull() { slot_box(mouth_gap, top_z - funnel_h); slot_box(inner_gap, top_z - slot_depth); }
        // internal relief channel (fabric bunches here and locks)
        translate([0, 0, top_z - slot_depth])
            rotate([90, 0, 0]) cylinder(h = clip_w + 2, r = relief_gap / 2, center = true);
    }
}

module mask_holder() {
    difference() {
        union() {
            // rounded end knob
            translate([0, 0, 0]) sphere(d = end_knob);
            // handle rod
            cylinder(d = rod_d, h = rod_len);
            // smooth transition rod -> jaw
            hull() {
                translate([0, 0, rod_len - 8]) cylinder(d = rod_d, h = eps);
                translate([0, 0, rod_len]) linear_extrude(eps) rrect(clip_th, clip_w, 1.5);
            }
            clip_block();
        }
        slot_cutter();
    }
}

mask_holder();
