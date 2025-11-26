// ============================
// PARAMETRI
// ============================
points = 5;                  // broj glavnih krakova (fiksno)
main_len = 40;               // duljina glavne grane
main_thick = 4;              // debljina glavne grane
height_3d = 3;               // stvarna debljina pahuljice u Z

rows = 2;                    // broj redova podgrana

// parametri podgrana po redu
sub_lengths = [15,10];       // duljina podgrana
sub_angles = [35,25];        // kut podgrana
sub_thicks = [3,2];          // debljina podgrana

// offseti prvog i drugog reda (0..1, precizno po 0.01)
sub_offset1 = 0.31;  
sub_offset2 = 0.68;  

// parametri malih podgrana prvog reda
inner_sub_count = 2;         // broj malih podgrana po podgrani prvog reda
inner_sub_length = 6;        // duljina malih podgrana
inner_sub_angle = 30;        // kut malih podgrana
inner_sub_thick = 2;         // debljina malih podgrana

// polumjer zaobljenja vrhova
cap_radius = 2;

// ============================
// MODULI
// ============================
module line2d_rounded(len, thick) {
    union() {
        translate([0,-thick/2])
            square([len, thick]);
        translate([len,0])
            rotate([0,0,90])
                circle(r=thick/2);
    }
}

module inner_subs() {
    for(i=[-floor(inner_sub_count/2):floor(inner_sub_count/2)]) {
        if(i != 0) {
            rot = i * inner_sub_angle / max(1, floor(inner_sub_count/2));
            rotate([0,0,rot])
                line2d_rounded(inner_sub_length, inner_sub_thick);
        }
    }
}

module first_row_subbranch(len, thick, angle) {
    rotate([0,0,angle]) {
        line2d_rounded(len, thick);
        translate([len/2,0]) inner_subs();
    }
}

module subbranch(len, thick, angle) {
    rotate([0,0,angle])
        line2d_rounded(len, thick);
}

module branch2d() {
    union() {
        line2d_rounded(main_len, main_thick);

        for(row=[0:rows-1]) {
            if(row==0) {
                translate([main_len*sub_offset1,0])
                    first_row_subbranch(sub_lengths[row], sub_thicks[row], sub_angles[row]);
                translate([main_len*sub_offset1,0])
                    first_row_subbranch(sub_lengths[row], sub_thicks[row], -sub_angles[row]);
            } else {
                translate([main_len*sub_offset2,0])
                    subbranch(sub_lengths[row], sub_thicks[row], sub_angles[row]);
                translate([main_len*sub_offset2,0])
                    subbranch(sub_lengths[row], sub_thicks[row], -sub_angles[row]);
            }
        }
    }
}

// ============================
// 3D Pahuljica
// ============================
linear_extrude(height=height_3d, center=true) {
    union() {
        for(i=[0:points-1])
            rotate(i*360/points)
                branch2d();
    }
}
