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

module check(){
    motor_befestigung_vorne  = (((housing_width/2) - (motor_winding_distance/2)) - carousel_pos_x);
    motor_befestigung_hinten = (((housing_width/2) + (motor_winding_distance/2)) - carousel_pos_x);
    motor_befestigung_oben   = (((housing_height/2)  - (motor_winding_distance/2)) + carousel_pos_y);
    motor_befestigung_unten  = (((housing_height/2)  + (motor_winding_distance/2)) + carousel_pos_y);
    
    geh_abst_zu_ausschn_oben = ((housing_height/2)-(housing_cutout_height/2)+housing_cutout_position_y);
    echo ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    echo (concat("motor_befestigung_vorne:  ", motor_befestigung_vorne));
    echo (concat("motor_befestigung_hinten: ", motor_befestigung_hinten));
    echo (concat("motor_befestigung_oben:  ", motor_befestigung_oben));
    echo (concat("motor_befestigung_unten: ", motor_befestigung_unten));
    echo (concat("geh_abst_zu_ausschn_oben: ", geh_abst_zu_ausschn_oben));
    echo (concat("Radius Karussell: ", carousel_diameter/2));
    echo (concat("Radius Pfad Löcher: ", carousel_flap_path_radius));
    echo ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

    // Beweis, dass die oben berechneten Masse stimmen.
    color("red"){
        // Schrauben Löcher
        translate([(housing_width/2)-motor_befestigung_vorne,-29,-36]) square([motor_befestigung_vorne,1], center = false);
        translate([(housing_width/2)-motor_befestigung_hinten,3,-36]) square([motor_befestigung_hinten,1], center = false);
        
        translate([4, -(housing_height/2),-36]) square([1,motor_befestigung_oben], center = false);
        translate([34,-(housing_height/2),-36]) square([1,motor_befestigung_unten], center = false);
        
        // Abstand vorne, von oben bis Ausschnitt
        translate([61,-(housing_height/2),0]) square(geh_abst_zu_ausschn_oben, center = false);
        
        // Wieviel steht das Flap am Gehäuse an, bevor es fällt.
        translate([61.5,-(housing_height/2)+23,0]) rotate([0, 0, 45]) square([2, 2], center = true);
        translate([61.5,-(housing_height/2)+26,0]) rotate([0, 0, 45]) square([2, 2], center = true);
        
        // Breite des Gehäuses aussen
        translate([62,-55,0]) cube([2, 2, housing_outer_distance], center = true);
    }
}

module arc(angle, inner, strength, height){
    render()
    difference(){
        rotate_extrude($fn=100) translate([inner, -(height / 2), 0]) square([strength, height]);
        translate([-angle,-(strength + inner),-(height / 2)]) cube([(strength + inner + angle), (strength + inner) * 2, height]);
        translate([-(strength + inner),-angle,-(height / 2)]) cube([(strength + inner) * 2, (strength + inner + angle), height]);
    }
}

module schraube(){
    color("#888"){
        // Schraube
        cylinder(d=screw_diameter, h=screw_length, $fn=20, center = true);
        // Schrauben Köpfli
        translate([0, 0 ,-((screw_length / 2) + (2 / 2))]){
            translate([0,0,-1]) cylinder(1, r=1.5);
            cylinder(1.3, r=2.5);
            translate([0,0,0]) rotate_extrude() translate([1.5,0,0]) circle(1);
        }
        
    }

}

