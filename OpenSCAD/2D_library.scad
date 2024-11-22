/*
   Copyright Stefan Frech, 10.12.2021 - 28.09.2024
   Projekt Split-Flap Display Module

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

include<_settings.scad>;


module base_flap(overlap = 0)
{
    square([flap_width, flap_height + overlap], center = true);
}

module flap()
{
    base_flap();
    pins();
}

module flap_outline()
{
    difference()
    {
        offset(delta = +outline_weight) flap();
        flap();
    }
}

module pins()
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

module pins_outline()
{
    difference()
    {
        offset(delta = +outline_weight) pins();
        pins();
        // lets make the inner line disapear with an additional square
        translate([0, -((flap_height/2) - (flap_pin/2))]) square([flap_width, flap_pin + (outline_weight * 2)], center = true);
    }
}

module foil()
{
    square([foil_width, foil_height], center = true);
}

module indicator_cross()
{
    square([width_marker, length_marker], center = true);
    square([length_marker, width_marker], center = true);
}

module indicators(){
    // Indicators for CAD initialisation
    h_pos = (foil_width  / 2) - indicator_position;
    v_pos = (foil_height / 2) - indicator_position;
    
    translate([ h_pos,  v_pos, 0]) indicator_cross();
    translate([-h_pos,  v_pos, 0]) indicator_cross();
    translate([-h_pos, -v_pos, 0]) indicator_cross();
    translate([ h_pos, -v_pos, 0]) indicator_cross();
}
    
module half_letter(col, row)
{
    difference()
    {
        intersection()
        {
            // this does the overlap of the letter
            //flap();
            base_flap(overlap);
            
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
        // Das ist der Balken, der unten alles Überstehende abschneidet
        if(side != "front") translate([0, (flap_height/2) - (cut_off_blind/2)]) square([flap_width, cut_off_blind], center = true);
    }
}

module cols_and_rows()
{
    for(col=[0:1:cols-1])
    {
        for(row=[start_row-1:1:end_row-1])
        {
            // this translate shifts the objects in rows and cols
            translate([(flap_total_width + h_space_between_flaps) * col, -(flap_height + v_space_between_flaps) * (row - start_row)])
            {
                half_letter(col, row);
                flap_outline();
            }
        }
    }
}
