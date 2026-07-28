// ============================================================
// Y7 — Cup-holder insert for Mercedes S-Class W221 (2010)
// A drop-in organizer / cup insert: it sits in the center-console
// cup-holder well, held by a flared flange resting on the rim, with
// soft grip ribs on the outside. Units: millimetres.
//
// !!! MEASURE YOUR CAR TO LOCK THE FIT !!!
// Mercedes does not publish cup-holder dimensions and the W221 holder
// is an adjustable spring-arm unit, so the two numbers below are an
// ESTIMATE. Measure the round opening ⌀ and the depth, set `hold_d`
// and `hold_depth`, and re-export. The model does the rest.
// ============================================================

// ---- MEASURED FIT (edit these two) ----
hold_d     = 74;   // opening diameter of the car cup-holder well
hold_depth = 60;   // usable depth of the well

// ---- fit / build ----
fit_clear = 0.8;   // total diametral clearance so it drops in easily
taper     = 3.0;   // radius reduction from top to bottom (easy insert)
wall      = 2.2;
floor_t   = 2.8;
sink      = 6;     // how far below the well depth the floor sits (leave room)

// ---- grip ribs (soft, hold it centred by friction) ----
ribs = 24;
amp  = 0.7;

// ---- resting flange (flared collar on the rim) ----
flange_w    = 9;    // how far it overhangs the rim
flange_drop = 10;   // cone height of the flange underside (printable slope)

// ---- finger notch (reach in / pull it out) ----
notch = true;
notch_w = 26;
notch_h = 20;

eps = 0.02;
$fn = 160;

top_R  = (hold_d - fit_clear) / 2;
bot_R  = top_R - taper;
depth  = min(hold_depth - sink, 54);
ztop   = depth;

in_top_R = top_R - wall;
in_bot_R = bot_R - wall;
scale_up = top_R / bot_R;
scale_in = in_top_R / in_bot_R;
flange_R = top_R + flange_w;

module fluted2D(R) {
    step = 0.6;
    pts = [ for (a = [0 : step : 360 - step])
                let (rr = R + amp * pow(0.5 + 0.5 * cos(ribs * a), 1.6))
                    [rr * cos(a), rr * sin(a)] ];
    polygon(pts);
}

module flange() {
    rotate_extrude()
        polygon([
            [top_R - 0.1, ztop - flange_drop],
            [flange_R,    ztop - 1.5],
            [flange_R,    ztop],
            [top_R - 0.1, ztop]
        ]);
}

module insert() {
    difference() {
        union() {
            linear_extrude(height = ztop, scale = scale_up) fluted2D(bot_R);
            flange();
        }
        // inner cavity (open top), keep the floor
        translate([0, 0, floor_t])
            linear_extrude(height = ztop + 5, scale = scale_in) circle(r = in_bot_R);
        // finger notch through the flange + top wall
        if (notch)
            translate([flange_R, 0, ztop - notch_h])
                rotate([0, 0, 0])
                    cylinder(h = notch_h + eps, r = notch_w / 2);
    }
}

insert();