module karussell_scheibe(){
    difference(){
        cylinder(d=carousel_diameter, h=carousel_thickness, center = true);

        // Achse
        cylinder(d=carousel_axis_diameter, h=carousel_thickness_holes, center = true);

        // Löcher für Flaps
        for(i=[1:nr_of_flaps]){
            translate([carousel_flap_path_radius*cos(i*(360/nr_of_flaps)),carousel_flap_path_radius*sin(i*(360/nr_of_flaps)),0]) cylinder(d=carousel_flap_holes_diameter, h=carousel_thickness_holes, $fn=50, center = true);
        }

        // Löcher für Motor Poulley
        for(i=[1:pulley_nr_of_holes]){
            translate([pulley_holes_path_radius*cos(i*(360/pulley_nr_of_holes)),pulley_holes_path_radius*sin(i*(360/pulley_nr_of_holes)),0]) cylinder(d=pulley_holes_diameter, h=carousel_thickness_holes, $fn=50, center = true);
        }

        // Löcher Spacers
        for(i=[1:carousel_spacer_nr]){
            translate([carousel_spacer_path_radius*cos(i*(360/carousel_spacer_nr)),carousel_spacer_path_radius*sin(i*(360/carousel_spacer_nr)),0]) cylinder(d=carousel_spacer_holes_diameter, h=carousel_thickness_holes, $fn=50, center = true);
        }

        // 2mm Loch für das Magnet und als Alignement
        x=(360 / nr_of_flaps * 7);
        translate([magnet_hole_path_radius*cos(x),magnet_hole_path_radius*sin(x),0]){
            cylinder(d=magnet_hole_diameter, h=carousel_thickness_holes, $fn=50, center = true);
        }
    }

    // check
    //x=(360/50*7);
    //translate([0,0,3]) rotate([0,0,x]) color("red") square([100,0.2], center = true);
}

module karussell_scheibe_links()
{
    difference()
    {
        karussell_scheibe();
        rotate([0,0,0])   arc(5, 12, (carousel_diameter_cutout/2) - 12, carousel_thickness + 1);
        rotate([0,0,90])  arc(5, 12, (carousel_diameter_cutout/2) - 12, carousel_thickness + 1);
        rotate([0,0,180]) arc(5, 12, (carousel_diameter_cutout/2) - 12, carousel_thickness + 1);
        rotate([0,0,270]) arc(5, 12, (carousel_diameter_cutout/2) - 12, carousel_thickness + 1);
    }
}

module karussell_scheibe_rechts()
{
    difference()
    {
        karussell_scheibe();
        cylinder(d=carousel_diameter_cutout, h=carousel_thickness_holes, center = true);
    }
}

module karussell_scheibe_position(side = "rechts")
{
    color("#555") rotate([90,90,0])
    if(side == "rechts")
    {
        translate([0,0,-(carousel_inner_distance/2)-(carousel_thickness/2)])
        {
            karussell_scheibe_rechts();
        }
    }
    else
    {
        translate([0,0,(carousel_inner_distance/2)+(carousel_thickness/2)])
        {
            karussell_scheibe_links();
        }
    }
}

module karussell_spacer(){
    rotate([90,11,0]){
        for(i=[1:carousel_spacer_nr]){
            translate([carousel_spacer_path_radius*cos(i*(360/carousel_spacer_nr)),carousel_spacer_path_radius*sin(i*(360/carousel_spacer_nr)),0]){
                translate([0,0,1.5]) schraube();
                difference(){
                    cylinder(d=carousel_spacer_outer_diameter, h=carousel_spacer_length, center = true);
                    cylinder(d=carousel_spacer_inner_diameter, h=carousel_spacer_length, center = true);

                }
                // Gewindeeinsatz
                translate([0, 0 ,(carousel_inner_distance / 2 + carousel_thickness + (0.85 / 2))]) color("#F1A426") cylinder(d=6.10, h=0.85, center = true);
            }
        }
    }
}

module odd_flap_bottom(){
    rotate([0,0,51*1.2]){
        translate([(carousel_flap_path_radius+(flap_height/2)-1.5),0,0]){
            rotate([90,0,0]){
                flap();
            }
        }
    }
}

module example_flap_front_top(){
    translate([carousel_flap_path_radius, -((flap_height/2)-1.5), 0]){
        rotate([90,0,270]){
            flap();
        }
    }
}

