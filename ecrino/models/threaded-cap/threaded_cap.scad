// 7Y - Threaded round cap (screw-in plug) with 4 internal pins
// Modelled from photos. All dimensions in mm - adjust to the real part.

// ---- outer cap ----
cap_d      = 46;    // outer diameter of the flat head
cap_h      = 6;     // head thickness (the visible rim)
head_edge_r = 1.5;  // rounding of the head edge

// ---- thread ----
thread_major = 40;  // outside diameter of the thread
thread_pitch = 3.0; // mm per turn
thread_depth = 1.2; // radial depth of the thread
thread_len   = 14;  // length of threaded part below the head
turns_start  = 0.5; // unthreaded run-in at the tip (mm)

// ---- inside ----
bore_d     = 32;    // inner cavity diameter
bore_depth = 12;    // cavity depth from the open end
boss_d     = 22;    // inner disc holding the pins
boss_h     = 3;     // disc height above cavity floor
pin_d      = 5.5;
pin_h      = 4;
pin_pcd    = 13;    // pin circle diameter
pin_count  = 4;

$fn = 96;

module head() {
    hull() {
        cylinder(d = cap_d, h = cap_h - head_edge_r);
        translate([0, 0, cap_h - head_edge_r])
            rotate_extrude()
                translate([cap_d / 2 - head_edge_r, 0]) circle(r = head_edge_r);
    }
}

// simple trapezoid-ish thread made by stacking a rotating ring
module thread(len, major, pitch, depth) {
    minor = major - 2 * depth;
    steps = 60;
    cylinder(d = minor, h = len);
    for (i = [0 : steps * len / pitch - 1]) {
        a0 = 360 * i / steps;
        a1 = 360 * (i + 1) / steps;
        z0 = pitch * i / steps;
        z1 = pitch * (i + 1) / steps;
        hull() {
            rotate([0, 0, a0]) translate([minor / 2 - 0.05, 0, z0]) thread_profile(depth, pitch);
            rotate([0, 0, a1]) translate([minor / 2 - 0.05, 0, z1]) thread_profile(depth, pitch);
        }
    }
}
module thread_profile(depth, pitch) {
    w = pitch * 0.45;
    rotate([90, 0, 0])
        linear_extrude(0.01)
            polygon([[0, -w / 2], [depth, -w * 0.15], [depth, w * 0.15], [0, w / 2]]);
}

module cap() {
    difference() {
        union() {
            translate([0, 0, thread_len]) head();
            intersection() {
                thread(thread_len + 0.01, thread_major, thread_pitch, thread_depth);
                // chamfer the tip
                cylinder(d1 = thread_major - 2 * thread_depth - 1, d2 = thread_major + 2,
                         h = thread_len + 0.01);
            }
        }
        translate([0, 0, -0.01]) cylinder(d = bore_d, h = bore_depth + 0.01);
    }
    // inner disc with pins
    translate([0, 0, bore_depth - boss_h]) {
        cylinder(d = boss_d, h = boss_h);
        for (i = [0 : pin_count - 1])
            rotate([0, 0, 90 * i + 45])
                translate([pin_pcd / 2, 0, -pin_h])
                    cylinder(d = pin_d, h = pin_h + 0.01);
    }
}

// print orientation: flat head on the bed
translate([0, 0, cap_h + thread_len]) mirror([0, 0, 1]) cap();
