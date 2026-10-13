// ============================================================
// Y7 — Cup-holder insert for Mercedes S-Class W221 (2010)
// Modelled to match the user's own part: a fluted (ribbed) tapered
// bowl with a rolled top rim that rests on the cup-holder opening.
// It drops into the center-console well and holds a cup / bits.
// Units: millimetres. Prints upright, no supports.
//
// !!! MEASURE YOUR CAR TO LOCK THE FIT !!!
// Mercedes does not publish cup-holder dimensions and the W221 holder
// has adjustable spring arms, so `hold_d`/`hold_depth` are an ESTIMATE.
// Measure the round opening ⌀ and the depth, set the two numbers below
// and re-export.
// ============================================================

// ---- MEASURED FIT (edit these two) ----
hold_d     = 74;   // opening diameter of the car cup-holder well
hold_depth = 60;   // usable depth of the well

// ---- fit / build ----
fit_clear = 1.0;   // total diametral clearance so it drops in easily
taper     = 8.0;   // radius reduction from top to bottom (bowl taper)
wall      = 2.4;
floor_t   = 3.2;
sink      = 2;     // gap left under the floor vs. the well depth

// ---- flutes (vertical ribs, like the photo) ----
ribs = 34;
amp  = 1.2;

// ---- rolled top rim (rests on the well opening) ----
rim_r   = 2.2;     // rolled lip radius
rim_out = 3.0;     // how far the lip flares past the wall (sits on the rim)

// ---- foot ----
foot_recess = 1.4; // underside recess -> a clean standing foot ring
foot_ring   = 4.0;

eps = 0.02;
$fn = 200;

top_R  = (hold_d - fit_clear) / 2;      // outer radius just below the rim
bot_R  = top_R - taper;                 // narrower bottom (tapered bowl)
H      = min(hold_depth - sink, 58);    // body height

scale_up = top_R / bot_R;                       // widens toward the top
scale_in = (top_R - wall) / (bot_R - wall);     // inner cavity taper

module fluted2D(R) {
    step = 0.5;
    pts = [ for (a = [0 : step : 360 - step])
                let (rr = R + amp * pow(0.5 + 0.5 * cos(ribs * a), 1.6))
                    [rr * cos(a), rr * sin(a)] ];
    polygon(pts);
}

module bowl() {
    difference() {
        union() {
            // fluted, tapered outer body
            linear_extrude(height = H, scale = scale_up) fluted2D(bot_R);
            // rolled rim lip that rests on the cup-holder opening
            translate([0, 0, H])
                rotate_extrude() translate([top_R + rim_out - rim_r, 0]) circle(r = rim_r);
        }
        // smooth tapered inner cavity (open top), keep the floor
        translate([0, 0, floor_t])
            linear_extrude(height = H + rim_r + 6, scale = scale_in)
                circle(r = bot_R - wall);
        // recessed underside -> standing foot ring
        translate([0, 0, -eps])
            cylinder(r1 = bot_R - foot_ring, r2 = bot_R - foot_ring - 1.5,
                     h = foot_recess + eps);
    }
}

bowl();
