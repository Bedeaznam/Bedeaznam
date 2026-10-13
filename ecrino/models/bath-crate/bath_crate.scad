// Bathroom slatted crate ("щайгичка") — 200 x 100 x 50 mm, ASA, no supports
// Slatted walls + drainage floor, rounded corners, chamfered feet.

L = 200;      // length (X)
W = 100;      // width  (Y)
H = 50;       // height (Z)
wall = 2.4;   // wall thickness (4 perimeters @0.6 nozzle)
floor_t = 2.4;
r = 6;        // corner radius
slot_w = 6;   // wall slot width
slot_h = 22;  // wall slot height
slot_gap = 6; // material between slots
frame = 9;    // solid frame above/below wall slots
floor_hole = 7;
foot_h = 3;   // small feet so water drains under
handle_w = 40; handle_h = 12;

$fn = 48;

module rrect(l, w, h, rr) {
    hull() for (x = [-1, 1], y = [-1, 1])
        translate([x * (l / 2 - rr), y * (w / 2 - rr), 0]) cylinder(r = rr, h = h);
}

module slots_along(len, z0, count_dir) {
    n = floor((len - 2 * frame) / (slot_w + slot_gap));
    total = n * slot_w + (n - 1) * slot_gap;
    for (i = [0 : n - 1])
        translate([-total / 2 + i * (slot_w + slot_gap) + slot_w / 2, 0, z0])
            children();
}

module body() {
    difference() {
        rrect(L, W, H, r);
        // cavity
        translate([0, 0, floor_t]) rrect(L - 2 * wall, W - 2 * wall, H, r - wall);

        // long-side slots (X walls)
        for (s = [-1, 1])
            slots_along(L, frame + slot_h / 2, 0)
                translate([0, s * (W / 2), 0]) cube([slot_w, wall * 3, slot_h], center = true);
        // short-side slots (Y walls) — leave middle for handle cut-out
        for (s = [-1, 1], y = [-1, 1])
            translate([s * (L / 2), y * (W / 4 + 4), frame + slot_h / 2 - 4])
                for (k = [-1, 0, 1]) translate([0, k * (slot_w + slot_gap), 0])
                    cube([wall * 3, slot_w, slot_h - 8], center = true);
        // handle cut-outs on the short sides (top edge)
        for (s = [-1, 1])
            translate([s * (L / 2), 0, H])
                hull() {
                    for (x = [-1, 1]) translate([0, x * (handle_w / 2 - handle_h / 2), 0])
                        rotate([0, 90, 0]) cylinder(r = handle_h / 2, h = wall * 3, center = true);
                    translate([0, 0, handle_h]) cube([wall * 3, handle_w, 1], center = true);
                }

        // drainage floor: staggered round holes
        nx = floor((L - 2 * wall - 10) / (floor_hole + 5));
        ny = floor((W - 2 * wall - 10) / (floor_hole + 5));
        for (i = [0 : nx - 1], j = [0 : ny - 1])
            translate([-(nx - 1) * (floor_hole + 5) / 2 + i * (floor_hole + 5),
                       -(ny - 1) * (floor_hole + 5) / 2 + j * (floor_hole + 5) + ((i % 2) ? 3 : 0), -1])
                if (abs(-(ny - 1) * (floor_hole + 5) / 2 + j * (floor_hole + 5) + ((i % 2) ? 3 : 0)) < W / 2 - wall - floor_hole)
                    cylinder(d = floor_hole, h = floor_t + 2);
    }
    // feet
    for (x = [-1, 1], y = [-1, 1])
        translate([x * (L / 2 - 12), y * (W / 2 - 12), -foot_h])
            cylinder(d1 = 10, d2 = 14, h = foot_h + 0.01);
}

translate([0, 0, foot_h]) body();
