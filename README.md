## Intro
Older people (like me) look back with nostalgia at train stations and airports, middle-aged people are captivated by technology, and the younger generation is excited by the clattering sound combined with the non-virtual movement. The split flap display remains a fascinating display panel for text and small animations.

One day, while watching a video about split flap displays, I suddenly felt the desire to own one. After a relatively short research, I realized that only a few manufacturers build such displays. There are, for example, [Oat Foundry](https://www.oatfoundry.com/), [Vestaboard](https://www.vestaboard.com/), [Scott Bezek](https://github.com/scottbez1/splitflap) or the one called "Split Flap Display Manufacturer." No matter which manufacturer you choose, the displays are either very expensive or don't meet my requirements. So I decided to try building one myself.

[![DIY Split Flap Display on YouTube](https://img.youtube.com/vi/JR2ThV7CSwY/maxresdefault.jpg)](https://youtu.be/JR2ThV7CSwY?si=3bZnhtjU7jKmc7q2)

A typical split flap display looks best when it can display text. This text is naturally composed of characters, i.e., letters, numbers, and special characters. Optionally, symbols, colors, or images can also be displayed. A character is represented on the display by a so-called module. A module consists of a housing, a stepper motor, a motor driver, a PCB that connects the driver and the motor, a carousel, 50 flaps for the characters, and, of course, various spacers and screws that hold the whole thing together. A magnetic sensor (Hall effect sensor) is also integrated into the carousel, which tells the microprocessor when position 0 or the home position has been reached.

As already mentioned, a single module produces little effect, so we want multiple modules for a display to achieve an intense visual effect. I decided to control eight modules with an [Arduino Micro](https://docs.arduino.cc/hardware/micro/). The modules therefore always come in packs of eight. The Micro offers 20 digital input/output pins. Two of these are required per module: an output pin as a stepper for the driver and an input pin for the Hall effect sensor to determine the feedback for a full rotation of the carousel. This means a total of 16 Arduino pins are used for eight modules. The Arduino, in turn, is placed on the backplane PCB, where the modules are plugged into so-called card edge connectors. This PCB primarily controls two things:
- The digital communication between the Arduino and the modules (drivers & Hall sensors)
- The power supply for all electronics, including the motors

**Animation of spinning spool using OpenSCAD**

[![Spinning Carousel](https://g000ze.github.io/docs/index.html)](https://github.com/user-attachments/assets/af98eea6-6dcd-4d9f-962c-459cd9d655be)

[![Exploded View]](https://github.com/user-attachments/assets/ecffe0bf-9c8d-47f0-b8ce-c02ede4a916f)

## The Housing
The housing is used to position the motor, along with the carousel and flaps, as well as the PCB with the Hall sensor. If everything is exactly right, the flaps will drop at the right time and the magnet will move correctly over the sensor. I used 0.8 mm sheet steel for the housing. The 3D OpenSCAD drawing can be found [here](https://github.com/g000ze/Split-Flap-Display/blob/main/OpenSCAD/Chassis.scad). I found a company in Switzerland called [Blexon](https://blexon.com), that will punch and bend the housing according to my specifications.

<img width="567" alt="Housing" src="https://github.com/user-attachments/assets/7d457f1f-1d2f-4849-aac7-7d4a1348fe1a" />

## The Stepper Motor
Normally, Nema 17 stepper motors are mounted on the side where the shaft is located. This display is different; the motor must be mounted on one side, and the shaft, where the carousel is screwed to, must be on the opposite side. The [17HS13-0404D](https://www.omc-stepperonline.com/de/doppel-schacht-nema-17-bipolar-1-8deg-26ncm-36-8oz-in-0-4a-12v-42x34mm-4-draehte-17hs13-0404d) is the only Nema 17 I could find with the shaft on the opposite side from where it is mounted. This motor is actually a "dual shaft" motor. The 17HS13-0404D is powered by +12 volts.

<img width="340" alt="17HS13-0404D" src="https://github.com/user-attachments/assets/5ccef8f6-140d-484a-8c40-83faac180ccc" />

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

<img width="567" alt="PCB Module" src="https://github.com/user-attachments/assets/ab931367-9ad7-4703-a052-73e8839e27a8" />
<img width="1418" alt="PCB Backplane" src="https://github.com/user-attachments/assets/a44f44f3-0cbd-4914-85cf-c44a03d4fe48" />

## The Carousel
The Carousel is attached to the pouley on the motor shaft so that it can be rotated by the steppermotor. It also holds the 50 flaps in position. The stepper motor is located inside the carousel. With its 82mm diameter, the carousel fits perfectly around the motor and there's enough space for the 50 flap positions. The two wheels are different, as the left wheel contains spokes, while the right wheel is open.

<img width="959" alt="Carousel" src="https://github.com/user-attachments/assets/9ac454af-4406-4b10-8f1c-81b2ef74c5dd" />

I decided to use 3mm PVC plates for the carousel. A company named [Waterjet](https://www.waterjet.ch/) located in Switzerland did the water cutting to cut out the carousel wheels.

## The Pouley
The pouley connects the motor and the carousel together. [This](https://www.pololu.com/product/1998) one was actually the only one I found to suit the motor shaft. So I bought it, even though it is insanely overpriced.

## The Flaps
The flaps are the essential parts, since they show the text that you want to see. Basically almost all kind of fonts, characters, signs and pictures are possible. After endless searching, trying and disapointments, I found a company named [Ren Peck](http://www.ren-peck.com/) in China who was willing to create what I am looking for. In fact it is the very same company that created the flaps for [Scott Bezek](https://github.com/scottbez1/splitflap)s Split Flap Display. 

<img width="851" alt="Flaps" src="https://github.com/user-attachments/assets/ca76837a-219c-4259-87e0-854e23e6e386" />

## The Software

## Other

## Tools Used
- OpenSCAD: https://openscad.org/
- KiCad: https://www.kicad.org/
- FreeCAD: https://www.freecad.org/
- For the Raspberry Pi to communicate with Arduino using I2C, I used this extension: https://github.com/tasoftch/php-i2c-extension






