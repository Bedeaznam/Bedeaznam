// ============================================================
// Y7 — Faceted outdoor planter (tuned for ASA, UV/weather resistant)
// Low-poly geometric pot with drainage holes. Print flat, no supports
// (or vase mode). Units: millimetres.
// ============================================================

top_d    = 110;   // top outer diameter
bot_d    = 78;    // bottom outer diameter
H        = 100;   // height
wall     = 3.0;   // wall thickness
floor_t  = 4.0;   // floor thickness
facets   = 7;     // number of vertical facets (heptagon look)
drain_n  = 5;     // drainage holes in the floor
drain_r  = 5;     // drainage hole radius
$fn_hole = 32;
eps      = 0.05;

module faceted_solid(dtop, dbot, h) {
    // prism with `facets` sides, tapered
    cylinder(h = h, r1 = dbot/2, r2 = dtop/2, $fn = facets);
}

module planter() {
    difference() {
        // outer faceted body
        faceted_solid(top_d, bot_d, H);
        // hollow interior (leaves floor + wall)
        translate([0, 0, floor_t])
            faceted_solid(top_d - 2*wall, bot_d - 2*wall, H);
        // drainage holes in the floor
        for (i = [0 : drain_n - 1])
            rotate([0, 0, i * 360 / drain_n])
                translate([bot_d/2 - wall - drain_r - 4, 0, -eps])
                    cylinder(h = floor_t + 2*eps, r = drain_r, $fn = $fn_hole);
        // center drain hole
        translate([0, 0, -eps]) cylinder(h = floor_t + 2*eps, r = drain_r, $fn = $fn_hole);
    }
}

planter();
