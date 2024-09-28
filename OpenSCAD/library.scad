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

$fn=100;

// Karussell
karussell_durchmesser = 82;
karussell_wandstaerke = 3;
karussell_abstand = 51;
anzahl_flaps = 50;
durchmesser_loecher_flaps = 3.4;
radius_pfad_flaps = 40 - (durchmesser_loecher_flaps/2);
karussell_dm_loch_achse = 5;
karussell_pos_x = 20.5; // 0.5 mm nach vorne korrigiert
karussell_pos_y = -13.5; // 2 mm nach oben korrigiert
karussell_pos = [karussell_pos_x,karussell_pos_y,0];

// Die Löcher werden etwas länger, damit die Darstellung von OpenSCAD stimmt
karussell_wandstaerke_loecher = karussell_wandstaerke + 0.005;

// Ausschnitt
karussell_dm_ausschnitt = 59;

// Flaps
flaps_breite = 50;
flaps_hoehe = 40;
flaps_wandstaerke = 0.76;
flaps_nasen = 3;

// Poulley
poulley_anzahl_loecher = 4;
poulley_durchmesser_loecher = 3;
poulley_radius_pfad = 6.35;
poulley_durchmesser = 19;
poulley_staerke = 5;
poulley_achse = karussell_dm_loch_achse;

// Magnet
durchmesser_loch_magnet = 1.9;
radius_pfad_magnet = 33;

// Spacers Karussell
spacer_durchmesser_aussen = 6;
spacer_durchmesser_innen = 3.4;
spacer_laenge = karussell_abstand;
spacer_anzahl = 4;
spacer_durchmesser_loecher = 3.2;
spacer_radius_pfad = 33;

// Die Schrauben durch die Karussell Spacer
schrauben_laenge = 60;
schrauben_dm = 3;

// Stepper Motor
motor_breite = 42;
motor_hoehe = 42;
motor_tiefe = 34;
motor_ecken = 5.5;
motor_dm_achse = karussell_dm_loch_achse;
motor_achse_verschiebung = -5;
motor_laenge_achse = 64;
motor_aufsatz_tiefe = 2;
motor_aufsatz_dm = 22;
motor_distanz_gewinde = 31;
// Spacer für Motor
motor_spacer_dm_aussen = 6;
motor_spacer_dm_innen = 3.2;
motor_spacer_laenge = 20;

// Gehäuse
geh_breite = 120;
geh_hoehe = 150;
geh_aussenabstand = 70;
geh_wandstaerke = 0.8;
geh_innenabstand = geh_aussenabstand - (2 * geh_wandstaerke);

geh_ausschnitt_hoehe = 104;
geh_ausschnitt_breite = 53;
geh_ausschnitt_kar_ho = 35;
geh_ausschnitt_kar_br = 3;
geh_ausschnitt_pos_y = 3;

// PCB
pcb_breite = 42.67;
pcb_laenge = 72;
pcb_edge_breite = 26.6;
pcb_edge_laenge = 7.4;
pcb_wandstaerke = 1.6;

pcb_loch_durchmesser = 3.2;
pcb_loch_oben_from_left = 47;
pcb_loch_unten_from_left = 24;
pcb_loch_oben_from_top_edge = 7;
pcb_loch_unten_from_bottom_edge = 5;



module check(){
    motor_befestigung_vorne  = (((geh_breite/2) - (motor_distanz_gewinde/2)) - karussell_pos_x);
    motor_befestigung_hinten = (((geh_breite/2) + (motor_distanz_gewinde/2)) - karussell_pos_x);
    motor_befestigung_oben   = (((geh_hoehe/2)  - (motor_distanz_gewinde/2)) + karussell_pos_y);
    motor_befestigung_unten  = (((geh_hoehe/2)  + (motor_distanz_gewinde/2)) + karussell_pos_y);
    
