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
                karussell_scheibe_rechts();
            }
            else
            {
                karussell_scheibe_links();
            }
        }
    }
}
