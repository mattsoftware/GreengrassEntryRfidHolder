
$fn = 60;
print = true;
show = true;
explode = true;

depth = 47.5;
corner = 8.5;
hole = 4;
holes = [
    [9.46, 0],
    [36.58, -2]
];
glass_clearance = 2;
front_clearance = 1;
wall_width = 3;
support_height = 43;
support_clearance = 1;
inner_support_r = 10;
top_clearance = 5;
slots = 30;
slot_clearance = 0.5;

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

s_width = rfid_width + wall_width*2 + support_clearance + corner;
s_height = support_height + wall_width;
s_thick = glass_clearance + rfid_depth + support_clearance + front_clearance + wall_width;
module card_support() {
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
                translate([s_width-inner_support_r-wall_width,-inner_support_r-wall_width,0]) cube([inner_support_r,inner_support_r+wall_width,s_height]);
            }
            translate([s_width-wall_width-inner_support_r,-inner_support_r-wall_width,-0.01]) cylinder(r = inner_support_r, h = s_height+0.02);
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
            translate([s_width,s_thick,0])  cover(true);
        }
    }
}

c_width = rfid_width + wall_width*3 + support_clearance;
t_height = rfid_length - s_height + wall_width * 2 + top_clearance;
c_clearance = 1;
c_height = t_height + s_height;
c_offset = wall_width+inner_support_r;
module cover (cutout = false) {
    slot_height = cutout ? slots + 5 : slots;
    slot_width = wall_width;
    translate([-s_width-wall_width,-s_thick-wall_width,0]) {
        difference() {
            cube([c_width,s_thick+wall_width,c_height]);
            translate([wall_width*2,wall_width+0.01,-0.01+s_height]) cube([c_width - wall_width*3, s_thick+0.01, t_height-wall_width+0.01]);
            translate([wall_width+0.01,wall_width+0.01,-0.01]) cube([c_width - wall_width+0.01, s_thick+0.01, c_height-t_height+0.01]);
            translate([c_width+corner-c_offset,-0.01,-0.01]) cube([c_offset,wall_width+0.03,s_height+0.01]);
        }
        translate([c_width+corner-c_offset,wall_width/4,c_height-t_height-slot_height+0.01]) {
            translate([0,(cutout ? -slot_clearance/2 : 0),0]) cube([slot_width+(cutout ? slot_clearance/2 : 0),slot_width/2+slot_clearance,slot_height]);
            translate([slot_width/2-(cutout ? slot_clearance/2 : 0),(cutout ? -slot_clearance/2 : 0),0]) cube([slot_width/2+(cutout ? slot_clearance : 0),slot_width+(cutout ? slot_clearance : 0),slot_height]);
        }
        translate([wall_width,s_thick+wall_width-wall_width/4-s_thick/2,c_height-t_height-slot_height+0.01]) {
            translate([0,(cutout ? -slot_clearance/2 : 0),0]) cube([slot_width/2+slot_clearance,slot_width/2+(cutout ? slot_clearance: 0),slot_height]);
            //translate([slot_width/2,-slot_width+slot_width/4,0]) cube([slot_width/2,slot_width*2,slot_height]);
        }
    }
}

if (!print && show) %wall();
card_support();
ct = print ? [0,-depth/2-s_thick,c_height] : (explode ? [0,0,60] : [0,0,0]);
cr = print ? [180,0,0] : 0;
translate(ct) rotate(cr) cover();
if (!print) %translate([-rfid_width-wall_width-support_clearance/2-corner,-glass_clearance-support_clearance/2,wall_width]) rfid();

