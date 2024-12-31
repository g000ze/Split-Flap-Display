#include </Users/stefan/Documents/Arduino/Split_Flap/inputs/inputs.ino>
#include <Wire.h>

// motor and flap settings
const byte microsteps = 16;   // Microsteps for the driver
const byte motorsteps = 200;  // Stepper motor takes 200 positions per revolution
const byte flaps = 50;        // number of flaps on carrousel
const word ms_per_revolution = motorsteps * microsteps; // microsteps performed by carousel revolution
const word ms_per_flap = ms_per_revolution / flaps; // microsteps performed by flap position

/*
 Speed: The greater the number the slower it turns.
 28800 / microsteps is approximately 6 seconds per revolution.

 grundsätzlich ist jede Geschwindigkeit möglich, solange
 sie sich durch 32 (Anz. max. Microsteps) teilen lässt.
 slow:   38400
 normal: 28800
 fast:   19200
 stress: 9600
 */
const long speed = 28800 / microsteps;

// Number of modules
const byte modules = 8;

// array settings
// As of Backplane V2 PCB

//////////////////////////////
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
//////////////////////////////

/*
const byte hall_pin_0 = 6;
const byte step_pin_0 = 0;
*/

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

word cur_ms_pos[modules]          = {};
word new_ms_pos[modules]          = {};
int  ms_to_go[modules]            = {};
char new_char[modules]            = {};
bool set_ms_pos[modules]          = {};

// Feineinstellung
const word init_ms_pos[modules]   = {50, 10, 10, 10, 10, 10, 10, 10};

void setup() {
  Serial.begin(9600);

  /*
  // Join I2C bus as slave with uniqe address
  Wire.begin(0x0b);
  // set I2C receive and request functions
  Wire.onReceive(receive_i2c_event);
  Wire.onRequest(request_i2c_event);
  */
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

// ToDo XXX
//#include </Users/stefan/Documents/Arduino/Split_Flap/output/output.ino>

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
      /*
      if(cur_ms_pos[module] > ms_per_revolution){
        // magnet behind counter
      }
      if(cur_ms_pos[module] < ms_per_revolution - 1){
        // magnet before counter
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
  word new_flap_pos = get_position(new_char[module]);
  new_ms_pos[module] = new_flap_pos * ms_per_flap;

  // proceed only if a valid character has been provided
  if(new_flap_pos == 0){
    new_ms_pos[module] = 0;
    return;
  }

  // pretend to be on correct position, even if magnet has not been spotted
  int position = cur_ms_pos[module] % ms_per_revolution;

  // do the magic!
  if(new_ms_pos[module] > position){
    ms_to_go[module] = new_ms_pos[module] + init_ms_pos[module] - position;
  }else{
    ms_to_go[module] = new_ms_pos[module] + init_ms_pos[module] + (ms_per_revolution - position);
  }
}

bool is_valid_module(byte module) {
    return module < modules;
}

bool is_magnet_home(byte module){
  if (digitalRead(hall_pin[module]) == 0) {
    return true;
  }
  return false;
}

bool is_running(byte module){
  if (ms_to_go[module] > 0) {
    return true;
  }
  return false;
}

/*
 * serial events
 */
void receive_serial_event(){
  if(Serial.available() > 0){
    String content = Serial.readStringUntil('\n');
    for(byte module = 0; module < modules; module++){
      //new_char[module] = Serial.read();
      new_char[module] = content.charAt(module);
      set_ms_to_go(module);
    }
  }
}

/*
 * I2C events
 */
void receive_i2c_event(int bytes){
  // the first byte is the register which sends the php lib. Drop it!
  int trash = Wire.read();
  byte module = 0;
  while(Wire.available() > 0){
    char content = Wire.read();
    new_char[module] = content;
    set_ms_to_go(module);
    module++;
  }
}

void request_i2c_event(){
  for(byte module = 0; module < modules; module++){
    if(ms_to_go[module] > 0){
      Wire.write(255);
    }else{
      // ToDo XXX
      //Wire.write(cur_flap_pos[module]);
      Wire.write(cur_ms_pos[module]);
    }
  }
}

