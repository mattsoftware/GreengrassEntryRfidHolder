
$fn = 60;
print = true;

beam_depth = 47.5;
corner_a = 8.5;
corner_b = 3.5;

wall_width = 3;
clearance = 0.5;
glass_clearance = 2;
rfid_clearance = 3.5 + 5;
mount_offset = 15;
overall_height = 60 + 30; // must be bigger than the rfid_length plus extra for cable
rivit_hole = 3.5;
rail_height = 20; // must be less than the h_height
cover_rail_offset = wall_width * 2;

rfid_width = 39.5;
rfid_length = 60;
rfid_depth = 1.12;
rfid_hole = 3;
rfid_holes = [
    [rfid_width/2 + 25.5/2, 6.7],
    [rfid_width/2 - 25.5/2, 6.7],
    [rfid_width/2 + 34/2, 44.4],
    [rfid_width/2 - 34/2, 44.4]
];
rfid_pin_hole = 0.9;
rfid_pin_count = 7;
rfid_pin_xy = [10,0.7];
rfid_pin_pitch = 2.54;
rfid_cap_offset = 9.9 + 2.7;

module wall () {
    height = 400;
    thick = beam_depth/2;
    length = 400;
    wthick = 5;
    translate([-thick,-beam_depth,-height/2]) cube([thick, beam_depth, height]);
    translate([-length/2,0,-height/2]) cube([length,wthick,height]);
    translate([0,0,-height/2]) resize([corner_b,0,0]) cylinder(r = corner_a, h = height);
}

module rfid (cutout = false) {
    width = rfid_width;
    depth = rfid_depth + (cutout ? clearance*2 : 0);
    length = rfid_length;
    difference() {
        union() {
            cube([width,depth,length], center=true);
            cap_height = 3.5;
            cap_width = 3.5;
            cap_length = 9.9;
            translate([-cap_width/2+width/2,-cap_height/2-depth/2,cap_length/2+length/2-rfid_cap_offset]) {
                cube([cap_width,cap_height,cap_length], center=true);
            }
        }
        if (!cutout) {
            translate([-width/2,0,-length/2]) {
                for (h = rfid_holes) {
                    translate([h[0],0,h[1]]) rotate([90,0,0]) cylinder(d = rfid_hole, h=depth + 0.02, center=true);
                }
            }
            translate([-width/2+rfid_pin_xy[0]+rfid_pin_pitch/2,0,length/2-rfid_pin_xy[1]-rfid_pin_pitch/2]) {
                for (p = [0 : 1 : rfid_pin_count]) {
                    translate([p * rfid_pin_pitch,0,0]) rotate([90,0,0]) cylinder(d = rfid_pin_hole, h=depth + 0.02, center=true);
                }
            }
        }
    }
}

h_width = rfid_width + wall_width * 2 + clearance * 2;
h_height = rfid_length - rfid_cap_offset - clearance + wall_width;
h_depth = glass_clearance + rfid_depth + rfid_clearance + clearance * 2 + wall_width;
module holder(side = -1) {
    // holder
    difference() {
        union() {
            cube([h_width,h_depth,h_height], center=true);
        }
        translate([0,0,wall_width+0.01]) cube([h_width-wall_width*4,h_depth+0.02,h_height-wall_width*2+0.01], center=true);
        translate([0,h_depth/2-rfid_depth/2-glass_clearance-clearance,rfid_length/2-h_height/2+wall_width]) rfid(true);
    }

