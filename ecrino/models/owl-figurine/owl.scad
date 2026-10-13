// ============================================================
// Y7 — Owl figurine (tuned for PLA Wood)
// Decorative, prints flat on its base, no supports.
// Units: millimetres.
// ============================================================

H       = 70;   // total height
body_r  = 24;   // max body radius
$fn     = 120;
eps     = 0.05;

module egg_body() {
    // egg / owl body: rotate a rounded profile
    pts = [
        [0,        0],
        [body_r-6,  0],
        [body_r,    18],
        [body_r-2,  40],
        [body_r-9,  H-10],
        [8,         H],
        [0,         H],
    ];
    rotate_extrude() polygon(pts);
}

module eye(x) {
    translate([x, body_r-6, H-24]) {
        rotate([-90, 0, 0]) cylinder(h = 6, r = 9);          // eye disc
        translate([0, 4.5, 0]) rotate([-90, 0, 0]) cylinder(h = 4, r = 4.5); // pupil ring
        translate([0, 7.5, 0]) sphere(r = 2.6);              // pupil
    }
}

module beak() {
    translate([0, body_r-4, H-30])
        rotate([90, 0, 0]) scale([1, 1.4, 1]) cylinder(h = 8, r1 = 4.5, r2 = 0, center = false);
}

module ear_tuft(x) {
    translate([x, 0, H-6]) rotate([0, x > 0 ? 18 : -18, 0])
        scale([1, 0.7, 1]) cylinder(h = 16, r1 = 6, r2 = 0);
}

module wing(x) {
    translate([x, 2, H*0.42])
        rotate([0, 0, x > 0 ? -8 : 8])
            scale([0.5, 0.6, 1.4]) sphere(r = 12);
}

module feet() {
    for (x = [-8, 8])
        translate([x, body_r-10, 3])
            scale([1, 1.6, 0.4]) sphere(r = 6);
}

module belly_scales() {
    // rows of little scallops on the front to suggest feathers
    for (row = [0 : 4])
        for (col = [-2 : 2])
            translate([col*8, body_r-3, 18 + row*9 + (col%2)*4])
                rotate([-90,0,0]) scale([1,1,0.5]) sphere(r = 3.2);
}

module owl() {
    union() {
        difference() {
            egg_body();
            // flatten front slightly for the face/belly area (optional subtle)
        }
        eye(-11); eye(11);
        beak();
        ear_tuft(-12); ear_tuft(12);
        wing(-body_r+2); wing(body_r-2);
        feet();
    }
}

owl();