module example_flap_front_bottom(){
    translate([(carousel_flap_path_radius - 0.3),((flap_height/2)+3.2),0]){
        rotate([90,0,90]){
            flap();
        }
    }
}

module example_flap_bottom(){
    translate([0, (flap_height/2) + (carousel_flap_path_radius - (carousel_flap_holes_diameter / 2)) , 0]){
        rotate([90,0,90]){
            flap();
        }
    }
}

module stepper_motor(){
    translate([0,0,-((housing_inner_distance/2)-(motor_depth/2)-motor_carousel_spacer_length)]){
        difference(){
            cube([motor_width,motor_height,motor_depth], center = true);
            // Ecken
            translate([motor_width/2,motor_height/2,0])    rotate([0,0,45]) cube([motor_corners,motor_corners,motor_depth+0.1], center = true);
            translate([-motor_width/2,motor_height/2,0])   rotate([0,0,45]) cube([motor_corners,motor_corners,motor_depth+0.1], center = true);
            translate([motor_width/2,-motor_height/2,0])   rotate([0,0,45]) cube([motor_corners,motor_corners,motor_depth+0.1], center = true);
            translate([-motor_width/2,-motor_height/2,0])  rotate([0,0,45]) cube([motor_corners,motor_corners,motor_depth+0.1], center = true);
        }
        // Aufsatz
        translate([0,0,-((motor_depth/2)+(motor_attachment_depth/2))]) cylinder(d=motor_attachment_diameter, h=motor_attachment_depth, center = true);
        
        //Achse
        translate([0,0,motor_axis_shift]) cylinder(d=motor_axis_diameter, h=motor_axis_length, center = true);
    }
}

module stepper_spacer(){
    spacer_pos = ((housing_inner_distance/2)-(motor_carousel_spacer_length/2));
    translate([motor_winding_distance/2,motor_winding_distance/2,-spacer_pos]){
        difference(){
            cylinder(d=motor_spacer_outer_diameter, h=motor_carousel_spacer_length, center = true);
            cylinder(d=motor_spacer_inner_diameter, h=motor_carousel_spacer_length, center = true);
        }
    }
    translate([-motor_winding_distance/2,motor_winding_distance/2,-spacer_pos]){
        difference(){   
            cylinder(d=motor_spacer_outer_diameter, h=motor_carousel_spacer_length, center = true);
            cylinder(d=motor_spacer_inner_diameter, h=motor_carousel_spacer_length, center = true);
        }
    }
    translate([motor_winding_distance/2,-motor_winding_distance/2,-spacer_pos]){
        difference(){
            cylinder(d=motor_spacer_outer_diameter, h=motor_carousel_spacer_length, center = true);
            cylinder(d=motor_spacer_inner_diameter, h=motor_carousel_spacer_length, center = true);
        }
    }
    translate([-motor_winding_distance/2,-motor_winding_distance/2,-spacer_pos]){
        difference(){
            cylinder(d=motor_spacer_outer_diameter, h=motor_carousel_spacer_length, center = true);
            cylinder(d=motor_spacer_inner_diameter, h=motor_carousel_spacer_length, center = true);
        }
    }
}

module stepper_pouley(){
    translate([0,0,(carousel_inner_distance/2)-(pulley_thickness/2)]) {
        difference(){
            cylinder(d=pulley_diameter, h=pulley_thickness, center = true);

            // Achse
            cylinder(d=pulley_axis_diameter, h=pulley_thickness, center = true);

            // m3 Gewinde
            translate([0,pulley_holes_path_radius,0])  cylinder(d=pulley_holes_diameter, h=pulley_thickness, center = true);
            translate([0,-pulley_holes_path_radius,0]) cylinder(d=pulley_holes_diameter, h=pulley_thickness, center = true);
            translate([pulley_holes_path_radius,0,0])  cylinder(d=pulley_holes_diameter, h=pulley_thickness, center = true);
            translate([-pulley_holes_path_radius,0,0]) cylinder(d=pulley_holes_diameter, h=pulley_thickness, center = true);
        }
    }
}


