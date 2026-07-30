// ============================================================
// Y7 — Dual cup-holder unit for Mercedes S-Class W221 (2010)
// Parametric replica of the OEM twin holder: a rounded rectangular
// bezel with two OPEN-bottom tapered rings and spring-style grip
// hooks (like the reference photo), plus side mounting ears.
// Units: millimetres.
//
// !!! MEASURE YOUR CAR TO LOCK THE FIT !!!
// Mercedes does not publish the dimensions. `cup_d`, `cup_depth`
// and `center_spacing` are an ESTIMATE — measure your part and set
// them, then re-export. This reproduces the SHAPE; the exact console
// mount is simplified.
// ============================================================

// ---- the numbers you measure ----
cup_d          = 74;   // opening diameter of one round well
cup_depth      = 58;   // wall depth of a well
center_spacing = 82;   // distance between the two well centers

// ---- frame / body ----
margin   = 11;   // bezel border around the wells
bez_t    = 4.0;  // thickness of the flat top bezel
corner_r = 16;   // rounded corners of the bezel
wall     = 2.8;  // well wall thickness
taper    = 6.0;  // radius reduction top -> bottom
window_h = 26;   // height of the open cut-outs on the outer walls

// ---- spring grip hooks (the little black fingers) ----
hooks       = true;
hook_n      = 2;     // hooks per cup
hook_w      = 11;    // width of a hook
hook_t      = 3.2;   // thickness
hook_proj   = 4.0;   // how far the tip pokes into the well
hook_len    = 16;    // vertical length of the hook
hook_drop   = 3;     // gap below the rim

// ---- side mounting ears ----
ears     = true;
ear_w    = 16;
ear_l    = 12;
ear_t    = 4;
ear_hole = 4;

eps = 0.05;
$fn = 160;

top_R = cup_d / 2;
bot_R = top_R - taper;
H     = cup_depth;

L = center_spacing + cup_d + 2 * margin;   // bezel length (x)
W = cup_d + 2 * margin;                     // bezel width  (y)
cx = center_spacing / 2;

// 2D rounded rectangle
module rrect(l, w, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (l/2 - r), sy * (w/2 - r)]) circle(r = r);
}

// one open-bottom tapered ring wall (no floor)
module ring() {
    difference() {
        cylinder(h = H, r1 = bot_R + wall, r2 = top_R + wall);
        translate([0, 0, -eps])
            cylinder(h = H + 2*eps, r1 = bot_R, r2 = top_R);
    }
}

// a curved spring hook poking inward from angle `a` on the rim
module hook(a) {
    rotate([0, 0, a])
        translate([top_R - hook_proj, 0, H - hook_drop - hook_len])
            union() {
                // vertical blade against the wall
                translate([0, 0, hook_len/2])
                    cube([hook_t, hook_w, hook_len], center = true);
                // the inward-curling tip at the top
                translate([-1.5, 0, hook_len])
                    rotate([0, 25, 0])
                        cube([hook_t, hook_w, 5], center = true);
            }
}

// side mounting ear with a screw hole
module ear(sx) {
    translate([sx * (L/2), 0, H - ear_t])
        difference() {
            hull() {
                translate([0, -ear_w/2, 0]) cube([eps, ear_w, ear_t]);
                translate([sx * ear_l, -ear_w/4, 0]) cube([eps, ear_w/2, ear_t]);
            }
            translate([sx * (ear_l - 4), 0, -eps])
                cylinder(h = ear_t + 2*eps, d = ear_hole);
        }
}

module unit() {
    union() {
        difference() {
            union() {
                // flat top bezel tying the two wells together
                translate([0, 0, H - bez_t])
                    linear_extrude(height = bez_t) rrect(L, W, corner_r);
                // the two open rings
                translate([-cx, 0, 0]) ring();
                translate([ cx, 0, 0]) ring();
                // mounting ears
                if (ears) { ear(-1); ear(1); }
            }
            // open the two cups through the bezel
            translate([-cx, 0, -eps]) cylinder(h = H + 2*eps, r1 = bot_R, r2 = top_R);
            translate([ cx, 0, -eps]) cylinder(h = H + 2*eps, r1 = bot_R, r2 = top_R);
            // outer wall windows (lightening cut-outs, like the molded frame)
            for (s = [-cx, cx])
                translate([s, 0, 4])
                    for (a = [40, 140, 220, 320])
                        rotate([0, 0, a])
                            translate([top_R, 0, 0])
                                cube([wall * 4, 22, window_h], center = true);
        }
        // spring hooks added AFTER the cavity so their tips remain inside
        if (hooks)
            for (s = [-cx, cx], k = [0 : hook_n - 1])
                translate([s, 0, 0]) hook(90 + k * (360 / hook_n));
    }
}

unit();
