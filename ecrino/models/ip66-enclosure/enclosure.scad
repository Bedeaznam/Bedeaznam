// 3D printable outdoor enclosure, 250 (h) x 200 (w) x 150 (d) mm, IP66 style.
// Built to the supplied drawings:
//   overall 250 x 200 x 150, usable interior 218 x 168
//   gasket groove 3 mm wide x 8 mm deep
//   M4 standoffs, 8 mm tall, for a 210 x 160 mounting plate with 4x O4.5
//   wall mounting holes O6, ~20 mm in from the corners
//   M20 cable gland entry in the bottom wall
//
// Parts (select with -D part="..."):
//   base   - box, print with the opening up
//   lid    - cover, print face (logo) down on the plate: smooth face, no support
//   plate  - mounting plate 210 x 160
//   gasket - TPU gasket frame for the groove (instead of EPDM cord)
//   all    - everything laid out side by side, for preview only

part = "all";

// ---------------------------------------------------------------- main sizes
OW        = 200;    // width  (X)
OL        = 250;    // height (Y) - the long side when wall mounted
OD        = 150;    // total depth (Z), base + lid
wall      =   4;
floor_t   =   4;
r_out     =  14;    // outer corner radius

lid_h     =  18;    // lid plate + skirt
lid_t     =   4;
base_h    = OD - lid_h;

// mating rim: inner flange thick enough to take the gasket groove
rim_w     =   5;    // extra thickness added inside along the top
rim_h     =  16;
groove_w  =   3;    // per drawing
groove_d  =   8;    // per drawing
tongue_w  =   2.6;
tongue_h  =   6.5;

// corner screw pillars (lid screws)
pil_d     =  13;
pil_in    =  12.5;  // pillar centre, in from the outer faces
screw_d   =   3.4;  // M4 self tapping
head_d    =   8;    // countersink in the lid
lid_hole  =   4.5;

// mounting plate + standoffs
pl_w      = 160;
pl_l      = 210;
pl_t      =   3;
pl_hole   =   4.5;
pl_in     =   8;    // plate holes, in from its edges
sto_h     =   8;    // per drawing
sto_d     =  10;

// wall mounting holes through the floor
mnt_d     =   6;
mnt_x     =  76;
mnt_y     = 106;

// M20 cable gland in the bottom wall
gl_d      =  20.5;
gl_z      =  32;    // above the inner floor
gl_boss_d =  32;
gl_boss_h =   5;

// logo engraved into the lid face
logo      = "7Y";
logo_size =  74;
logo_deep =   0.8;

$fn = 96;
eps = 0.05;

// ---------------------------------------------------------------- helpers
module rrect(w, h, r) {
    rr = max(0.5, r);
    offset(r = rr) offset(delta = -rr) square([w, h], center = true);
}

module box(w, l, r, hgt) { linear_extrude(hgt) rrect(w, l, r); }

// centreline of the gasket groove, measured in from the outer face
function groove_off() = wall + rim_w / 2;

module groove_ring(hgt) {
    o = groove_off();
    linear_extrude(hgt)
        difference() {
            rrect(OW - 2*o + groove_w, OL - 2*o + groove_w, r_out - o + groove_w/2);
            rrect(OW - 2*o - groove_w, OL - 2*o - groove_w, r_out - o - groove_w/2);
        }
}

module pillar_positions() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (OW/2 - pil_in), sy * (OL/2 - pil_in), 0]) children();
}

module standoff_positions() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (pl_w/2 - pl_in), sy * (pl_l/2 - pl_in), 0]) children();
}

