#!/usr/bin/php
<?php

require(dirname(__FILE__) . "/library.php");

# default values
$noblock = false;
$animation = "n";
$same = false;

# desperate attempt to optarg in php
# maybe someone has a better solution!
array_shift($argv);
while ($arg = array_shift($argv)) {
  if(substr($arg, 0, 7) == '--text='){
    # take the second part of $arg found by delimiter "="
    # and make every sinlge charakter being an array member
    $text = str_split(explode("=", $arg, 2)[1], 1);
  }
  if(substr($arg, 0, 9) == '--noblock'){
    $noblock = true;
  }
  if(substr($arg, 0, 11) == '--animation'){
    $animation = explode("=", $arg, 2)[1];
  }
  if(substr($arg, 0, 6) == '--same'){
    $same = true;
  }
}

# set random text, if none is given
if(!isset($text)){
  $text = get_random_values();
}

# generate array to be used by library
$display = create_text_to_display($text);

# do not run on same characters
if($same){
  $display = ignore_same_positions($display);
}

$display = set_delay($display, $animation);

foreach($text as $value){
  echo "$value";
}
echo "\n\n";

run_carrousel($display);

if(!$noblock){
  block();
}

i2c_close($fd);

?>
