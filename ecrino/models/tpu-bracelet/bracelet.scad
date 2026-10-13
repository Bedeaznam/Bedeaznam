// ============================================================
// Y7 — Flexible bracelet / cuff (tuned for TPU, AMS-friendly)
// Prints flat, no supports. Slight opening makes it springy.
// Units: millimetres.
// ============================================================

inner_d   = 62;   // wrist inner diameter
band_w    = 16;   // width (height when worn)
thick     = 3.0;  // wall thickness (TPU: 2.5-3.5 stays flexible)
gap_ang   = 40;   // open cuff gap (degrees) for spring-on fit
waves     = 18;   // chevron waves around the band
wave_amp  = 1.4;  // relief depth of the pattern
$fn       = 200;
eps       = 0.05;

R = inner_d/2;

module ring_band() {
    rotate_extrude(angle = 360 - gap_ang)
        translate([R, 0])
            offset(r = 1.2) offset(delta = -1.2)   // rounded corners
                square([thick, band_w], center = false);
}

module wave_relief() {
    // raised chevrons wrapped around the outer surface
    n = waves;
    for (i = [0 : n - 1]) {
        a = i * (360 - gap_ang) / n;
        rotate([0, 0, a])
            translate([R + thick - 0.4, 0, band_w/2])
                rotate([0, 90, 0])
                    cylinder(h = wave_amp + 0.6, r1 = 3.2, r2 = 0.6, center = false, $fn = 6);
    }
}

module rounded_ends() {
    // round the two ends of the open cuff
    for (a = [0, 360 - gap_ang])
        rotate([0, 0, a])
            translate([R + thick/2, 0, 0])
                cylinder(h = band_w, r = thick/2);
}

module bracelet() {
    union() {
        ring_band();
        rounded_ends();
        wave_relief();
    }
}

bracelet();