    geh_abst_zu_ausschn_oben = ((geh_hoehe/2)-(geh_ausschnitt_hoehe/2)+geh_ausschnitt_pos_y);
    echo ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    echo ("motor_befestigung_vorne:  " , motor_befestigung_vorne);
    echo ("motor_befestigung_hinten: ", motor_befestigung_hinten);
    echo ("motor_befestigung_oben:  " , motor_befestigung_oben);
    echo ("motor_befestigung_unten: ", motor_befestigung_unten);
    echo ("geh_abst_zu_ausschn_oben: ", geh_abst_zu_ausschn_oben);
    echo ("Radius Karussell: ", karussell_durchmesser/2);
    echo ("Radius Pfad Löcher: ", radius_pfad_flaps);
    echo ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

    // Beweis, dass die oben berechneten Masse stimmen.
    color("red"){
        // Schrauben Löcher
        translate([(geh_breite/2)-motor_befestigung_vorne,-29,-36]) square([motor_befestigung_vorne,1], center = false);
        translate([(geh_breite/2)-motor_befestigung_hinten,3,-36]) square([motor_befestigung_hinten,1], center = false);
        
        translate([4, -(geh_hoehe/2),-36]) square([1,motor_befestigung_oben], center = false);
        translate([34,-(geh_hoehe/2),-36]) square([1,motor_befestigung_unten], center = false);
        
        // Abstand vorne, von oben bis Ausschnitt
        translate([61,-(geh_hoehe/2),0]) square(geh_abst_zu_ausschn_oben, center = false);
        
        // Breite des Gehäuses aussen
        translate([62,-55,0]) cube([2, 2, geh_aussenabstand], center = true);
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
        cylinder(d=schrauben_dm, h=schrauben_laenge, $fn=20, center = true);
        // Schrauben Köpfli
        translate([0, 0 ,-((schrauben_laenge / 2) + (2 / 2))]){
            translate([0,0,-1]) cylinder(1, r=1.5);
            cylinder(1.3, r=2.5);
            translate([0,0,0]) rotate_extrude() translate([1.5,0,0]) circle(1);
        }
        
    }

}

module karussell_scheibe(){
    difference(){
        cylinder(d=karussell_durchmesser, h=karussell_wandstaerke, center = true);

        // Achse
        cylinder(d=karussell_dm_loch_achse, h=karussell_wandstaerke_loecher, center = true);

        // Löcher für Flaps
        for(i=[1:anzahl_flaps]){
            translate([radius_pfad_flaps*cos(i*(360/anzahl_flaps)),radius_pfad_flaps*sin(i*(360/anzahl_flaps)),0]) cylinder(d=durchmesser_loecher_flaps, h=karussell_wandstaerke_loecher, $fn=20, center = true);
        }

        // Löcher für Motor Poulley
        for(i=[1:poulley_anzahl_loecher]){
            translate([poulley_radius_pfad*cos(i*(360/poulley_anzahl_loecher)),poulley_radius_pfad*sin(i*(360/poulley_anzahl_loecher)),0]) cylinder(d=poulley_durchmesser_loecher, h=karussell_wandstaerke_loecher, $fn=20, center = true);
        }

        // Löcher Spacers
        for(i=[1:spacer_anzahl]){
            translate([spacer_radius_pfad*cos(i*(360/spacer_anzahl)),spacer_radius_pfad*sin(i*(360/spacer_anzahl)),0]) cylinder(d=spacer_durchmesser_loecher, h=karussell_wandstaerke_loecher, $fn=20, center = true);
        }

        // 2mm Loch für das Magnet und als Alignement
        x=(360/50*7);
        translate([radius_pfad_magnet*cos(x),radius_pfad_magnet*sin(x),0]){
            cylinder(d=durchmesser_loch_magnet, h=karussell_wandstaerke_loecher, $fn=20, center = true);
        }
    }

    // check
    x=(360/50*7);
    //translate([0,0,3]) rotate([0,0,x]) color("red") square([100,0.2], center = true);
}

