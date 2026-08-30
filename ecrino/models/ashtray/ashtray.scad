// ============================================================
// Y7 — "Старата къща" ashtray
// A barrel-shaped ashtray modelled from the reference photo: ~9 cm
// wide, curved (bulging) body, cigarette-rest notches on the rim.
// Height lowered to 4 cm per request. Raised Cyrillic side text
// "СТАРАТА КЪЩА" for a 2-colour (white) print on Bambu Lab / AMS.
// Units: millimetres. Prints upright, no supports.
// ============================================================

// ---- overall size ----
D_max   = 90;   // widest outer diameter (~9 cm)
H       = 40;   // total height (4 cm)
wall    = 3.0;  // side wall thickness
floor_t = 4.0;  // floor thickness (weight + stability)

// ---- cigarette rests ----
notches   = 3;    // number of rim notches
notch_r   = 4.5;  // radius of a notch groove
notch_ang = 0;    // starting angle offset

// ---- side text (printed white) ----
do_text   = true;
text_str  = "СТАРАТА КЪЩА";
text_font = "DejaVu Sans:style=Bold";
text_size = 8.0;    // glyph height (mm)
text_emb  = 0.9;    // how far letters stand out (for the colour swap)
text_z    = 17;     // vertical centre of the text band
text_arc  = 150;    // total arc the text wraps across (deg)
text_face = 270;    // centre direction of the text (deg)
text_mirror = 0;    // 1 = mirror each glyph, 0 = not
text_dir    = 1;    // +1 or -1 layout direction

// which part to output: "all" (body+text fused), "body", or "text"
// Use -D part=\"body\" / -D part=\"text\" to export the 2-colour pair.
part = "all";

eps = 0.03;
$fn = 220;

R = D_max / 2;

// outer barrel profile (r,z) — convex bulge like the photo
outer_pts = [
    [0,        0],
    [R - 9,    0],
    [R - 3,    6],
    [R,        18],
    [R - 2,    30],
    [R - 6,    H],
    [0,        H],
];

// inner cavity profile (subtracted) — leaves wall + floor
inner_pts = [
    [0,           floor_t],
    [R - 9 - wall, floor_t + 2],
    [R - wall,     18],
    [R - 2 - wall, 30],
    [R - 6 - wall, H + eps],
    [0,            H + eps],
];

module body() {
    difference() {
        rotate_extrude() polygon(outer_pts);
        rotate_extrude() polygon(inner_pts);
        // cigarette-rest notches: horizontal grooves across the rim
        for (i = [0 : notches - 1])
            rotate([0, 0, notch_ang + i * 360 / notches])
                translate([R - 6, 0, H])
                    rotate([0, 90, 0])
                        cylinder(h = 20, r = notch_r, center = true);
    }
}

// wrap one glyph around the barrel, facing outward
module glyph(ch, a, r) {
    rotate([0, 0, a])
        translate([r, 0, text_z])
            rotate([90, 0, 90])
                mirror([text_mirror, 0, 0])
                    linear_extrude(height = text_emb + 1)
                        text(ch, size = text_size, font = text_font,
                             halign = "center", valign = "center");
}

module side_text() {
    n = len(text_str);
    // radius of the barrel at the text height (approx the max bulge)
    r = R - 1.2;
    step = (n > 1) ? text_arc / (n - 1) : 0;
    start = text_face - text_dir * text_arc / 2;
    for (i = [0 : n - 1])
        glyph(text_str[i], start + text_dir * i * step, r);
}

// raised text trimmed to a thin shell that hugs the curved surface
module text_shell() {
    intersection() {
        side_text();
        difference() {
            rotate_extrude() polygon(outer_pts_off(text_emb));
            rotate_extrude() polygon(outer_pts);
        }
    }
}

module ashtray() {
    if (part == "body")      body();
    else if (part == "text") text_shell();
    else if (do_text)        union() { body(); text_shell(); }
    else                     body();
}

// outer profile expanded outward by d (for the text shell)
function outer_pts_off(d) = [
    [0,        0],
    [R - 9 + d, 0],
    [R - 3 + d, 6],
    [R + d,     18],
    [R - 2 + d, 30],
    [R - 6 + d, H],
    [0,         H],
];

ashtray();
