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

cols = 10; 
rows = 5; 

for(row=[0:1:rows-1])
{
    for(col=[0:1:cols-1])
    {
        // this translate shifts the objects in rows and cols
        translate([((flap_width + (2 * flap_pin) + h_space_between_flaps) * col), -((flap_height + v_space_between_flaps) * (row * 2))])
        {
            //                                                    XXX das hier ist falsch beim letzten Durchgang.
            rotate([0, 0, 90])   flap_with_char(((cols * row) + col) + 1);
        }
        translate([((flap_width + (2 * flap_pin) + h_space_between_flaps) * col), -((flap_height + v_space_between_flaps) * (row * 2) + (flap_height + 1))])
        {
            rotate([0, 180, 90]) flap_with_char(((cols * row) + col));
        }
    }
}
