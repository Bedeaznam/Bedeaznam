// ============================================================
// Y7 — Heart box (base, lidless) + matching decorative lid
// Two parts, selected with `part`:
//   part = "base" -> heart-shaped box WITHOUT a lid (a rim is left
//                    for a lid to sit on)
//   part = "lid"  -> a heart lid with feminine swirl / filigree
//                    curls on top and a locating lip underneath
// Units: millimetres. Both print flat on the bed, no supports.
//
// Export:
//   openscad -o heart_base.stl -D part=\"base\" heart_box.scad
//   openscad -o heart_lid.stl  -D part=\"lid\"  heart_box.scad
// ============================================================

part = "base";   // "base" or "lid"

// ---- overall size ----
S        = 110;   // heart bounding width (mm)
wall     = 3.0;   // side-wall thickness
floor_t  = 3.0;   // floor thickness
box_h    = 34;    // base height (without lid)

// ---- lid fit ----
lid_top   = 4.0;  // thickness of the lid top plate
lip_h     = 6.0;  // how deep the locating lip drops into the base
lip_gap   = 0.4;  // clearance so the lid drops on easily
rim_h     = lip_h + 1.5;  // height of the inner shoulder in the base

// ---- swirls (feminine filigree on the lid) ----
swirl_line = 2.6;   // stroke width of the curls
swirl_emb  = 2.2;   // how far the curls stand up from the lid

eps = 0.05;
$fn = 140;

// ---- heart outline (parametric, smooth) ----
// classic heart curve, scaled to width S and centred at origin
module heart2D(scl = 1.0) {
    steps = 220;
    pts = [ for (i = [0 : steps])
                let (t = i * 360 / steps,
                     x = 16 * pow(sin(t), 3),
                     y = 13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t))
                    [x, y] ];
    // raw curve spans ~ -16..16 in x (width 32). scale to S.
    k = scl * S / 34;
    scale([k, k]) translate([0, -1]) polygon(pts);
}

// ---------- BASE (no lid) ----------
module base() {
    difference() {
        linear_extrude(height = box_h) heart2D(1.0);
        // inner cavity, leaving a floor
        translate([0, 0, floor_t])
            linear_extrude(height = box_h) offset(r = -wall) heart2D(1.0);
        // inner shoulder / rim recess so the lid lip sits flush
        translate([0, 0, box_h - rim_h])
            linear_extrude(height = rim_h + eps)
                offset(r = -wall + 1.2) heart2D(1.0);
    }
}

// a single spiral curl drawn as a swept stroke (raised)
module curl(cx, cy, turns = 1.25, r0 = 3, growth = 3.2, dir = 1, rot = 0) {
    steps = 90;
    translate([cx, cy, 0]) rotate([0, 0, rot])
        linear_extrude(height = swirl_emb)
            for (i = [0 : steps - 1]) {
                a0 = dir * i * turns * 360 / steps;
                a1 = dir * (i + 1) * turns * 360 / steps;
                r_a = r0 + growth * i / steps * turns;
                r_b = r0 + growth * (i + 1) / steps * turns;
                hull() {
                    translate([r_a * cos(a0), r_a * sin(a0)]) circle(d = swirl_line);
                    translate([r_b * cos(a1), r_b * sin(a1)]) circle(d = swirl_line);
                }
            }
}

// symmetric feminine flourish centred on the lid
module filigree() {
    // central open-outline heart
    translate([0, 14, 0]) linear_extrude(height = swirl_emb)
        difference() { heart2D(0.26); offset(r = -swirl_line) heart2D(0.26); }
    // large scrolls sweeping out into each lobe (mirrored pair)
    for (m = [0, 1])
        mirror([m, 0, 0]) {
            curl(20, 20, turns = 1.5, r0 = 5,   growth = 7.0, dir = 1,  rot = 30);
            curl(30, 0,  turns = 1.2, r0 = 4,   growth = 6.0, dir = -1, rot = 210);
            curl(12, -14, turns = 1.1, r0 = 3.5, growth = 5.0, dir = 1,  rot = 120);
        }
    // graceful tail curl toward the bottom point
    curl(0, -34, turns = 1.4, r0 = 4, growth = 5.5, dir = 1, rot = 90);
}

// ---------- LID ----------
module lid() {
    union() {
        // top plate
        linear_extrude(height = lid_top) heart2D(1.0);
        // locating lip that drops into the base
        translate([0, 0, -lip_h])
            linear_extrude(height = lip_h + eps)
                difference() {
                    offset(r = -wall + 1.2 - lip_gap) heart2D(1.0);
                    offset(r = -wall - 2.0) heart2D(1.0);
                }
        // decorative swirls on top
        translate([0, 0, lid_top - eps]) filigree();
    }
}

if (part == "lid") lid();
else               base();