// ---------------------------------------------------------------- base
module base() {
    difference() {
        union() {
            box(OW, OL, r_out, base_h);
            // gland boss on the bottom wall
            translate([0, -OL/2 - gl_boss_h + eps, floor_t + gl_z])
                rotate([-90, 0, 0]) cylinder(d = gl_boss_d, h = gl_boss_h);
        }

        // cavity
        translate([0, 0, floor_t])
            box(OW - 2*wall, OL - 2*wall, r_out - wall, base_h);

        // gasket groove in the top rim
        translate([0, 0, base_h - groove_d]) groove_ring(groove_d + 1);

        // cable gland
        translate([0, -OL/2 - gl_boss_h - 1, floor_t + gl_z])
            rotate([-90, 0, 0]) cylinder(d = gl_d, h = wall + gl_boss_h + 2);

        // wall mounting holes
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mnt_x, sy * mnt_y, -1])
                cylinder(d = mnt_d, h = floor_t + 2);
    }

    // inner rim flange, so the groove has material either side
    difference() {
        translate([0, 0, base_h - rim_h])
            linear_extrude(rim_h)
                difference() {
                    rrect(OW - 2*wall + eps, OL - 2*wall + eps, r_out - wall);
                    rrect(OW - 2*wall - 2*rim_w, OL - 2*wall - 2*rim_w, r_out - wall - rim_w);
                }
        translate([0, 0, base_h - groove_d]) groove_ring(groove_d + 1);
    }

    // corner pillars for the lid screws, gusseted into the corner walls
    difference() {
        for (sx = [-1, 1], sy = [-1, 1])
            hull() {
                translate([sx * (OW/2 - pil_in), sy * (OL/2 - pil_in), 0])
                    cylinder(d = pil_d, h = base_h - eps);
                translate([sx * (OW/2 - wall - 3), sy * (OL/2 - wall - 3), 0])
                    cylinder(d = 5, h = base_h - eps);
            }
        pillar_positions()
            translate([0, 0, base_h - 22]) cylinder(d = screw_d, h = 24);
    }

    // standoffs for the mounting plate
    difference() {
        standoff_positions()
            translate([0, 0, floor_t - eps]) cylinder(d = sto_d, h = sto_h);
        standoff_positions()
            translate([0, 0, floor_t + sto_h - 10]) cylinder(d = screw_d, h = 12);
    }
}

// ---------------------------------------------------------------- lid
// modelled face-down: z = 0 is the outer face, everything else grows upwards,
// so it prints with no support and a smooth visible face
module lid() {
    difference() {
        union() {
            box(OW, OL, r_out, lid_t);
            // skirt around the perimeter
            translate([0, 0, lid_t - eps])
                linear_extrude(lid_h - lid_t)
                    difference() {
                        rrect(OW, OL, r_out);
                        rrect(OW - 2*wall, OL - 2*wall, r_out - wall);
                    }
            // tongue that presses the gasket into the groove
            translate([0, 0, lid_h - eps])
                linear_extrude(tongue_h) {
                    o = groove_off();
                    difference() {
                        rrect(OW - 2*o + tongue_w, OL - 2*o + tongue_w, r_out - o + tongue_w/2);
                        rrect(OW - 2*o - tongue_w, OL - 2*o - tongue_w, r_out - o - tongue_w/2);
                    }
                }
            // screw bosses
            pillar_positions()
                translate([0, 0, lid_t - eps]) cylinder(d = pil_d, h = lid_h - lid_t);
        }

        // screw holes with a countersink in the outer face
        pillar_positions() {
            translate([0, 0, -1]) cylinder(d = lid_hole, h = lid_h + 2);
            translate([0, 0, -eps]) cylinder(d1 = head_d, d2 = lid_hole, h = 2.2);
        }

        // engraved logo, filled with a second colour on the first layers
        translate([0, 0, -eps])
            linear_extrude(logo_deep)
                mirror([1, 0, 0])
                    text(logo, size = logo_size, halign = "center", valign = "center",
                         font = "DejaVu Sans:style=Bold");
    }
}

// ---------------------------------------------------------------- plate
module plate() {
    difference() {
        linear_extrude(pl_t) rrect(pl_w, pl_l, 6);
        standoff_positions() translate([0, 0, -1]) cylinder(d = pl_hole, h = pl_t + 2);
    }
}

// ---------------------------------------------------------------- gasket
// print in TPU 95A, 0.2 mm layers, 2 walls, no infill
module gasket() {
    o = groove_off();
    linear_extrude(groove_d)
        difference() {
            rrect(OW - 2*o + tongue_w, OL - 2*o + tongue_w, r_out - o + tongue_w/2);
            rrect(OW - 2*o - tongue_w, OL - 2*o - tongue_w, r_out - o - tongue_w/2);
        }
}

// ---------------------------------------------------------------- output
if      (part == "base")   base();
else if (part == "lid")    lid();
else if (part == "plate")  plate();
else if (part == "gasket") gasket();
else {
    base();
    translate([OW + 30, 0, 0]) lid();
    translate([2 * (OW + 30), 0, 0]) plate();
    translate([2 * (OW + 30), OL + 30, 0]) gasket();
}
