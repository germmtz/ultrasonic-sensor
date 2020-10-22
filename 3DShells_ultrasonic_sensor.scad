///////////////////////////////////////////////////
// PLASTIC SHELLS FOR THE ULTRASONIC ARDUINO-BASED PLANT HEIGHT MEASUREMENT DEVICE
///////////////////////////////////////////////////
// Author: Germain Montazeaud - g.montazeaud@gmail.com
// AGAP, Université de Montpellier, CIRAD, INRAE, Montpellier SupAgro, Montpellier, France
// &
// CEFE, Université de Montpellier, Montpellier SupAgro, CNRS, EPHE, IRD, Université Paul Valéry, Montpellier, France
// Licence Creative Common Attribution 4.0 International (CC BY 4.0)
//////////////////////////////////////////////////


//////////////////////////////////////////////
// SHELL FOR THE HC-SR04 ULTRASONIC SENSOR (Fig. 2A in the main text)
/////////////////////////////////////////////


// BOTTOM PART OF THE SHELL //
difference() {
// rectangle
cube([70,54,2.5]);
// Two holes for the sensor probes
translate([55,13.5,0]) cylinder(h=3,d=17,$fn=50);
translate([55,39.5,0]) cylinder(h=3,d=17,$fn=50);
}


// BACK OF THE SHELL
translate ([0,1,2]) cube([2,52,23]);
// Right triangular reinforcement
difference() {
translate ([0,10,2]) cube([7,2,15]);
translate ([7,10,2]) rotate([0,-20,0]) cube([7,2,16]);
}
// Left triangular reinforcement
difference() {
translate ([0,43,2]) cube([7,2,15]);
translate ([7,43,2]) rotate([0,-20,0]) cube([7,2,16]);
}


// SHELL COVER //
translate ([0,-1,-2]) {
    
difference() {
// Filled parallelogram
cube([71.5,56,29]);
// removing the inside and bottom side
translate([0,2,0]) cube([69.5,52,27]);
// adding a slide
translate ([0,1,2]) cube([70,54,3]);

}

// plunging part
// right side
translate([71.5,0,0])rotate([-90,90,0]) linear_extrude (height=2) polygon(points=[[0,0],[0,40],[70,30],[70,0]]);
// left side
translate([71.5,54,0])rotate([-90,90,0]) linear_extrude (height=2) polygon(points=[[0,0],[0,40],[70,30],[70,0]]);
// back side
translate([69.5,2,-70])cube([2,52,70]);
}





//////////////////////////////////////////////
// SHELL FOR THE ARDUINO BOARD, THE LCD SHIELD, THE SD CARD, AND THE POWER SUPPLY (Fig. 2B in the main text)
/////////////////////////////////////////////


// BOTTOM PART //
// Number of fragments for cylindrical parts
$fn=60;
// Defining a function for the bottom part of the shell
// (xdim=width, ydim=length, zdim=depth, rdim = cylinder radius
// , ep = thickness of the shell)

module roundedcube(xdim,ydim, zdim, rdim, ep){
difference(){
hull(){
translate ([rdim,rdim,0]) cylinder(h=zdim,r=rdim);
translate ([xdim-rdim,rdim,0]) cylinder(h=zdim,r=rdim);
translate ([rdim,ydim-rdim,0]) cylinder(h=zdim,r=rdim);
translate ([xdim-rdim,ydim-rdim,0]) cylinder(h=zdim,r=rdim);
}

translate([ep,ep,ep])
hull(){
translate ([rdim,rdim,0]) cylinder(h=zdim,r=rdim);
translate ([xdim-2*ep-rdim,rdim,0]) cylinder(h=zdim,r=rdim);
translate ([rdim,ydim-2*ep-rdim,0]) cylinder(h=zdim,r=rdim);
translate ([xdim-2*ep-rdim,ydim-2*ep-rdim,0]) cylinder(h=zdim,r=rdim);
}
}
}

// Defining the bottom part
translate([-150, 0, 0]){
difference() {
roundedcube (130,80,33,2,2); 
translate ([130-2,21.5,2]) cube([2,13,16]); // USB hole
translate ([130-2,52.5,2]) cube([2,10,16]); // alim hole
translate([27,78,2]) cube([4,2,25]); // SD card hole
}
// Addind cylinders in the 4 corners of the bottom part of the shell
translate ([4,4,0]) cylinder(h=31,r=2);
translate ([130-4,4,0]) cylinder(h=31,r=2);
translate ([4,80-4,0]) cylinder(h=31,r=2);
translate ([130-4,80-4,0]) cylinder(h=31,r=2);

// Adding some plastic around holes to guide connections from the oustide
translate([130-2-5,19+0.5,2]) cube([5,2,16]);
translate([130-2-5,19+15+0.5,2]) cube([5,2,16]);
translate([130-2-10,50+0.5,2]) cube([10,2,16]);
translate([130-2-10,50+2+10+0.5,2]) cube([10,2,16]);

// Adding 4 small cylinders to support the Arduino board
translate ([100.5,15.5,2]) cylinder(h=4,r=2.1);
translate ([50,31,2]) cylinder(h=4,r=2.1);
translate ([50,59,2]) cylinder(h=4,r=2.1);
translate ([100.5+1.3,59+5.1,2]) cylinder(h=4,r=2.1);

// Adding a compartment for the battery
translate ([23,78-50,2]) cube([2,50,25]);
}


// SHELL COVER //

// Defining a function for the shell cover
// (xdim=width, ydim=length, zdim=thickness)

module cover(xdim,ydim, zdim, rdim){
hull(){
translate ([rdim,rdim,0]) cylinder(h=zdim,r=rdim);
translate ([xdim-rdim,rdim,0]) cylinder(h=zdim,r=rdim);
translate ([rdim,ydim-rdim,0]) cylinder(h=zdim,r=rdim);
translate ([xdim-rdim,ydim-rdim,0]) cylinder(h=zdim,r=rdim);
}
}

// Defining a function for push buttons
// (r_base = radius of the base, r_main = radius of the main part, height = buttons'height)
module bouton(r_base, r_main, height) {
    union() {
    cylinder(h=2, r=r_base);
    cylinder(h=height, r=r_main);
    }
}

// Creating the shell cover
translate([-148, 2, 33]){

difference() {
cover(126,76,2,2);
translate([49+1,47-24-0.5,0]) rotate([0,0,-0.85])cube([72,25,2]);
translate([49+72-17.5,47+9-2,-3]) {
bouton(2.5,2,7);
translate([0,6.5,0]) bouton(2.5,2,7);
translate([-10,4.5,0]) bouton(2.5,2,7);
}
translate([49+72-1.5,47-24-11.5-2,0]) cylinder(h=2,r=1.5);
}

}



// BUTTONS //
// Creating buttons
translate([-44.5, 56, 32]){

bouton(2.5,1.5,7);
translate([0,6.5,0]) bouton(2.5,1.5,7);
translate([-10,4.5,0]) bouton(2.5,1.5,7);
translate ([-1/2,0,0]) cube([1,7,0.5]);
rotate([0,0,-10]) translate ([-10.5,2.5,0]) cube([10,1,0.5]);

}
