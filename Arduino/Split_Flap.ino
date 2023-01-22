#include <inputs.ino>
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
// Can be extended to 8 per Arduino.
const byte modules = 6;

// array settings
const byte hall_pin_0 = 4;
const byte hall_pin_1 = 5;
const byte hall_pin_2 = 6;
const byte hall_pin_3 = 7;
const byte hall_pin_4 = 8;
const byte hall_pin_5 = 9;
const byte hall_pin_6 = 10;
const byte hall_pin_7 = 11;

const byte step_pin_0 = 18;
const byte step_pin_1 = 19;
const byte step_pin_2 = 20;
const byte step_pin_3 = 21;
const byte step_pin_4 = 22;
const byte step_pin_5 = 23;
const byte step_pin_6 = 24;
const byte step_pin_7 = 25;

// some other things
unsigned long curr_time = 0;
unsigned long prev_time = 0;

const byte hall_pin[modules] =
{
    hall_pin_0,
    hall_pin_1,
    hall_pin_2,
    hall_pin_3,
    hall_pin_4,
    hall_pin_5,
//    hall_pin_6,
//    hall_pin_7,
};

const byte step_pin[modules] =
{
    step_pin_0,
    step_pin_1,
    step_pin_2,
    step_pin_3,
    step_pin_4,
    step_pin_5,
//    step_pin_6,
//    step_pin_7,
};

word cur_ms_pos[modules]          = {};
word new_ms_pos[modules]          = {};
int  ms_to_go[modules]            = {};

byte cur_flap_pos[modules]        = {};
byte new_flap_pos[modules]        = {};
byte flap_pos_to_go[modules]      = {};

char new_char[modules]            = {};

int home_ms_pos[modules]          = {};

// Feineinstellung
const word init_ms_pos[modules]   = {24, 24, 24, 24, 24, 32,};

bool enabled[modules]             = {};


void setup() {
  Serial.begin(57600);

  // Join I2C bus as slave with uniqe address
  Wire.begin(0x0b);
  // set I2C receive and request functions
  Wire.onReceive(receive_i2c_event);
  Wire.onRequest(request_i2c_event);

  // setup pins and variables
  for(byte module = 0; module < modules; module++){
    pinMode(step_pin[module], OUTPUT);
    pinMode(hall_pin[module], INPUT);

    new_char[module] = 32;

    cur_ms_pos[module] = 0;
    set_ms_to_go(module);

    cur_flap_pos[module]    = flaps;
    new_flap_pos[module]    = 0;
    flap_pos_to_go[module]  = 0;

    // get away from home for initial revolution on startup
    home_ms_pos[module] = ms_per_flap;

    enabled[module]  = true;
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
      if(enabled[module]){
        if(ms_to_go[module] > 0){
          digitalWrite(step_pin[module], HIGH);
          digitalWrite(step_pin[module], LOW);  
          update_ms_pos(module);
          update_flap_pos(module);
        }
      }
    }
  }
}

void reset_home_pos(byte module){
  // take care if destination is also home position
  if(new_ms_pos[module] == ms_per_revolution){
    if(cur_ms_pos[module] < new_ms_pos[module]){
      // magnet has been spotted too early
      ms_to_go[module] = 0;
    }else if(cur_ms_pos[module] > new_ms_pos[module]){
      // go extra round if too late
      ms_to_go[module] = new_ms_pos[module];
    }else{
      // everything ok
      ms_to_go[module] = 0;
    }
    cur_ms_pos[module] = 0;
  }else{
    // this is the normal case
    cur_ms_pos[module] = 0;
    set_ms_to_go(module);
  }
}

void update_ms_pos(byte module){
  cur_ms_pos[module]++;
  ms_to_go[module]--;

  if(is_magnet_home(module)){
    if(home_ms_pos[module] == init_ms_pos[module]){
      reset_home_pos(module);
    }
    home_ms_pos[module]++;
  }else{
    home_ms_pos[module] = 0;
  }

  // is hall sensor actually responding?
  if(cur_ms_pos[module] >= ms_per_revolution * 3){
    Serial.println(" --> Hall sensor did not respond for 3 revolutions");
    stats(module);
    enabled[module] = false;
  }
}

void update_flap_pos(byte module){
  // flap position zwischen den ms positions einmitten
  if((cur_ms_pos[module] + (ms_per_flap / 2)) % ms_per_flap == 0){
    cur_flap_pos[module] = ((cur_ms_pos[module] + (ms_per_flap / 2)) / ms_per_flap);
    if(new_flap_pos[module] > cur_flap_pos[module]){
      flap_pos_to_go[module] = new_flap_pos[module] - cur_flap_pos[module];
    }else{
      flap_pos_to_go[module] = (flaps - cur_flap_pos[module]) + new_flap_pos[module];
    }
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
  new_flap_pos[module] = get_position(new_char[module]);
  new_ms_pos[module] = new_flap_pos[module] * ms_per_flap;

  // proceed only if a valid character has been provided
  if(new_flap_pos[module] == 0){
    new_ms_pos[module] = 0;
    return;
  }

  // pretend to be on correct position, if magnet has not been spotted
  int counter = 0;
  if(cur_ms_pos[module] > ms_per_revolution){
    counter = cur_ms_pos[module] - ((cur_ms_pos[module] / ms_per_revolution) * ms_per_revolution);
  }else{
    counter = cur_ms_pos[module];    
  }

  // do the magic!
  if(new_ms_pos[module] > counter){
    ms_to_go[module] = new_ms_pos[module] - counter;
  }else{
    ms_to_go[module] = (ms_per_revolution - counter) + new_ms_pos[module];
  }
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
    if(enabled[module]){
      if(ms_to_go[module] > 0){
        Wire.write(255);
      }else{
        Wire.write(cur_flap_pos[module]);
      }
    }else{
      Wire.write(0);
    }
  }
}

void stats(byte module){
  Serial.print(" module: ");
  Serial.println(module);
  Serial.print("   cur_ms_pos: ");
  Serial.println(cur_ms_pos[module]);
  Serial.print("   new_ms_pos: ");
  Serial.println(new_ms_pos[module]);
  Serial.print("   ms_to_go:   ");
  Serial.println(ms_to_go[module]);
  Serial.println("");
}

