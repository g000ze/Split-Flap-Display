## Intro
Older people (like me) look back with nostalgia at train stations and airports, middle-aged people are captivated by technology, and the younger generation is excited by the clattering sound combined with the non-virtual movement. The split flap display remains a fascinating display panel for text and small animations.

One day, while watching a video about split flap displays, I suddenly felt the desire to own one. After a relatively short research, I realized that only a few manufacturers build such displays. There are, for example, [Oat Foundry](https://www.oatfoundry.com/), [Vestaboard](https://www.vestaboard.com/), [Scott Bezek](https://github.com/scottbez1/splitflap) or the one called "Split Flap Display Manufacturer." No matter which manufacturer you choose, the displays are either very expensive or don't meet my requirements. So I decided to try building one myself.

[![DIY Split Flap Display on YouTube](https://img.youtube.com/vi/JR2ThV7CSwY/maxresdefault.jpg)](https://youtu.be/JR2ThV7CSwY?si=3bZnhtjU7jKmc7q2)

A typical split flap display looks best when it can display text. This text is naturally composed of characters, i.e., letters, numbers, and special characters. Optionally, symbols, colors, or images can also be displayed. A character is represented on the display by a so-called module. A module consists of a housing, a stepper motor, a motor driver, a PCB that connects the driver and the motor, a carousel, 50 flaps for the characters, and, of course, various spacers and screws that hold the whole thing together. A magnetic sensor (Hall effect sensor) is also integrated into the carousel, which tells the microprocessor when position 0 or the home position has been reached.

As already mentioned, a single module produces little effect, so we want multiple modules for a display to achieve an intense visual effect. I decided to control eight modules with an [Arduino Micro](https://docs.arduino.cc/hardware/micro/). The modules therefore always come in packs of eight. The Micro offers 20 digital input/output pins. Two of these are required per module: an output pin as a stepper for the driver and an input pin for the Hall effect sensor to determine the feedback for a full rotation of the carousel. This means a total of 16 Arduino pins are used for eight modules. The Arduino, in turn, is placed on the backplane PCB, where the modules are plugged into so-called card edge connectors. This PCB primarily controls two things:
- The digital communication between the Arduino and the modules (drivers & Hall sensors)
- The power supply for all electronics, including the motors

**Animation of spinning spool using OpenSCAD**

https://github.com/user-attachments/assets/f0f93f7b-00a4-478b-8500-96269c6c5e51

## The Housing
The housing is used to position the motor, along with the carousel and flaps, as well as the PCB with the Hall sensor. If everything is exactly right, the flaps will drop at the right time and the magnet will move correctly over the sensor. I used 0.8 mm sheet steel for the housing. The 3D OpenSCAD drawing can be found [here](https://github.com/g000ze/Split-Flap-Display/blob/main/OpenSCAD/Chassis.scad). I found a company in Switzerland called [Blexon](https://blexon.ch), that will punch and bend the housing according to my specifications.

## The Stepper Motor
Normally, Nema 17 stepper motors are mounted on the side where the shaft is located. This display is different; the motor must be mounted on one side, and the shaft, where the carousel is screwed to, must be on the other side. The [17HS13-0404D](https://www.omc-stepperonline.com/de/doppel-schacht-nema-17-bipolar-1-8deg-26ncm-36-8oz-in-0-4a-12v-42x34mm-4-draehte-17hs13-0404d) is the only Nema 17 I could find with the shaft on the opposite side from where it is mounted. This motor is actually a "dual shaft" motor. The 17HS13-0404D is powered by +12 volts.

## The Driver
To operate a stepper motor, you need a driver. There are many. I experimented with stepper motor drivers for a long time until I finally came across the TMC2208 "Silent Step Stick" from [Watterott](https://learn.watterott.com/de/silentstepstick/). This driver allows the 17HS13-0404D to run almost silently. Finally, the sound of a split-flap display plays a crucial role. We want to hear only the flaps clattering, not the motors.

## The PCBs
Two different types of PCBs are required. One is a small PCB that is attached to each module. It essentially carries the driver and the Hall sensor. The other is the backplane PCB, which connects the Arduino's electronic wires to the eight modules via card-edge connectors. The six connections that run via the card-edge connectors are:
- Hall sensor
- GND
- +5V
- Step
- GND
- +12V

The TMC2208 and the Hall sensor on the module PCB each operate at +5 VCC, while the motor naturally requires 12 volts.

## The Carousel
The Carousel is attached to the pouley on the motor shaft so that it can be rotated by the steppermotor. It also holds the 50 flaps in position. The stepper motor is located inside the carousel. With its 82mm diameter, the carousel fits perfectly around the motor and there's enough space for the 50 flap positions. The two wheels are different, as the left wheel contains spokes, while the right wheel is open.
![Carousel](https://github.com/user-attachments/assets/d797df04-d1a4-482a-b0e6-0794be64aacd)

I decided to use 3mm PVC plates for the carousel. A company named [Waterjet](https://www.waterjet.ch/) located in Switzerland did the water cutting to cut out the carousel wheels.

## The Flaps

<img width="1298" alt="Overallview" src="https://github.com/user-attachments/assets/38d25479-a005-4a71-952e-5d17faed29d9" />

## The Software

## Other

## Tools Used
- OpenSCAD: https://openscad.org/
- KiCad: https://www.kicad.org/
- FreeCAD: https://www.freecad.org/
- For the Raspberry Pi to communicate with Arduino using I2C, I used this extension: https://github.com/tasoftch/php-i2c-extension






