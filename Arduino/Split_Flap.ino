#include <inputs/inputs.ino>
#include <Wire.h>

// motor and flap settings
const byte microsteps = 16;   // Microsteps for the driver
const byte motorsteps = 200;  // Stepper motor takes 200 positions per revolution
const byte flaps = 50;        // number of flaps on carrousel
const int ms_per_revolution = motorsteps * microsteps; // microsteps performed by carousel revolution
const int ms_per_flap = ms_per_revolution / flaps; // microsteps performed by flap position

/*
 Speed: The greater the number the slower it turns.
 28800 / microsteps is approximately 6 seconds per revolution.

 grundsätzlich ist jede Geschwindigkeit möglich, solange
 sie sich durch 32 (Anz. max. Microsteps) teilen lässt.
 sneak:  128000
 slow:   38400
 normal: 28800
 fast:   19200
 stress: 9600
 */
const unsigned long speed = 28800 / microsteps;

// Number of modules
const byte modules = 8;

// array settings
// As of Backplane V2 PCB
#include <inputs/pins_v2.ino>
//// example /////////////////
/*
const byte hall_pin_0 = 18;
const byte hall_pin_1 = 19;
const byte hall_pin_2 = 20;
const byte hall_pin_3 = 21;
const byte hall_pin_4 = 9;
const byte hall_pin_5 = 10;
const byte hall_pin_6 = 11;
const byte hall_pin_7 = 12;

const byte step_pin_0 = 15;
const byte step_pin_1 = 14;
const byte step_pin_2 = 23;
const byte step_pin_3 = 22;
const byte step_pin_4 = 5;
const byte step_pin_5 = 4;
const byte step_pin_6 = 17;
const byte step_pin_7 = 16;
*/
//////////////////////////////

const byte hall_pin[modules] =
{
    hall_pin_0,
    hall_pin_1,
    hall_pin_2,
    hall_pin_3,
    hall_pin_4,
    hall_pin_5,
    hall_pin_6,
    hall_pin_7,
};

const byte step_pin[modules] =
{
    step_pin_0,
    step_pin_1,
    step_pin_2,
    step_pin_3,
    step_pin_4,
    step_pin_5,
    step_pin_6,
    step_pin_7,
};

// some other things
unsigned long curr_time = 0;
unsigned long prev_time = 0;

int  cur_ms_pos[modules]          = {};
int  new_ms_pos[modules]          = {};
int  ms_to_go[modules]            = {};
char new_char[modules]            = {};
bool set_ms_pos[modules]          = {};

// Feineinstellung
const int init_ms_pos[modules]   = {43, 43, 43, 43, 43, 43, 43, 43};

void setup() {
  Serial.begin(9600);

  // Join I2C bus as slave with uniqe address
  Wire.begin(0x0b);
  // set I2C receive and request functions
  Wire.onReceive(receive_i2c_event);
  Wire.onRequest(request_i2c_event);

  // setup pins and variables
  for(byte module = 0; module < modules; module++){
    pinMode(step_pin[module], OUTPUT);
    pinMode(hall_pin[module], INPUT);

    // ascii 32 is space character
    new_char[module] = 32;
    cur_ms_pos[module] = 0;
    set_ms_pos[module] = false;
    set_ms_to_go(module);
  }
}

void loop() {
  motor_run();
  receive_serial_event();
}

void motor_run(){
  curr_time = micros();
  if((curr_time - prev_time) >= speed){
    prev_time = curr_time;
    for(byte module = 0; module < modules; module++){
      if(ms_to_go[module] > 0){
        digitalWrite(step_pin[module], HIGH);
        digitalWrite(step_pin[module], LOW);
        update_ms_pos(module);
      }
    }
  }
}

void update_ms_pos(byte module){
  cur_ms_pos[module]++;
  ms_to_go[module]--;

  // reset cur_ms_pos only once if magnet is at home place
  if(is_magnet_home(module)){
    if(set_ms_pos[module]){
      // uncomment for debugging purposes.
      /*      
      if(cur_ms_pos[module] > ms_per_revolution){
        Serial.print("magnet behind counter ");
      }
      if(cur_ms_pos[module] < ms_per_revolution - 1){   // weshalb - 1 ?
        Serial.print("magnet before counter ");
      }
      */

      cur_ms_pos[module] = 0;

      // instant adjustment of microsteps to go
      if(new_ms_pos[module] != ms_per_revolution){
        set_ms_to_go(module);
      }else{
        ms_to_go[module] = init_ms_pos[module];
      }
    }
    set_ms_pos[module] = false;
  }else{
    /*
    // wait for magnet after one revolution
    if(cur_ms_pos[module] >= ms_per_revolution){
      if(cur_ms_pos[module] <= (ms_per_revolution * 3)){
        ms_to_go[module] = 1;
      }
    }
    */
    set_ms_pos[module] = true;
  }
}

/*
case 1:
if new position is greater than current position, go straight forward
positions to walk = new - cur
cur = 6
new = 30
30 - 6 = 24

case 2:
if new position is smaller than current position, recalculate respecting flap positions
positions to walk = (flaps - cur) + new
cur = 44
new = 30
(50 - 44) + 30 = 36
*/
void set_ms_to_go(byte module){
  unsigned int new_flap_pos = get_position(new_char[module]);
  // proceed only if a valid character has been provided
  if(new_flap_pos == 0){
    return;
  }

  new_ms_pos[module] = new_flap_pos * ms_per_flap;

  // pretend to be on correct position, even if magnet has not been spotted
  int position = cur_ms_pos[module] % ms_per_revolution;

  // do the magic!
  if(new_ms_pos[module] > position){
    ms_to_go[module] = new_ms_pos[module] + init_ms_pos[module] - position;
  }else{
    ms_to_go[module] = new_ms_pos[module] + init_ms_pos[module] + (ms_per_revolution - position);
  }
}

bool is_magnet_home(byte module) {
  return (digitalRead(hall_pin[module]) == 0);
}

bool is_running(byte module) {
  return (ms_to_go[module] > 0);
}

/*
 * serial events
 */

void receive_serial_event() {
  if (!Serial.available()) {
    return;
  }

  String content = Serial.readStringUntil('\n');
  for (byte module = 0; module < modules && module < content.length(); module++) {
    new_char[module] = content.charAt(module);
    set_ms_to_go(module);
  }
}

/*
 * I2C events
 */
void receive_i2c_event(int bytes) {
  // at least one byte must be given
  if (bytes <= 0) {
    return;
  }

  // ignore the first byte (register-byte)
  if (Wire.available() > 0) {
    Wire.read();
  }

  // Version von Chat GPT
  for (byte module = 0; module < modules && Wire.available() > 0; module++) {
  //while(Wire.available() > 0){
    for (byte module = 0; module < modules; module++) {
      new_char[module] = Wire.read();
      set_ms_to_go(module);
    }
  }
}

void request_i2c_event(){
  for(byte module = 0; module < modules; module++){
    if(ms_to_go[module] > 0){
      Wire.write(255);
    }else{
      //round, in case something ran out of count
      Wire.write(round((float)(cur_ms_pos[module] - init_ms_pos[module]) / ms_per_flap));
      //Wire.write((cur_ms_pos[module] - init_ms_pos[module]) / ms_per_flap);
    }
  }
}
