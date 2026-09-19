// ============================================================
// Y7 — Masquerade mask stick (TPU / AMS)
// A decorative turned-baluster handle with a SIDE jaw at the top:
// the pinch slot opens to the RIGHT so a mask is held to the side
// (like a Venetian mask-on-a-stick), not straight on top.
// Units: millimetres.
//
//   printable = false -> EXACT spec slot: mouth 0.2 -> inner 0.1, relief 0.2
//   printable = true  -> FDM-safe slot (0.4 mm nozzle): 0.7 -> 0.35, relief 1.4
// ============================================================

printable = true;

// ---- baluster handle ----
handle_len = 178;   // stick length (+ end knob) ~ 20 cm total
r_base     = 3.0;   // shaft radius
bulbs      = 5;     // decorative turned bulbs along the shaft

// ---- side jaw ----
clip_len  = 16;     // how far the jaw plate reaches out to the right
clip_th   = 6;      // plate thickness (the two springy lips are split in this)
clip_h    = 34;     // vertical span of mask edge it grabs

// ---- gripping slot ----
funnel_w   = 3.0;
funnel_h   = 2.0;
slot_depth = 12;
mouth_gap  = printable ? 0.7  : 0.2;
inner_gap  = printable ? 0.35 : 0.1;
relief_gap = printable ? 1.4  : 0.2;

eps = 0.01;
$fn = 96;

// turned profile: base shaft + bulbs + a lower grip swell + a top collar
function rprof(z) =
      r_base
    + 1.9 * (0.5 + 0.5 * cos(360 * bulbs * z / handle_len))
    + 3.0 * exp(-pow((z - 34) / 22, 2))
    + 1.4 * exp(-pow((z - handle_len) / 12, 2));

module handle() {
    rotate_extrude()
        polygon(concat(
            [[0, 0]],
            [ for (i = [0:140]) let(z = handle_len * i / 140) [ max(0.8, rprof(z)), z ] ],
            [[0, handle_len]]
        ));
    translate([0, 0, 0]) sphere(5.6);   // bottom knob
}

plate_x0 = 2.5;
plate_z0 = handle_len - 6;
x_mouth  = plate_x0 + clip_len;
zc       = plate_z0 + clip_h / 2;

module rrect(l, w, r) { offset(r = r) offset(delta = -r) square([l, w], center = true); }

module plate() {
    translate([0, 0, plate_z0])
        linear_extrude(clip_h)
            translate([plate_x0 + clip_len / 2, 0]) rrect(clip_len, clip_th, 1.2);
}

module neck() {
    hull() {
        translate([0, 0, plate_z0 - 2]) sphere(4.6);
        translate([plate_x0 + 3, 0, plate_z0 + 5]) sphere(3.6);
    }
}

// a thin slab: eps in X, 'gap' in Y, tall in Z, at x
module sbox(gap, x) { translate([x, 0, zc]) cube([eps, gap, clip_h + 2], center = true); }

module slot_cutter() {
    union() {
        hull() { sbox(funnel_w, x_mouth + eps);       sbox(mouth_gap, x_mouth - funnel_h); }
        hull() { sbox(mouth_gap, x_mouth - funnel_h); sbox(inner_gap, x_mouth - slot_depth); }
        translate([x_mouth - slot_depth, 0, zc])
            cylinder(h = clip_h + 2, r = relief_gap / 2, center = true);
    }
}

module mask_stick() {
    difference() {
        union() { handle(); neck(); plate(); }
        slot_cutter();
    }
}

color("Gold") mask_stick();
