// ============================================================
// Y7 — Fluted sauce ramekin / dip bowl
// Modelled from reference photos: tapered round bowl with vertical
// flutes, a rolled/flared rim and a recessed foot. Units: millimetres.
// Prints upright, no supports (wall leans out only ~15 deg).
//
// NOTE: for food contact use a food-safe filament + food-safe finish,
// or treat as decorative. PETG/PLA fine for a display/print test.
// ============================================================

// ---- overall shape ----
R_bot   = 31;    // outer radius at the bottom (valley of the flutes)
R_top   = 43;    // outer radius at the top
H       = 44;    // wall height (up to the rim)
wall    = 2.6;   // wall thickness
floor_t = 3.4;   // floor thickness

// ---- flutes ----
ribs    = 30;    // number of vertical ribs
amp     = 1.6;   // how far the ribs stand out

// ---- rim ----
rim_r   = 2.7;   // rolled lip radius
rim_out = 3.0;   // how far the lip flares past the wall (covers the flute tips)

// ---- foot ----
foot_recess = 1.6;   // depth of the underside recess
foot_ring   = 4.0;   // width of the standing foot ring

eps = 0.02;
$fn = 180;

scale_up = R_top / R_bot;                 // wall widens toward the top
scale_in = (R_top - wall) / (R_bot - wall);

// rounded fluted 2D cross-section (base = bottom of the bowl)
module fluted2D(R) {
    step = 0.5;
    pts = [ for (a = [0 : step : 360 - step])
                let (rr = R + amp * pow(0.5 + 0.5 * cos(ribs * a), 1.6))
                    [rr * cos(a), rr * sin(a)] ];
    polygon(pts);
}

module ramekin() {
    difference() {
        union() {
            // fluted, tapered outer body
            linear_extrude(height = H, scale = scale_up) fluted2D(R_bot);
            // rolled rim lip
            translate([0, 0, H])
                rotate_extrude() translate([R_top + rim_out - rim_r, 0]) circle(r = rim_r);
        }
        // smooth tapered inner cavity (open top)
        translate([0, 0, floor_t])
            linear_extrude(height = H + rim_r + 6, scale = scale_in)
                circle(r = R_bot - wall);
        // recessed underside -> leaves a standing foot ring
        translate([0, 0, -eps])
            cylinder(r1 = R_bot - foot_ring, r2 = R_bot - foot_ring - 1.5,
                     h = foot_recess + eps);
    }
}

ramekin();
