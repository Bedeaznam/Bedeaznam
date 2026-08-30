// ============================================================
// Y7 — Phone / tablet stand (tuned for PETG HS)
// Sturdy angled cradle, cable pass-through, no supports.
// Units: millimetres.
// ============================================================

base_w   = 90;    // width
base_d   = 80;    // depth (front-back)
thick    = 6;     // material thickness of the plates
angle    = 62;    // recline angle of the back rest (deg from bed)
back_h   = 95;    // back rest height along its slope
lip_h    = 22;    // front lip that holds the phone
slot_w   = 40;    // cable slot width in the lip
$fn      = 64;
eps      = 0.05;

module rounded_plate(w, d, t, r = 6) {
    hull() for (x = [r-w/2, w/2-r], y = [r-d/2, d/2-r])
        translate([x, y, 0]) cylinder(h = t, r = r);
}

module phone_stand() {
    difference() {
        union() {
            // base
            translate([0, 0, 0]) rounded_plate(base_w, base_d, thick);
            // front lip (holds phone bottom edge)
            translate([0, -base_d/2 + thick/2, 0])
                rounded_plate(base_w, thick, lip_h, r = thick/2);
            // angled back rest
            translate([0, base_d/2 - thick, 0])
                rotate([90 - angle, 0, 0])
                    rounded_plate(base_w, thick, back_h, r = thick/2);
            // side gussets for rigidity
            for (s = [-1, 1])
                translate([s*(base_w/2 - thick/2), 0, 0])
                    rotate([0, 0, 0])
                        linear_extrude(height = thick)
                            polygon([[-2,-base_d/2+8],[2,-base_d/2+8],[2, base_d/2-4]]);
        }
        // cable pass-through slot in the front lip
        translate([0, -base_d/2 + thick/2, -eps])
            hull() {
                translate([-slot_w/2 + 6, 0, 0]) cylinder(h = lip_h*0.6, r = 6);
                translate([ slot_w/2 - 6, 0, 0]) cylinder(h = lip_h*0.6, r = 6);
            }
    }
}

phone_stand();