module chassis_front(){
    difference(){
        geh_front_pos = (housing_width/2)-(housing_thickness/2);
        translate([geh_front_pos,0,0]) cube([housing_thickness,housing_height,housing_inner_distance], center = true);
        // Ausschnitt
        translate([geh_front_pos,housing_cutout_position_y,0]) cube([housing_thickness+0.1,housing_cutout_height,housing_cutout_width], center = true);

        // Die kleinen Ausschnitte für die Räder des Karussells
        geh_aus_kar = (housing_cutout_width/2) + (housing_cutout_small_width/2);
        translate([geh_front_pos,carousel_pos_y,geh_aus_kar]) cube([housing_thickness+0.1,housing_cutout_small_height,housing_cutout_small_width], center = true);
        translate([geh_front_pos,carousel_pos_y,-geh_aus_kar]) cube([housing_thickness+0.1,housing_cutout_small_height,housing_cutout_small_width], center = true);
    }
}

module chassis_right(){
    translate([0,0,-((housing_inner_distance/2)+(housing_thickness/2))]){
        difference(){
            cube([housing_width,housing_height,housing_thickness], center = true);
            translate(carousel_pos){
                // Die Achse des Motors kommt dem Gehäuse sehr nahe. Daher machen wir ein Loch ins Gehäuse.
                translate([0, 0, 0]) cylinder(d=motor_axis_diameter + 1, h=housing_thickness + 1, center = true);
                
                // Löcher für Motor-Spacer                
                translate([motor_winding_distance/2,motor_winding_distance/2,0]) cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);
                translate([-motor_winding_distance/2,motor_winding_distance/2,0]) cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);
                translate([motor_winding_distance/2,-motor_winding_distance/2,0]) cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);
                translate([-motor_winding_distance/2,-motor_winding_distance/2,0]) cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);                        

                // Löcher für PCB
                translate([-((motor_winding_distance/2) + (motor_spacer_outer_diameter/2) + pcb_hole_top_from_left),  -((pcb_width / 2) - pcb_hole_top_from_top_edge), 0])     cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);
                translate([-((motor_winding_distance/2) + (motor_spacer_outer_diameter/2) + pcb_hole_bottom_from_left),  ((pcb_width / 2) - pcb_hole_bottom_from_bottom_edge), 0]) cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);
            }
            
            // Und hier noch das Loch für den Bolzen
            // XXX ToDo XXX
            translate([(housing_width/2)-18,(housing_height/2)-24,0]) cylinder(d=motor_spacer_inner_diameter, h=housing_thickness + 1, center = true);
        }
    }
}

module chassis_left(){
    // mit Ausschnitt für Karussell
    translate([0,0,((housing_inner_distance/2)+(housing_thickness/2))]){
        difference(){
            cube([housing_width,housing_height,housing_thickness], center = true);
            cube([housing_width-20,housing_height-20,housing_thickness+0.01], center = true);
        }
    }
}

