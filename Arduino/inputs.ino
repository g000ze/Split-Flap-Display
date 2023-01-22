// https://de.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange

int get_position(int input){
  int output = 0;
  switch (input) {
    // numbers
    case 48: // 0
      output = 1;
      break;
    case 49: // 1
      output = 2;
      break;
    case 50: // 2
      output = 3;
      break;
    case 51: // 3
      output = 4;
      break;
    case 52: // 4
      output = 5;
      break;
    case 53: // 5
      output = 6;
      break;
    case 54: // 6
      output = 7;
      break;
    case 55: // 7
      output = 8;
      break;
    case 56: // 8
      output = 9;
      break;
    case 57: // 9
      output = 10;
      break;

    // alphabeth a - z
    case 65: // A
    case 97: // a
      output = 11;
      break;
    case 66: // B
    case 98: // b
      output = 12;
      break;
    case 67: // C
    case 99: // c
      output = 13;
      break;
    case 68: // D
    case 100: // d
      output = 14;
      break;
    case 69: // E
    case 101: // e
      output = 15;
      break;
    case 70: // F
    case 102: // f
      output = 16;
      break;
    case 71: // G
    case 103: // g
      output = 17;
      break;
    case 72: // H
    case 104: // h
      output = 18;
      break;
    case 73: // I
    case 105: // i
      output = 19;
      break;
    case 74: // J
    case 106: // j
      output = 20;
      break;
    case 75: // K
    case 107: // k
      output = 21;
      break;
    case 76: // L
    case 108: // l
      output = 22;
      break;
    case 77: // M
    case 109: // m
      output = 23;
      break;
    case 78: // N
    case 110: // n
      output = 24;
      break;
    case 79: // O
    case 111: // o
      output = 25;
      break;
    case 80: // P
    case 112: // p
      output = 26;
      break;
    case 81: // Q
    case 113: // q
      output = 27;
      break;
    case 82: // R
    case 114: // r
      output = 28;
      break;
    case 83: // S
    case 115: // s
      output = 29;
      break;
    case 84: // T
    case 116: // t
      output = 30;
      break;
    case 85: // U
    case 117: // u
      output = 31;
      break;
    case 86: // V
    case 118: // v
      output = 32;
      break;
    case 87: // W
    case 119: // w
      output = 33;
      break;
    case 88: // X
    case 120: // x
      output = 34;
      break;
    case 89: // Y
    case 121: // y
      output = 35;
      break;
    case 90: // Z
    case 122: // z
      output = 36;
      break;

    // special characters
    case 33: //  !
      output = 37;
      break;
    case 37: //  %
      output = 38;
      break;
    case 38: //  &
      output = 39;
      break;
    case 42: //  *
      output = 40;
      break;
    case 43: //  +
      output = 41;
      break;
    case 45: //  -
      output = 42;
      break;
    case 46: //  .
      output = 43;
      break;
    case 47: //  /
      output = 44;
      break;
    case 58: //  :
      output = 45;
      break;
    case 63: //  ?
      output = 46;
      break;
    case 36: // $
      output = 47;
      break;
    case 64: // @
      output = 48;
      break;
    case 35: // #
      output = 49;
      break;

    // this is null or home
    case 32: // " " (space)
      output = 50;
      break;

    //default:
    //  output = 0;
    //  break;
  }
  return output;
}

