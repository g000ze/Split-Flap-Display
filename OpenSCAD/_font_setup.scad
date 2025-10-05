/*
This code has originaly been created by Scott.
For details see https://github.com/scottbez1/splitflap/tree/master
Many thanks Scott for your big effort in your project!
*/

/*
Configure font presets below. Each font has the following settings:
  'array_name'
    This is the name to which you point to in the code.
    
     'font'
         Font name - see https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text#Using_Fonts_&_Styles
         Hint. Select "Help > Fontlist" to get a list of all included fonts. You will finde the appropriate names there.

     'height'
         Font size (height) relative to flaps. i.e. a value of 1 sets the font size equal to the height of the top and bottom flaps.

     'width'
         Width scale factor. 1 = use default font width.

     'offset_x'
         Horizontal offset, in mm, of letters within flaps. A value of 0 uses default font centering.
         
     'offset_y'
         Vertical offset, in mm, of letters within flaps. A value of 0 uses default font centering.

     'color'
         the default color of the character, used in 3D_library.scad

     'type'
         whether the given font or a white square should be drawn. Valid values are "square" or "font"

     'overrides'
         Array of position/size overrides for specific letters. Each entry is a set of overrides for a single letter,
         specified as an array with the following entries:
             - Letter to override (e.g. "M"). Case must match for the override to apply.
             - Additional X position offset, in mm (e.g. -5). Can be undef or 0 to omit.
             - Additional Y position offset, in mm (e.g. 2.5). Can be undef or 0 to omit.
             - Height override, as a value relative to flap height (e.g. 0.7). Replaces letter_height for this letter. Can be undef to omit.
             - Width override, as a value relative to default font width (e.g. 0.7). Replaces letter_width for this letter. Can be undef to omit.
             - Color override. Can be undef or 0 to omit.

*/


use<MS-Gothic-SFD.ttf>;


_font_settings = [
    "msgothicsfd", [
        "font", "MS Gothic SFD",
        "height", 0.9,
        "width", 0.92,
        "offset_x", 0,
        "offset_y", 1,
        "color", "white",
        "type", "letter",
        "overrides", [
            ["-", 0, -8, 1, 0.8],
            ["+", 0, -8, 0.9, 0.9],
            [".", 13, 7, 0.9, 0.9],
            [",", 13, 10, 0.9, 0.9],
            [":", 0, 7, 0.9, 0.9],
            [";", 0, 7, 0.9, 0.9],
            ["$", 0, 0, 0.75, 1.1],
            ["/", 0, 2.9, 0.95, 1, "white",  "square"],
        ],
    ],
];

