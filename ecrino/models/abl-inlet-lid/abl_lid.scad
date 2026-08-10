// Replacement hinged flap (lid) for ABL-Sursum 1154-210 flush-mount 16 A caravan inlet.
// Original spare part: ABL art. E154200 (Klappdeckel, series 1154).
//
// Reference data (from the ABL / Eurotech product data):
//   flange (front plate) 115 h x 105 w x 95 d
//   wall cut out          90 h x  80 w x 80 d
// The lid itself is NOT dimensioned in any public datasheet, so everything below
// is parametric. Measure the original and adjust the five values marked MEASURE.

// ---------------------------------------------------------------- parameters
lid_w      = 100;   // MEASURE lid width  (across, parallel to hinge)
lid_h      =  96;   // MEASURE lid height (top edge to bottom edge)
lid_t      =   3.0; // MEASURE plate thickness
corner_r   =   6;   // corner radius

pin_d      =   3.2; // MEASURE hinge pin diameter + 0.2 clearance
knuckle_n  =   2;   // number of hinge knuckles
knuckle_w  =  14;   // width of one knuckle
knuckle_cc =  65;   // MEASURE centre-to-centre spacing of the hinge knuckles
knuckle_t  =   7;   // knuckle boss thickness (grows outward -> prints flat)
pin_up     =   4;   // pin axis above the plate top edge

ribs_n     =   4;   // decorative/stiffening ribs, as on the original
rib_len    =  70;
rib_w      =   6;
rib_h      =   1.6;
rib_pitch  =  11;
rib_y0     =  14;   // first rib, measured down from the top edge

tab_w      =  18;   // finger tab on the bottom edge
tab_out    =   6;

lip        =   0;   // 1 = add inner sealing lip, 0 = plain plate (prints flat, no support)
lip_in     =   5;   // lip inset from the outline
lip_w      =   2;
lip_h      =   2;

$fn = 64;
eps = 0.05;

// ---------------------------------------------------------------- helpers
module rrect(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h], center = true);
}

module plate() {
    linear_extrude(lid_t) rrect(lid_w, lid_h, corner_r);
}

// ribs run across the width, rounded like the moulded original
module ribs() {
    for (i = [0 : ribs_n - 1])
        translate([0, lid_h/2 - rib_y0 - i * rib_pitch, lid_t - eps])
            hull() {
                translate([-rib_len/2 + rib_w/2, 0, 0])
                    cylinder(r = rib_w/2, h = rib_h);
                translate([ rib_len/2 - rib_w/2, 0, 0])
                    cylinder(r = rib_w/2, h = rib_h);
            }
}

// hinge knuckles: tabs on the top edge with the pin hole lying in the plate
// plane, so the whole part prints flat with no support
module knuckles() {
    for (i = [0 : knuckle_n - 1]) {
        x = -knuckle_cc/2 + i * (knuckle_cc / max(1, knuckle_n - 1));
        translate([x, 0, 0]) difference() {
            hull() {
                translate([-knuckle_w/2, lid_h/2 - 6, 0])
                    cube([knuckle_w, 6, knuckle_t]);
                translate([0, lid_h/2 + pin_up, knuckle_t/2])
                    rotate([0, 90, 0])
                        cylinder(r = knuckle_t/2, h = knuckle_w, center = true);
            }
            // pin bore
            translate([0, lid_h/2 + pin_up, knuckle_t/2])
                rotate([0, 90, 0])
                    cylinder(d = pin_d, h = knuckle_w + 2, center = true);
        }
    }
}

module tab() {
    hull() {
        translate([-tab_w/2, -lid_h/2, 0]) cube([tab_w, 2, lid_t]);
        translate([-tab_w/2 + 2, -lid_h/2 - tab_out, 0])
            cube([tab_w - 4, 2, lid_t * 0.7]);
    }
}

module sealing_lip() {
    linear_extrude(lip_h)
        difference() {
            offset(r = -lip_in)          rrect(lid_w, lid_h, corner_r);
            offset(r = -lip_in - lip_w)  rrect(lid_w, lid_h, corner_r);
        }
}

// ---------------------------------------------------------------- assembly
module abl_lid() {
    union() {
        plate();
        ribs();
        knuckles();
        tab();
        if (lip) translate([0, 0, -lip_h + eps]) sealing_lip();
    }
}

abl_lid();
