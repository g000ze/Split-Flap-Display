include<3D_library.scad>;


module chassis(){
    // Gehäuse Seiten:
    union()
    {
        color("grey")
        {
            // Rechts mit grossem Ausschnitt
            chassis_right();

            // Links mit Löcher für Motor
            chassis_left();

            // Front
            chassis_front();
        }
    }
}

rotate([-90,0,0]) chassis();

