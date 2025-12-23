<?php

$flaps = 50;
$microsteps = 16;
$motorsteps = 200;
$speed      = 28800 / $microsteps;
$delay_per_position = (($motorsteps * $microsteps) / $flaps) * $speed;


$placeholder = '~';
# starting the array with key "1" matches the positions
# returned by Arduino and prevents calculation of "+1" later on
$characters = array(
     1 => '0', 'A', 'B', 'C', 'D',  // 5
          '1', 'E', 'F', 'G', 'H',  // 10
          '2', 'I', 'J', 'K', 'L',  // 15
          '3', 'M', 'N', 'O', 'P',  // 20
          '4', 'Q', 'R', 'S', 'T',  // 25
          '5', 'U', 'V', 'W', 'X',  // 30
          '6', 'Y', 'Z', '+', '-',  // 35
          '7', '?', '!', '.', ',',  // 40
          '8', '@', ':', ';', '#',  // 45
          '9', '*', '$', '/', ' ',  // 50
);

/** @var $targets */
$targets = array(
    # lines
    0 => array(
        # arduinos or units
        0 => array(
            'size' => 8,    // number of modules
            'i2c'  => 0x0a, // i2c address of arduino
        ),
        1 => array(
            'size' => 8,    // number of modules
            'i2c'  => 0x0b, // i2c address of arduino
        ),
    ),
    1 => array(
        0 => array(
            'size' => 8,
            'i2c'  => 0x0c,
        ),
        1 => array(
            'size' => 8,
            'i2c'  => 0x0d,
        ),
    ),
    2 => array(
        0 => array(
            'size' => 8,
            'i2c'  => 0x0e,
        ),
        1 => array(
            'size' => 8,
            'i2c'  => 0x0f,
        ),
    ),
);

// count $rows, $cols and $modules
$rows = count($targets);
$cols = 0;
foreach ($targets[0] as $arduino)
{
    $cols += $arduino['size'];
}
$modules = $rows * $cols;

/**
 * @param array $options
 * @return array|false|null
 */
function filter_options (array $options)
{
    $filters = [
        'same'    => [
            'filter'  => FILTER_VALIDATE_BOOLEAN,
            'options' => [
                'default' => false,
            ],
        ],
        'noblock' => [
            'filter'  => FILTER_VALIDATE_BOOLEAN,
            'options' => [
                'default' => false,
            ],
        ],
        'wipe'    => [
            'filter'  => FILTER_VALIDATE_BOOLEAN,
            'options' => [
                'default' => false,
            ],
        ],
        'animation' => [
            'filter'  => FILTER_VALIDATE_REGEXP,
            'options' => [
                'default' => "start",
                'regexp'  => "/^(start|stop|right|left|top|bottom|random|snake1|snake2|snake3|snake4|cross|diagonal|round)$/",
            ],
        ],
        'text'      => [
            'filter' => FILTER_DEFAULT,
            #'flags'  => FILTER_REQUIRE_ARRAY,
        ],
        'slowdown' => [
            'filter'  => FILTER_VALIDATE_INT,
            'options' => [
                'default' => 1,
                'min_range' => 1,
                'max_range' => 10,
            ],
        ],
    ];
    return (filter_var_array($options, $filters));
}


/**
 * @param string $string
 * @return string
 */

function sanitize_string(string $string, $wipe = false): string
{
    global $characters, $placeholder, $modules;

    # Unicode-Normalisierung in Form KD (Kompatibilitätszerlegung)
    $string = Normalizer::normalize($string, Normalizer::FORM_KD);

    # replace whitespaces
    $string = preg_replace('/\r\n|\r|\n|\t|\v|\f/u', ' ', $string);

    # Entfernt diakritische Zeichen (Akzente)
    $string = preg_replace('/\p{Mn}/u', '', $string);

    $string = iconv('UTF-8', 'ASCII//TRANSLIT', $string);

    # max length to number of modules
    $string = substr($string, 0, $modules);

    # string to uppercase
    $string = strtoupper($string);

    # fill up string with spaces
    if ($wipe) {
      if (strlen($string) < $modules) {
        for ($i = strlen($string); $i < $modules; $i++) {
          $string[$i] = " ";
        }
      }
    }

    # replace any character with placeholder, if it isn't part of the $characters array
    for ($i = 0; $i < strlen($string); $i++) {
        if (!in_array($string[$i], $characters, true)) {
            $string[$i] = $placeholder;
        }
    }
    return ($string);
}

/**
 * @param string $text
 * @return array $targets
 * merges a sanitized text string into the three-dimensional array
 * that has been specified above.
 * also specify another array structure in order to be more
 * intuitive. we change it from:
 * array
 *   rows
 *     arduinos
 *       modules
 *
 * to:
 * array
 *   rows
 *     cols
 */
function config_to_grid($text, $same = false): array
{
    global $targets, $placeholder, $characters;
    $array = array();
    $current_positions = get_current_positions();

    $index = 0;
    foreach ($targets as $row => $line) {
        $col = 0;
        foreach ($line as $arduino) {
            for ($i = 0; $i < $arduino['size']; $i++) {
                $array[$row][$col]['i2c']      = $arduino['i2c'];
                $array[$row][$col]['module']   = $i;
                $array[$row][$col]['size']     = $arduino['size'];
                $array[$row][$col]['char']     = isset($text[$index]) ? $text[$index] : $placeholder;
                # pos 0 in Arduino is the same as pos 50 in PHP
                $array[$row][$col]['cur_pos']  = ($current_positions[$row][$col] == 0) ? 50 : $current_positions[$row][$col];
                $array[$row][$col]['new_pos']  = array_search($array[$row][$col]['char'], $characters);
                $array[$row][$col]['walk']     = pos_to_walk($array[$row][$col]['cur_pos'], $array[$row][$col]['new_pos'], $same);
                $index++;
                $col++;
            }
        }
    }
    return ($array);
}