module karussell_scheibe_links(){
    translate([0,0,(karussell_abstand/2)+(karussell_wandstaerke/2)]){
        difference() {
            karussell_scheibe();
            // angle_a, angle_b, inner, strength, height
            rotate([0,0,0])   arc(5, 12, (karussell_dm_ausschnitt/2) - 12, karussell_wandstaerke + 1);
            rotate([0,0,90])  arc(5, 12, (karussell_dm_ausschnitt/2) - 12, karussell_wandstaerke + 1);
            rotate([0,0,180]) arc(5, 12, (karussell_dm_ausschnitt/2) - 12, karussell_wandstaerke + 1);
            rotate([0,0,270]) arc(5, 12, (karussell_dm_ausschnitt/2) - 12, karussell_wandstaerke + 1);
        }
    }
}

module karussell_scheibe_rechts(){
    translate([0,0,-(karussell_abstand/2)-(karussell_wandstaerke/2)]){
        difference(){
            karussell_scheibe();

            // Ausschnitt
            cylinder(d=karussell_dm_ausschnitt, h=karussell_wandstaerke_loecher, center = true);
        }
    }
}

module karussell_spacer(){
    for(i=[1:spacer_anzahl]){
        translate([spacer_radius_pfad*cos(i*(360/spacer_anzahl)),spacer_radius_pfad*sin(i*(360/spacer_anzahl)),0]){
            translate([0,0,1.5]) schraube();
            difference(){
                cylinder(d=spacer_durchmesser_aussen, h=spacer_laenge, center = true);
                cylinder(d=spacer_durchmesser_innen, h=spacer_laenge, center = true);

            }
            // Gewindeeinsatz
            translate([0, 0 ,(karussell_abstand / 2 + karussell_wandstaerke + (0.85 / 2))]) color("#F1A426") cylinder(d=6.10, h=0.85, center = true);
        }
    }
}



module all_flaps(){
    // speed up things with union 
    union() {
        // die oberen Flaps
        for(i=[1:anzahl_flaps/2]){
            rotate([0, 0, ((360/anzahl_flaps) * i) + 90]) {
                translate([(flaps_hoehe/2) - (durchmesser_loecher_flaps/2) + 0.1, radius_pfad_flaps, 0]){
                    rotate([0, 0, 90]) {
                        flap();
                    }
                }
            }
        }

        // die unteren Flaps
        for(i=[1:anzahl_flaps/2]){  // XXX                                                                                                                         komisch
            translate([radius_pfad_flaps*cos(i*(360/anzahl_flaps)),radius_pfad_flaps*sin(i*(360/anzahl_flaps)) + (flaps_hoehe/2) - (durchmesser_loecher_flaps/2) + 0.3, 0]){
                rotate([0, 0, 180]) {
                    flap();
                }
            }
        }
    }
}

module odd_flap_bottom(){
    rotate([0,0,51*1.2]){
        translate([(radius_pfad_flaps+(flaps_hoehe/2)-1.5),0,0]){
            rotate([0,0,90]){
                flap();
            }
        }
    }
}

module example_flap_front_top(){
    translate([radius_pfad_flaps, -((flaps_hoehe/2)-1.5), 0]){
        rotate([0,0,0]){
            flap();
        }
    }
}

module example_flap_front_bottom(){
    translate([(radius_pfad_flaps - 0.3),((flaps_hoehe/2)+3.2),0]){
        rotate([180,0,0]){
            flap();
        }
    }
}

module example_flap_bottom(){
    translate([0, (flaps_hoehe/2) + (radius_pfad_flaps - (durchmesser_loecher_flaps / 2)) , 0]){
        rotate([180,0,0]){
            flap();
        }
    }
}