module pcb(){
    // (pcb_length / 2) + (motor_winding_distance / 2) + (motor_spacer_outer_diameter / 2) - carousel_pos_x)
    translate([-((pcb_length / 2) + (motor_winding_distance / 2) + (motor_spacer_outer_diameter / 2) - carousel_pos_x), carousel_pos_y, -((housing_inner_distance / 2) - (pcb_thickness / 2))]){
        color("#1F6239"){
            difference(){
                cube([pcb_length, pcb_width, pcb_thickness], center = true);
                // die Löcher
                translate([((pcb_length / 2) - pcb_hole_top_from_left), -((pcb_width/2) - pcb_hole_top_from_top_edge),0])     cylinder(d=pcb_hole_diameter, h=pcb_thickness + 1, center = true);
                translate([((pcb_length / 2) - pcb_hole_bottom_from_left), ((pcb_width/2) - pcb_hole_bottom_from_bottom_edge),0]) cylinder(d=pcb_hole_diameter, h=pcb_thickness + 1, center = true);
            }
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), 0, 0]){
                cube([pcb_edge_length, pcb_edge_width, pcb_thickness], center = true);
            }
        }
        color("orange"){
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), 10, 0]) cube([pcb_edge_length, 2, pcb_thickness + 0.01], center = true);
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), 6, 0]) cube([pcb_edge_length, 2, pcb_thickness + 0.01], center = true);
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), 2, 0]) cube([pcb_edge_length, 2, pcb_thickness + 0.01], center = true);
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), -2, 0]) cube([pcb_edge_length, 2, pcb_thickness + 0.01], center = true);
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), -6, 0]) cube([pcb_edge_length, 2, pcb_thickness + 0.01], center = true);
            translate([-((pcb_length / 2) + (pcb_edge_length / 2)), -10, 0]) cube([pcb_edge_length, 2, pcb_thickness + 0.01], center = true);
        }
    }
    
    // resistor bzw. hall sensor
    translate([-((pcb_length / 2) + (motor_winding_distance / 2) + (motor_spacer_outer_diameter / 2) - carousel_pos_x), carousel_pos_y, -((housing_inner_distance / 2) - (pcb_thickness / 2))]){
        resistor_breite=2.6;
        resistor_hoehe=3.1;
        resistor_dicke=0.7;
        color("red"){
            translate([20, 0, ((pcb_thickness / 2) + (resistor_dicke / 2))]){
                cube([resistor_hoehe, resistor_breite, resistor_dicke], center = true);
            }
        }
    }
}

module flap(){
    color("#333") cube([flap_height,flap_width, flap_thickness], center = true);
    translate([-((flap_height/2) - (flap_pin/2)), -((flap_width/2) + (flap_pin/2)), 0])
    {
        color("#333") cube([flap_pin,flap_pin,flap_thickness], center = true);
    }
    translate([-((flap_height/2) - (flap_pin/2)),  ((flap_width/2) + (flap_pin/2)), 0]) 
    {
        color("#333") cube([flap_pin,flap_pin,flap_thickness], center = true);
    }
}

module rotating_carousel()
{
    for(i=[0:nr_of_flaps-1])
    {
        rotated_angle = (i * (360 / nr_of_flaps) - (360 * $t) + 360) % 360;

        translate([
                    (carousel_flap_path_radius)*sin(i*(360/nr_of_flaps)),
                    0, 
                    (carousel_flap_path_radius)*cos(i*(360/nr_of_flaps))
                  ])
        {
            rotate([0, 360 * $t, 0])
            {
                angle = (rotated_angle > 0 && rotated_angle < 180) ? rotated_angle : 180 ;
                rotate([0, angle, 0])
                {
                    translate([(carousel_flap_path_radius/2 - flap_thickness), 0, 0])
                    {
                        flap_with_char(i);
                    }
                }
            }
        }
    }
}

module draw_half_letter(char, flip = false)
{
    overrides     = get_letter_overrides(chars[char]);
    color         = is_undef(overrides[5]) ? get_font_setting("color") : overrides[5];
    rotate_letter = flip ? [0, 180, 90]      : [0, 0, 270];
    lift_letter   = flip ? -0.01             : 0.02;
    move_letter   = flip ? (flap_height/2)   : -(flap_height/2);

    translate([0, 0, lift_letter]) color(color) intersection()
    {
        cube([flap_height, flap_width, flap_thickness], center = true);
        rotate(rotate_letter) translate([0, move_letter, 0]) linear_extrude(height = flap_thickness) draw_letter(chars[char]);
    }
}

module flap_with_char(char)
{
    flap();
    draw_half_letter(char-1, flip = false);
    draw_half_letter(char,   flip = true);
}
