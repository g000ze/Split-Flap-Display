// https://de.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange
// Col Dez

/*
               "0", "A", "B", "C", "D",
               "1", "E", "F", "G", "H",
               "2", "I", "J", "K", "L",
               "3", "M", "N", "O", "P",
               "4", "Q", "R", "S", "T",
               "5", "U", "V", "W", "X",
               "6", "Y", "Z", "+", "-",
               "7", "?", "!", ".", ",",
               "8", "@", ":", ";", "#",
               "9", "*", "$", "/", " ",
*/

int get_position(int input){
    // convert lowercase to uppercase letters.
    if ((input >= 'a' && input <= 'z') || (input >= 'A' && input <= 'Z')) {
        input = input & ~32;
    }

    switch (input) {
    case 48:  return  1;    // 0
    case 65:  return  2;    // A
    case 66:  return  3;    // B
    case 67:  return  4;    // C
    case 68:  return  5;    // D
    case 49:  return  6;    // 1
    case 69:  return  7;    // E
    case 70:  return  8;    // F
    case 71:  return  9;    // G
    case 72:  return 10;    // H
    case 50:  return 11;    // 2
    case 73:  return 12;    // I
    case 74:  return 13;    // J
    case 75:  return 14;    // K
    case 76:  return 15;    // L
    case 51:  return 16;    // 3
    case 77:  return 17;    // M
    case 78:  return 18;    // N
    case 79:  return 19;    // O
    case 80:  return 20;    // P
    case 52:  return 21;    // 4
    case 81:  return 22;    // Q
    case 82:  return 23;    // R
    case 83:  return 24;    // S
    case 84:  return 25;    // T
    case 53:  return 26;    // 5
    case 85:  return 27;    // U
    case 86:  return 28;    // V
    case 87:  return 29;    // W
    case 88:  return 30;    // X
    case 54:  return 31;    // 6
    case 89:  return 32;    // Y
    case 90:  return 33;    // Z
    case 43:  return 34;    // +
    case 45:  return 35;    // -
    case 55:  return 36;    // 7
    case 63:  return 37;    // ?
    case 33:  return 38;    // !
    case 46:  return 39;    // .
    case 44:  return 40;    // ,
    case 56:  return 41;    // 8
    case 64:  return 42;    // @
    case 58:  return 43;    // :
    case 59:  return 44;    // ;
    case 35:  return 45;    // #
    case 57:  return 46;    // 9
    case 42:  return 47;    // *
    case 36:  return 48;    // $
    case 47:  return 49;    // /
    case 32:  return 50;    // " " (space)
    default:  return  0;    // Default
  }
}