module stepper_motor(){
    translate([0,0,-((geh_innenabstand/2)-(motor_tiefe/2)-motor_spacer_laenge)]){
        difference(){
            cube([motor_breite,motor_hoehe,motor_tiefe], center = true);
            // Ecken
            translate([motor_breite/2,motor_hoehe/2,0])    rotate([0,0,45]) cube([motor_ecken,motor_ecken,motor_tiefe], center = true);
            translate([-motor_breite/2,motor_hoehe/2,0])   rotate([0,0,45]) cube([motor_ecken,motor_ecken,motor_tiefe], center = true);
            translate([motor_breite/2,-motor_hoehe/2,0])   rotate([0,0,45]) cube([motor_ecken,motor_ecken,motor_tiefe], center = true);
            translate([-motor_breite/2,-motor_hoehe/2,0])  rotate([0,0,45]) cube([motor_ecken,motor_ecken,motor_tiefe], center = true);
        }
        // Aufsatz
        translate([0,0,-((motor_tiefe/2)+(motor_aufsatz_tiefe/2))]) cylinder(d=motor_aufsatz_dm, h=motor_aufsatz_tiefe, center = true);
        
        //Achse
        translate([0,0,motor_achse_verschiebung]) cylinder(d=motor_dm_achse, h=motor_laenge_achse, center = true);
    }
}

module stepper_spacer(){
    spacer_pos = ((geh_innenabstand/2)-(motor_spacer_laenge/2));
    translate([motor_distanz_gewinde/2,motor_distanz_gewinde/2,-spacer_pos]){
        difference(){
            cylinder(d=motor_spacer_dm_aussen, h=motor_spacer_laenge, center = true);
            cylinder(d=motor_spacer_dm_innen, h=motor_spacer_laenge, center = true);
        }
    }
    translate([-motor_distanz_gewinde/2,motor_distanz_gewinde/2,-spacer_pos]){
        difference(){   
            cylinder(d=motor_spacer_dm_aussen, h=motor_spacer_laenge, center = true);
            cylinder(d=motor_spacer_dm_innen, h=motor_spacer_laenge, center = true);
        }
    }
    translate([motor_distanz_gewinde/2,-motor_distanz_gewinde/2,-spacer_pos]){
        difference(){
            cylinder(d=motor_spacer_dm_aussen, h=motor_spacer_laenge, center = true);
            cylinder(d=motor_spacer_dm_innen, h=motor_spacer_laenge, center = true);
        }
    }
    translate([-motor_distanz_gewinde/2,-motor_distanz_gewinde/2,-spacer_pos]){
        difference(){
            cylinder(d=motor_spacer_dm_aussen, h=motor_spacer_laenge, center = true);
            cylinder(d=motor_spacer_dm_innen, h=motor_spacer_laenge, center = true);
        }
    }
}

module stepper_pouley(){
    translate([0,0,(karussell_abstand/2)-(poulley_staerke/2)]) {
        difference(){
            cylinder(d=poulley_durchmesser, h=poulley_staerke, center = true);

            // Achse
            cylinder(d=poulley_achse, h=poulley_staerke, center = true);

            // m3 Gewinde
            translate([0,poulley_radius_pfad,0])  cylinder(d=poulley_durchmesser_loecher, h=poulley_staerke, center = true);
            translate([0,-poulley_radius_pfad,0]) cylinder(d=poulley_durchmesser_loecher, h=poulley_staerke, center = true);
            translate([poulley_radius_pfad,0,0])  cylinder(d=poulley_durchmesser_loecher, h=poulley_staerke, center = true);
            translate([-poulley_radius_pfad,0,0]) cylinder(d=poulley_durchmesser_loecher, h=poulley_staerke, center = true);
        }
    }
}


module chassis_front(){
    difference(){
        geh_front_pos = (geh_breite/2)-(geh_wandstaerke/2);
        translate([geh_front_pos,0,0]) cube([geh_wandstaerke,geh_hoehe,geh_innenabstand], center = true);
        // Ausschnitt
        translate([geh_front_pos,geh_ausschnitt_pos_y,0]) cube([geh_wandstaerke+0.1,geh_ausschnitt_hoehe,geh_ausschnitt_breite], center = true);

        // Die kleinen Ausschnitte für die Räder des Karussells
        geh_aus_kar = (geh_ausschnitt_breite/2) + (geh_ausschnitt_kar_br/2);
        translate([geh_front_pos,karussell_pos_y,geh_aus_kar]) cube([geh_wandstaerke+0.1,geh_ausschnitt_kar_ho,geh_ausschnitt_kar_br], center = true);
        translate([geh_front_pos,karussell_pos_y,-geh_aus_kar]) cube([geh_wandstaerke+0.1,geh_ausschnitt_kar_ho,geh_ausschnitt_kar_br], center = true);
    }
}

