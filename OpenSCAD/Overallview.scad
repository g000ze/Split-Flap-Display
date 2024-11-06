include<3D_library.scad>;

cols = 10; 
rows = 5; 

for(col=[0:1:cols-1])
{
    for(row=[0:1:rows-1])
    {
        // this translate shifts the objects in rows and cols
        translate([((flap_width + (2 * flap_pin) + h_space_between_flaps) * col), -((flap_height + v_space_between_flaps) * (row * 2))])
        {
            rotate([0, 0, 90])   flap_with_char(((cols * row) + col) + 2);
        }
        translate([((flap_width + (2 * flap_pin) + h_space_between_flaps) * col), -((flap_height + v_space_between_flaps) * (row * 2) + (flap_height + 1))])
        {
            rotate([0, 180, 90]) flap_with_char(((cols * row) + col) + 1);
        }
    }
}
