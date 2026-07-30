// ============================================================
// Y7 — Dual cup-holder unit for Mercedes S-Class W221 (2010)
// A parametric replica of the OEM twin cup-holder: a rounded
// rectangular bezel with two tapered round wells and simple
// spring-style grip tabs. Units: millimetres. Prints upright
// (openings up), no supports.
//
// !!! MEASURE YOUR CAR TO LOCK THE FIT !!!
// Mercedes does not publish the dimensions. `cup_d`, `cup_depth`
// and `center_spacing` are an ESTIMATE — measure your part and set
// them, then re-export. This reproduces the SHAPE; the console
// mounting clips underneath are simplified, not an exact 1:1 mount.
// ============================================================

// ---- the numbers you measure ----
cup_d          = 74;   // opening diameter of one round well
cup_depth      = 60;   // depth of a well
center_spacing = 82;   // distance between the two well centers

// ---- frame / body ----
margin   = 11;   // bezel border around the wells
bez_t    = 4.0;  // thickness of the flat top bezel
corner_r = 16;   // rounded corners of the bezel
wall     = 2.6;  // well wall thickness
floor_t  = 3.0;  // well floor thickness
taper    = 8.0;  // radius reduction top -> bottom (drafts for printing)

// ---- grip tabs (the little spring fingers) ----
tabs      = true;
tab_w     = 10;   // width of a tab
tab_h     = 12;   // height of a tab
tab_proj  = 3.0;  // how far it pokes into the well
tab_drop  = 6;    // how far below the rim it sits

eps = 0.02;
$fn = 160;

top_R = cup_d / 2;
bot_R = top_R - taper;
H     = cup_depth;

L = center_spacing + cup_d + 2 * margin;   // bezel length
W = cup_d + 2 * margin;                     // bezel width
cx = center_spacing / 2;                    // half spacing

// 2D rounded rectangle
module rrect(l, w, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (l/2 - r), sy * (w/2 - r)]) circle(r = r);
}

// one tapered well (outer cone minus inner cavity, keeps a floor)
module well() {
    difference() {
        cylinder(h = H, r1 = bot_R + wall, r2 = top_R + wall);
        translate([0, 0, floor_t])
            cylinder(h = H, r1 = bot_R, r2 = top_R);
    }
}

// a single grip tab poking inward from the +x wall of a well
module grip_tab() {
    translate([top_R - tab_proj, 0, H - tab_drop - tab_h])
        rotate([0, 0, 0])
            hull() {
                translate([0, 0, tab_h]) rotate([0,90,0]) cylinder(h = tab_proj + 1, r = tab_w/2);
                translate([-2, 0, tab_h/2]) cube([1, tab_w, tab_h], center = true);
            }
}

module unit() {
    difference() {
        union() {
            // flat top bezel that ties the two wells together
            translate([0, 0, H - bez_t])
                linear_extrude(height = bez_t) rrect(L, W, corner_r);
            // the two wells
            translate([-cx, 0, 0]) well();
            translate([ cx, 0, 0]) well();
            // grip tabs (two per well: inner-facing + outer-facing)
            if (tabs) {
                translate([-cx, 0, 0]) { grip_tab(); rotate([0,0,180]) grip_tab(); }
                translate([ cx, 0, 0]) { grip_tab(); rotate([0,0,180]) grip_tab(); }
            }
        }
        // open the two cups through the bezel
        translate([-cx, 0, floor_t]) cylinder(h = H, r1 = bot_R, r2 = top_R);
        translate([ cx, 0, floor_t]) cylinder(h = H, r1 = bot_R, r2 = top_R);
    }
}

unit();
