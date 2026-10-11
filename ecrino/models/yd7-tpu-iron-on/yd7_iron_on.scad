// YD7 iron-on TPU logo for T-shirts / hoodies.
// Print flat in TPU, then iron onto fabric through baking paper.
include <yd7_outline.scad>

width     = 90;    // logo width, mm (chest logo ~80-100, back print ~200-250)
thickness = 0.8;   // total height, mm (4 layers @ 0.2); thinner = softer on fabric
mirrored  = false; // true if you place the top side of the print against the fabric

module logo2d()
    mirror([mirrored ? 1 : 0, 0, 0])
        translate([mirrored ? -width : 0, 0])
            scale([width, width]) yd7_outline();

linear_extrude(height = thickness) logo2d();
