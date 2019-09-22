
$fn = 60;

depth = 47.5;
corner = 8.5;
hole = 4;
holes = [
    [9.46, 0],
    [36.58, -2]
];
glass_clearance = 2;
front_clearance = 2;
wall_width = 3;
support_height = 43;
support_clearance = 1;
inner_support_r = 10;

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

module wall () {
    height = 400;
    thick = depth/2;
    length = 400;
    wthick = 5;
    difference() {
        union() {
            translate([0,-depth,-height/2]) cube([thick, depth, height]);
            translate([-length/2,0,-height/2]) cube([length,wthick,height]);
            translate([0,0,-height/2]) cylinder(r = corner, h = height);
        }
        translate([0,-holes[0][0],holes[0][1]]) rotate([0, 90, 0]) cylinder(d = hole, h = 5, center = true);
        translate([0,-holes[1][0],holes[1][1]]) rotate([0, 90, 0]) cylinder(d = hole, h = 5, center = true);
    }
}

module rfid () {
    difference() {
        union() {
            translate ([0,-rfid_depth,0]) cube([rfid_width,rfid_depth,rfid_length]);
            translate([rfid_width-3.5,-3.5-rfid_depth,rfid_length-9.9-2.7]) cube([3.5,3.5,9.9]);
        }
        for (h = rfid_holes) {
            translate([h[0],0.01,h[1]]) rotate([90,0,0]) cylinder(d = rfid_hole, h=rfid_depth + 0.02);
        }

        translate([rfid_pin_xy[0]+rfid_pin_pitch/2,0,rfid_length-rfid_pin_xy[1]-rfid_pin_pitch/2]) {
            for (p = [0 : 1 : rfid_pin_count]) {
                translate([p * rfid_pin_pitch,0.01,0]) rotate([90,0,0]) cylinder(d = rfid_pin_hole, h=rfid_depth + 0.02);
            }
        }
    }
}

module card_support() {
    s_width = rfid_width + wall_width*2 + support_clearance + corner;
    s_height = support_height + wall_width;
    s_thick = glass_clearance + rfid_depth + support_clearance + front_clearance + wall_width;
    translate([-s_width,-s_thick,0]) {
        difference() {
            union() {
                cube([s_width,s_thick,s_height]);
                translate([s_width-wall_width,s_thick-depth+wall_width+1,0]) cube([wall_width,depth-wall_width-1,s_height]);
                translate([s_width,s_thick-depth+wall_width+1,0]) {
                    difference() {
                        cylinder(r=wall_width, h=s_height);
                        translate([0,-wall_width+0.01,-0.01]) cube([wall_width+0.01,wall_width*2+0.02,s_height+0.02]);
                    }
                }
                translate([s_width-inner_support_r-wall_width,-inner_support_r,0]) cube([inner_support_r,inner_support_r,s_height]);
            }
            translate([s_width-wall_width-inner_support_r,-inner_support_r,-0.01]) cylinder(r = inner_support_r, h = s_height+0.02);
            translate([
                wall_width,
                s_thick-rfid_depth-support_clearance-glass_clearance,
                wall_width
            ]) {
                cube([rfid_width+support_clearance,rfid_depth + support_clearance,s_height]);
                translate([wall_width,-front_clearance-wall_width-0.01,wall_width]) {
                    cube([
                        rfid_width+support_clearance-wall_width*2,
                        s_thick+0.02,
                        s_height
                    ]);
                }
            }
            translate([s_width,s_thick,-0.01]) cylinder(r = corner, h = s_height+0.02);
        }
    }
}

module part() {

    // build some rails so the part will slide in
    card_support();

    %translate([-rfid_width-wall_width-support_clearance/2-corner,-glass_clearance,wall_width]) rfid();
}


%wall();
part();

