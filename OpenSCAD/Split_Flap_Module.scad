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

include<3D_library.scad>;

module split_flap(){
    *check();
    
    translate(carousel_pos)
    {
        rotate([270, 0, 270])
        {
            rotate([0, -360 * $t, 0])
            {
                color("#bbb") karussell_spacer();
                karussell_schrauben();
                karussell_muttern();
                karussell_scheibe_position("rechts");
                karussell_scheibe_position("links");

                // Das Pouley
                color("grey") stepper_pouley();
                color("#888") pouley_schrauben();

                // The flaps
                rotating_carousel();
                *example_flaps_bolt();
            }
        }

        // Schräges Flap, um zu checken, ob es am unteren
        // Ende des Gehäuseausschnittes anschlägt.
        *odd_flap_bottom();

        // Beispiel Flap
        *example_flap_front_top();
        *example_flap_front_bottom();
        *example_flap_bottom();

        // Stepper Motor, Schrittmotor
        color("silver") stepper_motor();
        color("#888")  motor_schrauben();

        // Spacer für Motor
        color("#333") stepper_spacer();

        // PCB
        color("#888") pcb_schrauben();
        color("#888") pcb_muttern();
        color("#333") pcb_spacer();
        pcb();
    }

    // Gehäuse Seiten:
    color([0.85, 0.85, 0.85, 0.6]){
        // Rechts mit grossem Ausschnitt
        %chassis_right();

        // Links mit Löcher für Motor
        %chassis_left();

        // Front
        %chassis_front();
    }
}



explode = 12;
module split_flap_exploded(){
    
    translate(carousel_pos)
    {
        rotate([270, 0, 270])
        {
            translate([0, -(explode * 10), 0])  color("#333")   karussell_spacer();
            translate([0, -(explode * 2), 0])                   karussell_schrauben();
            translate([0, -(explode * 12.5), 0])                karussell_muttern();
            translate([0, -(explode * 8),  0])                  karussell_scheibe_position("rechts");
            translate([0, -(explode * 12), 0])                  karussell_scheibe_position("links");
            // Das Pouley
            translate([0, -(explode * 11.5), 0]) color("grey") stepper_pouley();
            translate([0, -(explode * 13.5), 0]) color("#888") pouley_schrauben();
            
            *translate([0, -(explode * 10), 0]) rotating_carousel();
            *example_flaps_bolt();

        }

        translate([0, 0, (explode * 10)]) example_flap_bottom();

        // Stepper Motor, Schrittmotor
        translate([0, 0, (explode * 10)])   color("silver") stepper_motor();
        translate([0, 0, -explode * 3])     color("#888")   motor_schrauben();

        // Spacer für Motor
        translate([0, 0, (explode * 8)])    color("#333")   stepper_spacer();

        // PCB
        translate([0, 0, (explode * 1)])                    pcb();
        translate([0, 0, -(explode * 1.2)]) color("#888")   pcb_schrauben();
        translate([0, 0, (explode * 2)])    color("#888")   pcb_muttern();
        translate([0, 0, (explode * 0.5)])  color("#333")   pcb_spacer();

    }

    // Gehäuse Seiten:
    color([0.85, 0.85, 0.85,0.6]){
        // Rechts mit grossem Ausschnitt
        %chassis_right();

        // Links mit Löcher für Motor
        %chassis_left();

        // Front
        %chassis_front();
    }
}

*rotate([270, 0, 0]) split_flap();
rotate([0, 0, -360 * $t])
{
    translate([0,  -55, 0]) 
    rotate([270, 0, 0]) split_flap_exploded();
}


