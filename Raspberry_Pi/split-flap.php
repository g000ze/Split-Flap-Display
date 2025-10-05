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
        # arduinos or blocks
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
        # arduinos or blocks
        0 => array(
            'size' => 8,    // number of modules
            'i2c'  => 0x0c, // i2c address of arduino
        ),
        1 => array(
            'size' => 8,    // number of modules
            'i2c'  => 0x0d, // i2c address of arduino
        ),
    ),
    2 => array(
        0 => array(
            'size' => 8,    // number of modules
            'i2c'  => 0x0e, // i2c address of arduino
        ),
        1 => array(
            'size' => 8,    // number of modules
            'i2c'  => 0x0f, // i2c address of arduino
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
                'regexp'  => "/^(start|stop|left_snake|right_snake|right|left)$/",
            ],
        ],
        'text'      => [
            'filter' => FILTER_DEFAULT,
            #'flags'  => FILTER_REQUIRE_ARRAY,
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
 */
function text_to_array(string $text, $same = false): array
{
    global $targets, $characters, $placeholder;
    $current_positions = get_current_positions();

    $counter = 0;
    foreach ($targets as $key_line => &$line) {
        foreach ($line as $key_arduino => &$arduino) {
            for ($i = 0; $i < $arduino['size']; $i++) {
                # if no character is given, set a placeholder
                $char = isset($text[$counter]) ? $text[$counter] : $placeholder;

                $arduino['modules'][$i]['char']    = $char;
                # pos 0 in Arduino is the same as pos 50 in PHP
                $arduino['modules'][$i]['cur_pos'] = ($current_positions[$key_line][$key_arduino][$i] == 0) ? 50 : $current_positions[$key_line][$key_arduino][$i];
                $arduino['modules'][$i]['new_pos'] = array_search($char, $characters);
                $arduino['modules'][$i]['walk']    = pos_to_walk($arduino['modules'][$i]['cur_pos'], $arduino['modules'][$i]['new_pos'], $same);
                $counter++;
            }
        }
    }
    return ($targets);
}

/**
 * @return array
 */
function get_current_positions () : array
{
    global $fd, $targets;
    $array = array();
    foreach($targets as $key_line => $line) {
        foreach($line as $key_arduino => $arduino) {
            if(i2c_select($fd, $arduino['i2c'])) {
                $array[$key_line][$key_arduino] = i2c_read($fd, $arduino['size']);
            }
        }
    }
    return $array;
}

/**
 * @param $targets
 * @return array $delay
 *
 */
function set_delay ($targets, $animation = "start", $slowdown = 1)
{
    global $rows, $cols;
    $counter = 0;

    // create $delay array with values from $targes array
    $delay = array();
    foreach ($targets as $line) {
        foreach ($line as $arduino) {
            foreach($arduino['modules'] as $key => $module) {
                if($module['walk'] > 0){
                    $time = 0;
                    if($animation == "stop"){
                        $time = $module['walk'];
                    }else if($animation == "left_snake"){
                        $time = $counter-- * $slowdown;
                    }else if($animation == "right_snake"){
                        $time = $counter++ * $slowdown;
                    }else if($animation == "left"){
                        $time = $counter-- * $slowdown;
                        $counter = $counter <= -$cols ? 0 : $counter;
                    }else if($animation == "right"){
                        $time = $counter++ * $slowdown;
                        $counter = $counter >=  $cols ? 0 : $counter;
                    }
                    $delay[$time][$arduino['i2c']]['size'] = $arduino['size'];
                    $delay[$time][$arduino['i2c']]['modules'][$key] = $module;
                }
            }
        }
    }
    krsort($delay, SORT_NUMERIC);
    return ($delay);
}

/**
 * @param $targets
 * @return void
 */
function run_carrousel($targets): void
{
    global $fd, $delay_per_position, $placeholder;
    $prev_time = 0;
    $counter = 0;
    foreach ($targets as $time => $delay) {
        $sleep = $counter == 0 ? 0 : ($prev_time - $time) * $delay_per_position;
        usleep($sleep);
        $counter++;
        $prev_time = $time;
        foreach ($delay as $i2c => $address) {
            unset($text);
            for ($i = 0; $i < $address['size']; $i++) {
              $text[$i] = ord($address['modules'][$i]['char'] ?? $placeholder);
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