module chassis_left(){
    translate([0,0,-((geh_innenabstand/2)+(geh_wandstaerke/2))]){
        difference(){
            cube([geh_breite,geh_hoehe,geh_wandstaerke], center = true);
            translate(karussell_pos){
                // Die Achse des Motors kommt dem Gehäuse sehr nahe. Daher machen wir ein Loch ins Gehäuse.
                translate([0, 0, 0]) cylinder(d=motor_dm_achse + 1, h=geh_wandstaerke + 1, center = true);
                
                // Löcher für Motor-Spacer                
                translate([motor_distanz_gewinde/2,motor_distanz_gewinde/2,0]) cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);
                translate([-motor_distanz_gewinde/2,motor_distanz_gewinde/2,0]) cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);
                translate([motor_distanz_gewinde/2,-motor_distanz_gewinde/2,0]) cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);
                translate([-motor_distanz_gewinde/2,-motor_distanz_gewinde/2,0]) cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);                        

                // Löcher für PCB
                translate([-((motor_distanz_gewinde/2) + (motor_spacer_dm_aussen/2) + pcb_loch_oben_from_left),  -((pcb_breite / 2) - pcb_loch_oben_from_top_edge), 0])     cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);
                translate([-((motor_distanz_gewinde/2) + (motor_spacer_dm_aussen/2) + pcb_loch_unten_from_left),  ((pcb_breite / 2) - pcb_loch_unten_from_bottom_edge), 0]) cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);
            }
            
            // Und hier noch das Loch für den Bolzen
            // XXX ToDo XXX
            translate([(geh_breite/2)-18,(geh_hoehe/2)-24,0]) cylinder(d=motor_spacer_dm_innen, h=geh_wandstaerke + 1, center = true);
        }
    }
}

module chassis_right(){
    // mit Ausschnitt für Karussell
    translate([0,0,((geh_innenabstand/2)+(geh_wandstaerke/2))]){
        difference(){
            cube([geh_breite,geh_hoehe,geh_wandstaerke], center = true);
            cube([geh_breite-20,geh_hoehe-20,geh_wandstaerke+0.01], center = true);
        }
    }
}

module pcb(){
    // (pcb_laenge / 2) + (motor_distanz_gewinde / 2) + (motor_spacer_dm_aussen / 2) - karussell_pos_x)
    translate([-((pcb_laenge / 2) + (motor_distanz_gewinde / 2) + (motor_spacer_dm_aussen / 2) - karussell_pos_x), karussell_pos_y, -((geh_innenabstand / 2) - (pcb_wandstaerke / 2))]){
        color("#1F6239"){
            difference(){
                cube([pcb_laenge, pcb_breite, pcb_wandstaerke], center = true);
                // die Löcher
                translate([((pcb_laenge / 2) - pcb_loch_oben_from_left), -((pcb_breite/2) - pcb_loch_oben_from_top_edge),0])     cylinder(d=pcb_loch_durchmesser, h=pcb_wandstaerke + 1, center = true);
                translate([((pcb_laenge / 2) - pcb_loch_unten_from_left), ((pcb_breite/2) - pcb_loch_unten_from_bottom_edge),0]) cylinder(d=pcb_loch_durchmesser, h=pcb_wandstaerke + 1, center = true);
            }
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), 0, 0]){
                cube([pcb_edge_laenge, pcb_edge_breite, pcb_wandstaerke], center = true);
            }
        }
        color("orange"){
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), 10, 0]) cube([pcb_edge_laenge, 2, pcb_wandstaerke + 0.01], center = true);
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), 6, 0]) cube([pcb_edge_laenge, 2, pcb_wandstaerke + 0.01], center = true);
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), 2, 0]) cube([pcb_edge_laenge, 2, pcb_wandstaerke + 0.01], center = true);
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), -2, 0]) cube([pcb_edge_laenge, 2, pcb_wandstaerke + 0.01], center = true);
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), -6, 0]) cube([pcb_edge_laenge, 2, pcb_wandstaerke + 0.01], center = true);
            translate([-((pcb_laenge / 2) + (pcb_edge_laenge / 2)), -10, 0]) cube([pcb_edge_laenge, 2, pcb_wandstaerke + 0.01], center = true);
        }
    }
}