/**
 * @param $targets
 * @return array $delay
 *
 * this function sets the "timer" values according to the
 * animation and changes the array structure 
 * from:
 * array
 *   rows
 *     cols
 *       values ...
 * 
 * to: 
 * array
 *   timer
 *     i2c
 *       module
 *         values ...
 */
function set_delay ($array, $animation = "start"): array
{
    global $rows, $cols, $modules;

    $counter = 0;
    $timer = 0;
    $return = array();
    
    if ($animation === "random") {
        $randomized = range(0, $modules - 1);
        shuffle($randomized);
    }

    for($row = 0; $row < $rows; $row++){
        for($col = 0; $col < $cols; $col++){
            switch ($animation) {
                case "start":
                    $timer = 0;
                    break;
                case "stop":
                    $timer = $array[$row][$col]['walk'];
                    break;
                case "left":
                    $timer = ($col % $cols === 0) ? $cols : --$timer;
                    break;
                case "right":
                    $timer = ($col % $cols === 0) ? 0 : ++$timer;
                    break;
                case "top":
                    $timer = ($rows - 1) - $row;
                    break;
                case "bottom":
                    $timer = $row;
                    break;
                case "random":
                    $timer = $randomized[$counter];
                    break;
                case "snake1":
                    $timer = ($modules - 1) - ($row % 2 === 0 ? (($row + 1) * $cols - $col - 1) : $counter);
                    break;
                case "snake2":
                    $timer = ($modules - 1) - ($row % 2 === 1 ? (($row + 1) * $cols - $col - 1) : $counter);
                    break;
                case "snake3":
                    $timer = $row % 2 === 0 ? (($row + 1) * $cols - $col - 1) : $counter;
                    break;
                case "snake4":
                    $timer = $row % 2 === 1 ? (($row + 1) * $cols - $col - 1) : $counter;
                    break;
                case "cross":
                    ($row % 2 === 0) ? $timer++ : $timer--;
                    break;
                case "round":
                    if     ($row == 0)          { $timer = ($timer + 1); }
                    else if($row == ($rows - 1)){ $timer = ((($cols - 1) + ($rows - 1)) + ($cols - $col)); }
                    else
                    {
                        if     ($col == 0)          { $timer = ((($cols - 1) + ($rows - 1)) + ($cols + $row)); }
                        else if($col == ($cols - 1)){ $timer = $cols + $row; }
                    }
                    break;
                case "diagonal":
                    $timer = ($row * 2) + $col;
                    break;
            }
            $counter++;

            # only add module to array, if it is meant to be running
            if($array[$row][$col]['walk'] > 0){
                $module   = $array[$row][$col]['module'];
                $i2c      = $array[$row][$col]['i2c'];

                $return[$timer][$i2c]['size']  = $array[$row][$col]['size'];
                $return[$timer][$i2c][$module] = $array[$row][$col];
            }
        }
    }

    krsort($return, SORT_NUMERIC);
    return ($return);
}

/**
 * @return array
 */
function get_current_positions () : array
{
    global $fd, $targets;
    $array = array();
    foreach($targets as $row => $line) {
        $col = 0;
        foreach($line as $arduino) {
            if(i2c_select($fd, $arduino['i2c'])) {
                $positions = i2c_read($fd, $arduino['size']);
                for ($i = 0; $i < $arduino['size']; $i++) {
                  $array[$row][$col] = $positions[$i];
                  $col++;
                }
            }
        }
    }
    return $array;
}

/**
 * @param $targets
 * @return void
 */
function run_carrousel($targets, $slowdown = 1): void
{
    global $fd, $delay_per_position, $placeholder;
    $prev_time = 0;
    $counter = 0;

    foreach ($targets as $time => $delay) {
        $sleep = $counter == 0 ? 0 : ($prev_time - $time) * ($delay_per_position * $slowdown);
        usleep($sleep);
        $counter++;
        $prev_time = $time;
        foreach ($delay as $i2c => $address) {
            unset($text);
            for ($i = 0; $i < $address['size']; $i++) {
                $text[$i] = ord($address[$i]['char'] ?? $placeholder);
            }

            if (i2c_select($fd, $i2c)) {
                i2c_write($fd, 0, $text);
            }
        }
    }
}


/**
 * @param $cur
 * @param $new
 * @param bool $same
 * @return int
 */
function pos_to_walk($cur, $new, $same = false): int
{
    global $flaps;
    if(is_int($cur) && is_int($new))
    {
        if($new === $cur)
        {
            if($same)
            {
                return (0);
            } else
            {
                return ($flaps);
            }
        }
        else if($cur >= 255){
            // XXX ist das richtig???
            return (255);
        }
        else if($new > $cur)
        {
            return ($new - $cur);
        } else
        {
            return ($flaps - $cur) + $new;
        }
    } else
    {
        return (0);
    }
}


function block(){
    global $delay_per_position;
    while(is_running(get_current_positions())){
        # pause for a short time
        usleep($delay_per_position);
    }
}


/**
 * @param array $array
 * @return bool
 */
function is_running(array $array) {
    foreach ($array as $value) {
        if (is_array($value)) {
            if (is_running($value)) {
                return true;
            }
        }else{
            if ($value >= 255) {
                return true;
            }
        }
    }
    return false;
}
