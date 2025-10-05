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

// explode 12 to show exploded view and spin the view
//explode = 12;
// explode 0 to show compact view and spin the carousel
explode = 0;
module split_flap()
{
    translate(carousel_pos)
    {
        //rotate([90, 0, 0]) translate(housing_virt_bolt_pos) rotate([90, 0, 0]) circle();
        
        rotate([270, 0, 270])
        {
            rotate([0, explode == 0 ? -360 * $t : 0, 0])
            {
                translate([0, -(explode * 10), 0])   color("#333")   karussell_spacer();
                translate([0, -(explode * 2), 0])    color("#888")   karussell_schrauben();
                translate([0, -(explode * 13.5), 0]) color("#888")   karussell_muttern();
                translate([0, -(explode * 8), 0])    color("#555")   karussell_scheibe_position("rechts");
                translate([0, -(explode * 12.5), 0]) color("#555")   karussell_scheibe_position("links");
                
                // use this trick to speed up things: export rendered carousel wheels to .stl and import it here again.
                rotate([90, 90, 0]) translate([0, 0,  ((carousel_inner_distance/2) + (carousel_thickness/2) + (explode * 12.5))]) color("#555") import("Carousel_left.stl");
                rotate([90, 90, 0]) translate([0, 0, -((carousel_inner_distance/2) + (carousel_thickness/2) - (explode * 9))])    color("#555") import("Carousel_right.stl");
                
                // The Pouley
                translate([0, -(explode * 11.5), 0]) color("grey")   stepper_pouley();
                translate([0, -(explode * 14), 0])   color("#888")   pouley_schrauben();

                // The flaps
                if (explode == 0)
                translate([0, -(explode * 10), 0]) rotating_carousel();

            }
        }

        if (explode > 0)
        translate([0, 0, (explode * 10)]) example_flap_bottom(28);

        // Stepper Motor, Schrittmotor
        translate([0, 0, (explode * 10)])   color("silver") stepper_motor();
        translate([0, 0, -(explode * 3)])   color("#888")   motor_schrauben();

        // Spacer für Motor
        translate([0, 0, (explode * 8)])    color("#333")   stepper_spacer();

        // PCB
        // OpenSCAD generated PCB
        translate([0, 0, (explode * 1)])                    pcb();
        translate([0, 0, -(explode * 1.2)]) color("#888")   pcb_schrauben();
        translate([0, 0, (explode * 2)])    color("#888")   pcb_muttern();
        translate([0, 0, (explode * 0.5)])  color("#333")   pcb_spacer();

    }

    // Gehäuse Seiten:
    color([0.85, 0.85, 0.85, 0.6])
    {
        // Rechts mit grossem Ausschnitt
        %chassis_right();
        
        // Links mit Löcher für Motor
        %chassis_left();

        // Front
        %chassis_front();
    }
    
    // Bolt für die Flaps
    translate([0, 0, -(explode * 3)])    color("#888") chassis_bolt_screw();
    translate([0, 0,  (explode * 2)])    color("#888") chassis_bolt_nut();
}

rotate([270, 0, explode > 0 ? -360 * $t : 0]) split_flap();

