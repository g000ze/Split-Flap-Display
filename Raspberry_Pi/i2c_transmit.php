#!/usr/bin/php
<?php

require "./split-flap.php";

$longopts  = array(
    "text:",
    "animation:",
    "noblock",
    "same",
);

$options = getopt("", $longopts);
$options['same']    = isset($options['same'])    && !$options['same']    ? true : false;
$options['noblock'] = isset($options['noblock']) && !$options['noblock'] ? true : false;
$options = filter_options($options);

if (isset($options) && ! empty($options)) {
    $fd = i2c_open("/dev/i2c-1");
    $options['text'] = sanitize_string($options['text']);
    $array = text_to_array($options['text'], $options['same']);
    $text = set_delay ($array, $options['animation']);
    run_carrousel($text);
    if(!$options['noblock']){
        block();
    }

    i2c_close($fd);
}