/*
// try this if you wanna have fun with colors :-)
_font_settings = [
    "msgothicsfd", [
        "font", "MS Gothic SFD",
        "height", 0.9,
        "width", 0.92,
        "offset_x", 0,
        "offset_y", 1,
        "color", "white",
        "type", "letter",
        "overrides", [
            ["0", 1, 1, 1, 1, [1.000, 0.000, 0.000], "square"], 
            ["A", 1, 1, 1, 1, [1.000, 0.120, 0.000], "square"], 
            ["B", 1, 1, 1, 1, [1.000, 0.240, 0.000], "square"], 
            ["C", 1, 1, 1, 1, [1.000, 0.360, 0.000], "square"], 
            ["D", 1, 1, 1, 1, [1.000, 0.480, 0.000], "square"], 
            ["1", 1, 1, 1, 1, [1.000, 0.600, 0.000], "square"], 
            ["E", 1, 1, 1, 1, [1.000, 0.720, 0.000], "square"], 
            ["F", 1, 1, 1, 1, [1.000, 0.840, 0.000], "square"], 
            ["G", 1, 1, 1, 1, [1.000, 0.960, 0.000], "square"], 
            ["H", 1, 1, 1, 1, [0.960, 1.000, 0.000], "square"], 
            ["2", 1, 1, 1, 1, [0.840, 1.000, 0.000], "square"], 
            ["I", 1, 1, 1, 1, [0.720, 1.000, 0.000], "square"], 
            ["J", 1, 1, 1, 1, [0.600, 1.000, 0.000], "square"], 
            ["K", 1, 1, 1, 1, [0.480, 1.000, 0.000], "square"], 
            ["L", 1, 1, 1, 1, [0.360, 1.000, 0.000], "square"], 
            ["3", 1, 1, 1, 1, [0.240, 1.000, 0.000], "square"], 
            ["M", 1, 1, 1, 1, [0.120, 1.000, 0.000], "square"], 
            ["N", 1, 1, 1, 1, [0.000, 1.000, 0.000], "square"], 
            ["O", 1, 1, 1, 1, [0.000, 1.000, 0.120], "square"], 
            ["P", 1, 1, 1, 1, [0.000, 1.000, 0.240], "square"], 
            ["4", 1, 1, 1, 1, [0.000, 1.000, 0.360], "square"], 
            ["Q", 1, 1, 1, 1, [0.000, 1.000, 0.480], "square"], 
            ["R", 1, 1, 1, 1, [0.000, 1.000, 0.600], "square"], 
            ["S", 1, 1, 1, 1, [0.000, 1.000, 0.720], "square"], 
            ["T", 1, 1, 1, 1, [0.000, 1.000, 0.840], "square"], 
            ["5", 1, 1, 1, 1, [0.000, 1.000, 0.960], "square"], 
            ["U", 1, 1, 1, 1, [0.000, 0.960, 1.000], "square"], 
            ["V", 1, 1, 1, 1, [0.000, 0.840, 1.000], "square"], 
            ["W", 1, 1, 1, 1, [0.000, 0.720, 1.000], "square"], 
            ["X", 1, 1, 1, 1, [0.000, 0.600, 1.000], "square"], 
            ["6", 1, 1, 1, 1, [0.000, 0.480, 1.000], "square"], 
            ["Y", 1, 1, 1, 1, [0.000, 0.360, 1.000], "square"], 
            ["Z", 1, 1, 1, 1, [0.000, 0.240, 1.000], "square"], 
            ["+", 1, 1, 1, 1, [0.000, 0.120, 1.000], "square"], 
            ["-", 1, 1, 1, 1, [0.000, 0.000, 1.000], "square"], 
            ["7", 1, 1, 1, 1, [0.120, 0.000, 1.000], "square"], 
            ["?", 1, 1, 1, 1, [0.240, 0.000, 1.000], "square"], 
            ["!", 1, 1, 1, 1, [0.360, 0.000, 1.000], "square"], 
            [".", 1, 1, 1, 1, [0.480, 0.000, 1.000], "square"], 
            [",", 1, 1, 1, 1, [0.600, 0.000, 1.000], "square"], 
            ["8", 1, 1, 1, 1, [0.720, 0.000, 1.000], "square"], 
            ["@", 1, 1, 1, 1, [0.840, 0.000, 1.000], "square"], 
            [":", 1, 1, 1, 1, [0.960, 0.000, 1.000], "square"], 
            [";", 1, 1, 1, 1, [1.000, 0.000, 0.960], "square"], 
            ["#", 1, 1, 1, 1, [1.000, 0.000, 0.840], "square"], 
            ["9", 1, 1, 1, 1, [1.000, 0.000, 0.720], "square"], 
            ["*", 1, 1, 1, 1, [1.000, 0.000, 0.600], "square"], 
            ["$", 1, 1, 1, 1, [1.000, 0.000, 0.480], "square"], 
            ["/", 1, 1, 1, 1, [1.000, 0.000, 0.360], "square"], 
            [" ", 1, 1, 1, 1, [1.000, 0.000, 0.240], "square"], 
        ],
    ],
];
*/



// Private functions
function _get_entry_in_dict_array(arr, key) = arr[search([key], arr)[0] + 1];
function _get_font_settings() = _get_entry_in_dict_array(_font_settings, font_preset);

// Public functions
function get_font_setting(key) = _get_entry_in_dict_array(_get_font_settings(), key);
function get_letter_overrides(letter) = get_font_setting("overrides")[search([letter], get_font_setting("overrides"))[0]];

/*
  Public modules
*/
module draw_letter(letter) {
    overrides = get_letter_overrides(letter);
    height    = is_undef(overrides[3]) ? get_font_setting("height") : overrides[3];
    width     = is_undef(overrides[4]) ? get_font_setting("width")  : overrides[4];
    type      = is_undef(overrides[6]) ? get_font_setting("type")   : overrides[6];

    translate([0, -flap_height * height, 0])
    {
        scale([width, 1, 1])
        {
            offset_x = is_undef(overrides[1]) ? get_font_setting("offset_x") : get_font_setting("offset_x") + overrides[1];
            offset_y = is_undef(overrides[2]) ? get_font_setting("offset_y") : get_font_setting("offset_y") + overrides[2];
            translate([offset_x, offset_y])
            {
                if (type == "square")
                {
                    translate([0, flap_height * height]) square([flap_width, (flap_height * height * 2)], center = true);
                }
                else
                {
                    text(text=letter, size=flap_height * height * 2, font=get_font_setting("font"), halign="center", $fn=letter_facet_number);
                }
            }
        }
    }
}

