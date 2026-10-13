// Preview only: exploded view of the enclosure parts.
use <enclosure.scad>

color("gray25")   base();
color("silver")   translate([0, 0, 55]) plate();
color("darkred")  translate([0, 0, 150]) gasket();
color("gray40")   translate([0, 0, 235]) rotate([180, 0, 0]) lid();
