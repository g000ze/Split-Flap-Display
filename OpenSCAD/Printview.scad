include<2D_library.scad>;

// 1 - 5 or 6 - 10
//start_row = 1;
//end_row = 10;
// front or back

zoom = 10;


// es fehlen noch die indicators sowie
// start und end row zeugs

side = "front";


// dieses render() hilft gegen die Fehlermeldung
// Normalized tree is growing past 200000 elements. Aborting normalization
render() difference()
{
    draw_foil();
    // two translates, for better understanding:
    // 1) move by half flap in width and height, due to center = true
    // 2) move to center of foil
    translate([(flap_width / 2) + flap_pin, -(flap_height/2)])
    {
        translate([-total_width_flaps/2, total_height_flaps/2])
        {
            draw_cols_and_rows();
        }
    }

    draw_indicators();
}
