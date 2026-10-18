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

// character -> flap position lookup (uppercase letters only; lowercase is
// converted before lookup). Characters not listed here are unsupported.
// A character's flap position is its index in this array plus one.
// https://de.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange
const char char_positions[] = {
  '0', 'A', 'B', 'C', 'D',
  '1', 'E', 'F', 'G', 'H',
  '2', 'I', 'J', 'K', 'L',
  '3', 'M', 'N', 'O', 'P',
  '4', 'Q', 'R', 'S', 'T',
  '5', 'U', 'V', 'W', 'X',
  '6', 'Y', 'Z', '+', '-',
  '7', '?', '!', '.', ',',
  '8', '@', ':', ';', '#',
  '9', '*', '$', '/', ' ',
};

// Arduino pin settings
// as of Backplane V3 PCB
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
const int UNSET = -1;
int init_ms_pos[modules] = {UNSET, UNSET, UNSET, UNSET, UNSET, UNSET, UNSET, UNSET};
//const int init_ms_pos[modules]   = {20, 20, 20, 20, 20, 20, 20, 20};

// read values out of EEPROM
#include <EEPROM.h>
const int i2c_addr            = EEPROM.read(0);
const int default_init_ms_pos = EEPROM.read(1);

void setup() {
  Serial.begin(9600);

  // Join I2C bus as slave with uniqe address
  Wire.begin(i2c_addr);
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

    if (init_ms_pos[module] == UNSET) {
      init_ms_pos[module] = default_init_ms_pos;
    }

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
      if(is_running(module)){
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
  // convert lowercase to uppercase letters.
  byte c = new_char[module];
  if (c >= 'a' && c <= 'z') {
    c &= ~32;
  }

  unsigned int new_flap_pos = 0;
  for (byte i = 0; i < sizeof(char_positions) / sizeof(char_positions[0]); i++) {
    if (char_positions[i] == c) {
      new_flap_pos = i + 1;
      break;
    }
  }

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
  // register byte verwerfen
  Wire.read();

  // Maximal nur `modules` Bytes einlesen
  for (byte module = 0; module < modules && Wire.available(); module++) {
    byte b = Wire.read();

    // nur druckbare ASCII-Zeichen akzeptieren
    // https://www.eso.org/~ndelmott/ascii.html
    if (b >= 0x20 && b <= 0x7E) {
      new_char[module] = b;
      set_ms_to_go(module);
    }
  }

  // Rest verwerfen falls mehr als 8 Bytes geschickt wurden
  while (Wire.available()) Wire.read();
}

void request_i2c_event(){
  for(byte module = 0; module < modules; module++){
    if(is_running(module)){
      Wire.write(255);
    }else{
      //round, in case something ran out of count
      int flap_pos = round((float)(cur_ms_pos[module] - init_ms_pos[module]) / ms_per_flap);
      // wrap into [0, flaps) so a resync-induced negative offset never collides
      // with the 255 "still moving" sentinel above
      flap_pos = ((flap_pos % (int)flaps) + flaps) % flaps;
      Wire.write((byte)flap_pos);
    }
  }
}

