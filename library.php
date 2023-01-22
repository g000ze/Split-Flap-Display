<?php

/*************************************************
 The settings.
 They must match the one from the Arduino code.
*************************************************/
$target             = 0x0b;
$modules            = 6;
$microsteps         = 16;
$motorsteps         = 200;
$flaps              = 50;
$speed              = 28800 / $microsteps;
$delay_per_position = (($motorsteps * $microsteps) / $flaps) * $speed;

/*************************************************
 All characters
*************************************************/
$characters = array(
                      1  => '0',
                      2  => '1',
                      3  => '2',
                      4  => '3',
                      5  => '4',
                      6  => '5',
                      7  => '6',
                      8  => '7',
                      9  => '8',
                      10 => '9',
                      11 => 'A',
                      12 => 'B',
                      13 => 'C',
                      14 => 'D',
                      15 => 'E',
                      16 => 'F',
                      17 => 'G',
                      18 => 'H',
                      19 => 'I',
                      20 => 'J',
                      21 => 'K',
                      22 => 'L',
                      23 => 'M',
                      24 => 'N',
                      25 => 'O',
                      26 => 'P',
                      27 => 'Q',
                      28 => 'R',
                      29 => 'S',
                      30 => 'T',
                      31 => 'U',
                      32 => 'V',
                      33 => 'W',
                      34 => 'X',
                      35 => 'Y',
                      36 => 'Z',
                      37 => '!',
                      38 => '%',
                      39 => '&',
                      40 => '*',
                      41 => '+',
                      42 => '-',
                      43 => '.',
                      44 => '/',
                      45 => ':',
                      46 => '?',
                      47 => '$',
                      48 => '@',
                      49 => '#',
                      50 => ' ',
                   );

$fd = i2c_open("/dev/i2c-1");

if(!$fd){
  die("unable to open i2c device...");
}
i2c_select($fd, $target);

/*************************************************
 Below here is no more settings but code
*************************************************/
function set_delay($text, $animation = "n"){
  # delay in flap positions
  $delay = 5;
  $counter = 0;

  if($animation == "h"){
    $text = array_orderby($text, 'walk', SORT_DESC);
    $first_walk_distance = 0;
  }

  foreach($text as $key => $value){
    if      ($animation == "h"){
      if($counter == 0){
        $text[$key]['delay'] = 0;
        $first_walk_distance = $text[$key]['walk'];
      }else{
        $text[$key]['delay'] = $first_walk_distance - $text[$key]['walk'];
      }
    }else if($animation == "r"){
      $text[$key]['delay'] = ((count($text) - 1) * $delay) - ($counter * $delay);
    }else if($animation == "l"){
      $text[$key]['delay'] = $counter * $delay;
    }else{
      $text[$key]['delay'] = 0;
    }
    $counter++;
  }
  return $text;
}

function find_equal_delay_times($text, $delay){
  $return = array();
  foreach($text as $key => $value){
    if($value['delay'] == $delay){
      $return[$value['module']] = ord($value['char']);
    }else{
      $return[$value['module']] = ord('~');
    }
  }
  ksort($return, SORT_NUMERIC);
  return $return;
}

function run_carrousel($text){
  global $fd, $delay_per_position;

  # count the amount of different delay times
  foreach($text as $delay){
    $delays[] = $delay['delay'];
  }

  /*
    Now find all occurences of those delays in the $text array
    and put them in the final array. The array keys represent the
    number of flap positions to wait.
    it more or less looks like this:
    Array
    (
        [42] => Array
            (
                [0] => ~
                [1] => ~
                [2] => ~
                [3] => A
                [4] => C
            )
    
        [39] => Array
            (
                [0] => ~
                [1] => ~
                [2] => R
                [3] => ~
                [4] => ~
            )
    
        [33] => Array
            (
                [0] => *
                [1] => G
                [2] => ~
                [3] => ~
                [4] => ~
            )
    )
  */
  foreach(array_unique($delays) as $time){
    $text_arrays[$time] = find_equal_delay_times($text, $time);
  }
  ksort($text_arrays, SORT_NUMERIC);

  # now run i2c
  $last_wait = 0;
  foreach($text_arrays as $wait => $text){
    usleep(($wait - $last_wait) * $delay_per_position);
    $last_wait = $wait;
    i2c_write($fd, 0, $text);
  }

}

/*
 see https://www.php.net/manual/de/function.array-multisort.php#100534 for details
*/
function array_orderby()
{   
  $args = func_get_args();
  $data = array_shift($args);
  foreach ($args as $n => $field) {
    if (is_string($field)) {
      $tmp = array();
      foreach ($data as $key => $row)
        $tmp[$key] = $row[$field];
      $args[$n] = $tmp;
    }
  }
  $args[] = &$data;
  call_user_func_array('array_multisort', $args);
  return array_pop($args);
}

/*************************************************
 XXX ToDo: Error handling, in case the array input
 is too small.
*************************************************/
function create_text_to_display($text){
  global $modules, $characters;
  for($counter = 0; $counter < $modules; $counter++){
    $char = strtoupper($text[$counter]);
    $curr = get_current_positions()[$counter];
    # filter out invalid characters
    if(in_array($char, $characters)){
      $new = array_search($char, $characters);
      $walk = get_flap_positions_to_walk($curr, $new);
    }else{
      $char = "~";
      $new = "~";
      $walk = 0;
    }

    $array[$counter] = array(
      'module' => $counter,
      'char'   => $char,
      'curr'   => $curr,
      'new'    => $new,
      'walk'   => $walk,
    );
  }
  return($array);
}

function get_flap_positions_to_walk($current, $new){
  global $flaps;
  if ($new > $current) {
    return($new - $current);
  }
  else {
    return($flaps - $current) + $new;
  }
}

function ignore_same_positions($text){
  global $flaps;
  foreach($text as $counter => $character){
    # replace the 'char' field in the $text array
    # with something invalid, we take '~'.
    # replace the 'walk' field in the $text array
    # with 0 instead of $flaps.
    if($character['curr'] == $character['new']){
      $text[$counter]['char'] = '~';
      $text[$counter]['walk'] = 0;
    }
  }
  return($text);
}

function block(){
  global $delay_per_position;
  while(at_least_one_module_running()){
    # pause for a short time
    usleep($delay_per_position);
  }
}

function at_least_one_module_running(){
  global $targets;
  if(in_array(255, get_current_positions())){
    return true;
  }
  return false;
}

function get_current_positions(){
  global $fd, $modules;
  return(i2c_read($fd, $modules));
}

function get_random_values(){
  global $characters, $modules;
  $seed = $characters;
  shuffle($seed);
  # we want the array values, not the array keys
  $text = array_rand(array_flip($seed), $modules);
  return($text);
}

?>
