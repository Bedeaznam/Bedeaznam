// 7Y - L angle bracket (timber connector style), modelled from photo
// Default: 40 x 90 x 40 mm, 2.5 mm thick, 8 holes on the upright, 1 big + 4 small on the base.
// For 3D print use thicker material (see t) and PETG/PAHT-CF.

width  = 40;    // bracket width
tall   = 90;    // upright height
base   = 40;    // base length
t      = 3;     // thickness (steel original ~2.5; use 3-4 for print)
bend_r = 4;     // inside bend radius

hole_d      = 5;     // small holes
big_hole_d  = 11;    // big hole in base
hole_inset  = 9;     // hole column from edge
row_pitch   = 20;    // vertical spacing on upright
rows        = 4;
first_row_z = 15;    // first row height above base top

$fn = 64;

module plate_2d(l, w) { square([l, w]); }

module bracket() {
    difference() {
        // L profile in XZ, extruded along Y (width)
        rotate([90, 0, 0]) translate([0, 0, -width])
            linear_extrude(width)
                difference() {
                    R = bend_r + t;
                    union() {
                        difference() { square([base, tall]); square([R, R]); }
                        translate([R, R]) circle(r = R);
                    }
                    offset(r = bend_r) offset(delta = -bend_r)
                        translate([t, t]) square([base, tall]);
                }
        // upright holes: 2 columns, staggered rows
        for (r = [0 : rows - 1], c = [0, 1])
            translate([-1, c == 0 ? hole_inset : width - hole_inset,
                       first_row_z + r * row_pitch + (c == 1 ? row_pitch / 2 : 0)])
                rotate([0, 90, 0]) cylinder(d = hole_d, h = t + 2);
        // base holes
        translate([base / 2 + 3, width / 2, -1]) cylinder(d = big_hole_d, h = t + 2);
        for (p = [[base * 0.45, hole_inset], [base * 0.45, width - hole_inset],
                  [base - 7, hole_inset + 3], [base - 7, width - hole_inset - 3]])
            translate([p[0], p[1], -1]) cylinder(d = hole_d, h = t + 2);
    }
}

// print orientation: upright lying flat is impossible for an L; print standing on base
bracket();
