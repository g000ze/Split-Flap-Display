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

nr_of_flaps = 50;

// Flaps
flap_width = 50;
flap_height = 40;
flap_thickness = 0.76;
flap_pin = 3;

// Karussell
carousel_diameter = 82;
carousel_thickness = 3;
carousel_inner_distance = 51;
carousel_flap_holes_diameter = 3.4;
carousel_flap_path_radius = flap_height - (carousel_flap_holes_diameter/2);
carousel_axis_diameter = 5;
carousel_pos_x = 20.5; // 0.5 mm nach vorne korrigiert
carousel_pos_y = -13.5; // 2 mm nach oben korrigiert
carousel_pos = [carousel_pos_x,carousel_pos_y,0];

// Die Löcher werden etwas länger, damit die Darstellung von OpenSCAD stimmt
carousel_thickness_holes = carousel_thickness + 0.005;

// Ausschnitt
carousel_diameter_cutout = 59;

// Poulley
pulley_nr_of_holes = 4;
pulley_holes_diameter = 3;
pulley_holes_path_radius = 6.35;
pulley_diameter = 19;
pulley_thickness = 5;
pulley_axis_diameter = carousel_axis_diameter;

// Magnet
magnet_hole_diameter = 1.9;
magnet_hole_path_radius = 33;

// Spacers Karussell
carousel_spacer_outer_diameter = 6;
carousel_spacer_inner_diameter = 3.4;
carousel_spacer_length = carousel_inner_distance;
carousel_spacer_nr = 4;
carousel_spacer_holes_diameter = 3.2;
carousel_spacer_path_radius = 33;

// Die Schrauben durch die Karussell Spacer
screw_length = 60;
screw_diameter = 3;

// Stepper Motor
motor_width = 42;
motor_height = 42;
motor_depth = 34;
motor_corners = 5.5;
motor_axis_diameter = carousel_axis_diameter;
motor_axis_shift = -5;
motor_axis_length = 64;
motor_attachment_depth = 2;
motor_attachment_diameter = 22;
motor_winding_distance = 31;
// Spacer für Motor
motor_spacer_outer_diameter = 6;
motor_spacer_inner_diameter = 3.2;
motor_carousel_spacer_length = 20;

// Gehäuse
housing_width = 120;
housing_height = 150;
housing_outer_distance = 70;
housing_thickness = 0.8;
housing_inner_distance = housing_outer_distance - (2 * housing_thickness);

housing_cutout_height = 104;
housing_cutout_width = 53;
housing_cutout_small_height = 35;
housing_cutout_small_width = 3;
housing_cutout_position_y = 3;

// PCB
pcb_width = 42.67;
pcb_length = 72;
pcb_edge_width = 26.6;
pcb_edge_length = 7.4;
pcb_thickness = 1.6;

pcb_hole_diameter = 3.2;
pcb_hole_top_from_left = 47;
pcb_hole_bottom_from_left = 24;
pcb_hole_top_from_top_edge = 7;
pcb_hole_bottom_from_bottom_edge = 5;


chars = [ 
               "0", "A", "B", "C", "D",  
               "1", "E", "F", "G", "H", 
               "2", "I", "J", "K", "L", 
               "3", "M", "N", "O", "P", 
               "4", "Q", "R", "S", "T",  
               "5", "U", "V", "W", "X",  
               "6", "Y", "Z", "+", "-", 
               "7", "?", "!", ".", ",", 
               "8", "@", ":", ";", "#", 
               "9", "&", "*", "$", " ",  
        ];

/*
        chars = [
               "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
               "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
               "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
               "U", "V", "W", "X", "Y", "Z", "!", "%", "&", "*",
               "+", "-", ".", "/", ":", "?", "$", "@", "#", " ",
        ];
*/





/*
  Settings for the flaps sheet
*/

include<_font_setup.scad>;

font_preset = "msgothic";
letter_facet_number = 100;

// how many columns and rows to display
cols = 5;
//rows = 10;
rows = ceil(len(chars) / cols);

// Der Balken, der alles Überstehende abschneidet
cut_off_blind      = 4.5;

// horizontal space between flaps
h_space_between_flaps = 8;
// vertical space between flaps
v_space_between_flaps = 8;

outline_weight = 0.2;

// overlap letter for cutting tolerance
overlap = 4;

// the size of the foil
foil_width  = 360;
foil_height = 510;

// font size of description text
font_size_desc = 3;

// marker sizes
length_marker = 8;
width_marker  = 0.2;

indicator_position = 14;

