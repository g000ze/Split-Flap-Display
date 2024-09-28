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

include<library.scad>;


module split_flap(){
    *check();

    
    translate(karussell_pos){
        rotate([0, 0, 360 * $t]){
            // Scheibe für an den Motor
            karussell_scheibe_links();
            
            // Scheibe mit Ausschnitt
            karussell_scheibe_rechts();

            // Spacer für Karussell
            karussell_spacer();

            // Poulley
            color("lightgrey") stepper_pouley();
        }
        
        // Flaps
        *all_flaps();
        rotate([270, 0, 270]) rotating_flaps();

        // Schräges Flap, um zu checken, ob es am unteren
        // Ende des Gehäuseausschnittes anschlägt.
        *odd_flap_bottom();

        // Beispiel Flap
        *example_flap_front_top();
        *example_flap_front_bottom();
        *example_flap_bottom();

        // Stepper Motor, Schrittmotor
        color("grey") stepper_motor();

        // Spacer für Motor
        stepper_spacer();

    }

    // Gehäuse Seiten:
    color("#555"){
        // Rechts mit grossem Ausschnitt
        #chassis_right();

        // Links mit Löcher für Motor
        #chassis_left();

        // Front
        // um die Front transparent zu machen, kann ein "#" Hashtag vorangestellt werden.
        // So ist es möglich, das oberste Flap zu sehen, bevor es fällt.
        #chassis_front();
    }
    
    // PCB
    pcb();
    resistor();
}

// Hier wird das Modul "projection" verwendet, um 2D 
// darzustellen und danach nach "dfx" zu exportieren.
rotate([-90,0,0]) split_flap();