module resistor(){
    translate([-((pcb_laenge / 2) + (motor_distanz_gewinde / 2) + (motor_spacer_dm_aussen / 2) - karussell_pos_x), karussell_pos_y, -((geh_innenabstand / 2) - (pcb_wandstaerke / 2))]){
        resistor_breite=2.6;
        resistor_hoehe=3.1;
        resistor_dicke=0.7;
        color("red"){
            translate([20, 0, ((pcb_wandstaerke / 2) + (resistor_dicke / 2))]){
                cube([resistor_hoehe, resistor_breite, resistor_dicke], center = true);
            }
        }
    }
}

module flap(){
    color("#222") cube([flaps_wandstaerke,flaps_hoehe,flaps_breite], center = true);
    translate([0,((flaps_hoehe/2) - (flaps_nasen/2)), ((flaps_breite/2) + (flaps_nasen/2))]) color("red") cube([flaps_wandstaerke,flaps_nasen,flaps_nasen], center = true);
    translate([0,((flaps_hoehe/2) - (flaps_nasen/2)),-((flaps_breite/2) + (flaps_nasen/2))]) color("red") cube([flaps_wandstaerke,flaps_nasen,flaps_nasen], center = true);
}

module rotating_flap(){
    rotate([0, 0, 90])
    {
        color("#333") cube([flaps_breite,flaps_hoehe,flaps_wandstaerke], center = true);
        translate([ (flaps_breite/2) + (flaps_nasen/2), -(flaps_hoehe/2) + (flaps_nasen/2), 0])
        {
            color("red") cube([flaps_nasen,flaps_nasen,flaps_wandstaerke], center = true);
        }
        translate([-(flaps_breite/2) - (flaps_nasen/2), -(flaps_hoehe/2) + (flaps_nasen/2), 0]) 
        {
            color("red") cube([flaps_nasen,flaps_nasen,flaps_wandstaerke], center = true);
        }
    }
}

module rotating_flaps()
{
    translate([-(radius_pfad_flaps/2)+0.5, 0, 0]) rotate([0, -360 * $t, 0])
    {
        for(i=[1:anzahl_flaps])
        {
            rotated_angle = (i * (360 / anzahl_flaps) - (360 * $t) + 360) % 360;
            translate([
                        (radius_pfad_flaps)*sin(i*(360/anzahl_flaps)),
                        0, 
                        (radius_pfad_flaps)*cos(i*(360/anzahl_flaps))
                      ])
            {
                rotate([0, 360 * $t, 0])
                {
                    if (rotated_angle >= 0 && rotated_angle <= 180)
                    {
                        translate([radius_pfad_flaps/2 - flaps_wandstaerke, 0, 0])
                        rotate([0, rotated_angle + 180, 0])
                        //                       keine Ahnung warum
                        translate([-(radius_pfad_flaps/2) + flaps_wandstaerke, 0, 0])
                        //if(i == 1) color("red") rotating_flap(); else rotating_flap();
                        color( [i/50, 0.5+sin(10*i)/2, 0.5+sin(10*i)/2] ) rotating_flap();
                    }
                    else
                    {
                        //if(i == 1) color("red") rotating_flap(); else rotating_flap();
                        color( [i/50, 0.5+sin(10*i)/2, 0.5+sin(10*i)/2] ) rotating_flap();
                    }
                }
            }
        }
    }
}
