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


cols = 6;
rows = 6;
space = 1;

sheet_width = 500;
sheet_height = 500;


difference()
{
    square(size = [sheet_width, sheet_height], center = false);
    for(col=[0:1:cols-1])
    {
        for(row=[0:1:rows-1])
        {
            translate([(carousel_diameter / 2) + ((carousel_diameter + space) * row), (carousel_diameter / 2) + ((carousel_diameter + space) * col), 0])
            if((col + row) %  2 == 0)
            {
                // render() makes the preview faster
                render() karussell_scheibe_rechts();
            }
            else
            {
                render() karussell_scheibe_links();
            }
        }
    }
}
