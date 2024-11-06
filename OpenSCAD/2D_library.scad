include<../settings.scad>;

// Das ist die totale Breite sämtlicher Flaps inkl. Nasen & Abstände
total_width_flaps = (cols * (flap_width + (2 * flap_pin))) + (cols - 1) * h_space_between_flaps;
// Das ist die totale Höhe sämtlicher Flaps inkl. Abstände
total_height_flaps = (rows * flap_height)                  + (rows - 1) * v_space_between_flaps;


module draw_base_flap()
{
    square([flap_width, flap_height], center = true);
}

module draw_flap()
{
    draw_base_flap();
    draw_pins();
}

module draw_flap_outline()
{
    difference()
    {
        offset(delta = +outline_weight) draw_flap();
        draw_flap();
    }
}

module draw_pins()
{
    translate([ ((flap_width/2) + (flap_pin/2)), -((flap_height/2) - (flap_pin/2))])
    {
        square([flap_pin,flap_pin], center = true);
    }
    translate([-((flap_width/2) + (flap_pin/2)), -((flap_height/2) - (flap_pin/2))]) 
    {
        square([flap_pin,flap_pin], center = true);
    }
}

module draw_pins_outline()
{
    difference()
    {
        offset(delta = +outline_weight) draw_pins();
        draw_pins();
        // lets make the inner line disapear with an additional square
        translate([0, -((flap_height/2) - (flap_pin/2))]) square([flap_width, flap_pin + (outline_weight * 2)], center = true);
    }
}

module draw_foil()
{
    square([foil_width, foil_height], center = true);
}

module draw_indicator_cross()
{
    square([width_marker, length_marker], center = true);
    square([length_marker, width_marker], center = true);
}

module draw_indicators(){
    // Indicators for CAD initialisation
    h_pos = (foil_width  / 2) - indicator_position;
    v_pos = (foil_height / 2) - indicator_position;
    
    translate([ h_pos,  v_pos, 0]) draw_indicator_cross();
    translate([-h_pos,  v_pos, 0]) draw_indicator_cross();
    translate([-h_pos, -v_pos, 0]) draw_indicator_cross();
    translate([ h_pos, -v_pos, 0]) draw_indicator_cross();
}

module draw_half_letter(col, row)
{
    difference()
    {
        intersection()
        {
            // this does the overlap of the letter
            //draw_flap();
            square([flap_width, flap_height + overlap], center = true);
            
            // mind front and back as well as last character
            if(side == "front")
            {
                rotate([0, 0]) translate([0, -(flap_height / 2)]) 
                    draw_letter(chars[(cols * row) + col]);
            }
            else
            {
                character = (cols * row) - col + cols == len(chars) ? 0 : (cols * row) - col + cols ;
                rotate([180, 180]) translate([0,  (flap_height / 2)]) 
                    draw_letter(chars[character]);
            }
        }
        // Das ist der Balken, der alles Überstehende abschneidet
        translate([0, (flap_height/2) - (cut_off_blind/2)]) square([flap_width, cut_off_blind], center = true);
    }
}

module draw_cols_and_rows()
{
    for(col=[0:1:cols-1])
    {
        for(row=[0:1:rows-1])
        {
            // this translate shifts the objects in rows and cols
            translate([((flap_width + (2 * flap_pin) + h_space_between_flaps) * col), -((flap_height + v_space_between_flaps) * row)])
            {
                draw_half_letter(col, row);
                draw_flap_outline();
            }
        }
    }
}