    // Mounting bracket
    spacer_width = mount_offset-wall_width;
    spacer_length = h_depth + spacer_width;
    translate([(h_width/2-wall_width/2+mount_offset)*side,-beam_depth/2+h_depth/2,overall_height/2-h_height/2]) {
        difference() {
            union() {
                cube([wall_width,beam_depth,overall_height], center=true);
                translate([(-spacer_width/2-wall_width/2)*side,beam_depth/2-spacer_length/2,0]) cube([spacer_width,spacer_length,overall_height], center=true);
            }
            translate([(-spacer_width-wall_width/2)*side,beam_depth/2-spacer_length,0]) cylinder(r = spacer_width, h=overall_height+0.02, center=true);
            translate([(-mount_offset/2+wall_width/2)*side,+beam_depth/2-h_depth/2+wall_width/2,h_height/2]) {
                cube([mount_offset+0.02,h_depth+0.01-wall_width,overall_height-h_height+0.01], center=true);
            }
            for (i = [-overall_height/3, overall_height/3]) {
                translate([0,-beam_depth/4,i]) rotate([0,90,0]) cylinder(d = rivit_hole, center=true, h=wall_width+0.02);
            }

            // Create a space for the corner tube
            c_a = corner_a + clearance;
            c_b = corner_b + clearance;
            translate([wall_width/2*side,beam_depth/2,0]) resize([c_b,0,0]) cylinder(d = c_a, h=overall_height + 0.02, center=true);
        }
        // T rail to guide the cover
        translate([-wall_width/2+cover_rail_offset,h_width/2-h_depth,-h_height/2-rail_height/2+h_height]) rotate(-90) {
            rail(wall_width, rail_height, 90, 0);
            rail(wall_width, rail_height, -90, 0);
        }
    }
}

module rail(size, height, rotation, clearance) {
    hull() {
        cylinder(d=size/2+clearance, h=height, center = true);
        translate([-size,0,0]) cylinder(d=size/2+clearance, h=height, center = true);
    }
    hull () {
        translate([-size,0,0]) cylinder(d=size/2+clearance, h=height, center = true);
        translate([-size,0,0]) rotate(rotation) translate([-size/2,0,0]) cylinder(d=size/2+clearance, h=height, center = true);
    }
}

c_height = overall_height;
c_width = h_width + mount_offset+wall_width;
c_depth = h_depth;
module cover(cutout = false, side = -1) {
    width = c_width;
    height = c_height;
    depth = c_depth;
    translate([-wall_width/2*side,0,0]) {
        difference() {
            cube([width+(cutout?clearance:0),depth+(cutout?clearance:0),height+(cutout?clearance:0)], center=true);
            translate([wall_width*2*side,wall_width/2+(cutout?clearance:0),-wall_width/2-5]) cube([width,depth-wall_width+1,height-wall_width+10], center=true);
            translate([wall_width*side,wall_width,-height+h_height]) cube([width,depth,height], center=true);
            translate([(width/2-mount_offset/2)*side,-depth/2+wall_width/2,-height/2+h_height/2-0.01]) cube([mount_offset+1,wall_width+2,h_height+0.01], center=true);
        }
    }
    // rails
    //translate([(c_width/2-mount_offset/2-wall_width/2)*side,-c_depth/2+wall_width,-c_height/2+wall_width/2+h_height]) cube([mount_offset,wall_width*2,wall_width], center=true);
    translate([0,0,-height/2-rail_height/2+h_height]) {
        translate ([(width/2-mount_offset-wall_width/2)*side,-depth/2+wall_width-wall_width/4,0.01]) {
            rotate(side == 1 ? 180 : 0) rail(wall_width, rail_height, 90*side, cutout ? clearance : 0);
        }
        translate ([(-c_width/2+wall_width/2)*side,c_depth/2-wall_width/4-wall_width*2,0.01]) {
            rotate(side == 1 ? 180 : 0) rail(wall_width, rail_height, 270*side, cutout ? clearance : 0);
        }
    }
}

if (!print) {
    //%translate([(mount_offset+beam_depth/2)*side,0,0]) wall();
    %translate([0,0,-overall_height/2+rfid_length/2+wall_width]) rfid();
}

side = -1;
difference() {
    translate([0,0,h_height/2-overall_height/2]) holder(side);
    translate([mount_offset/2*side,0,0]) cover(true, side);

}
translate([(-c_width/2+h_width/2+mount_offset+wall_width/2)*side,(print ? 30 : 0),0]) {
    rotate ([print ? 180 : 0,0,0]) cover(false, side);
}

