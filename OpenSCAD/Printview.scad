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
