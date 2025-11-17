#!/usr/bin/php
<?php

require (__DIR__ . "/split-flap.php");

$longopts  = array(
    "text:",
    "animation:",
    "slowdown:",
    "noblock",
    "same",
    "wipe"
);

$options = getopt("", $longopts);
$options['same']       = isset($options['same'])     && !$options['same']     ? true : false;
$options['wipe']       = isset($options['wipe'])     && !$options['wipe']     ? true : false;
$options['noblock']    = isset($options['noblock'])  && !$options['noblock']  ? true : false;
$options['slowdown']   = isset($options['slowdown']) ? $options['slowdown'] : 1;
$options['text']       = isset($options['text']) ? $options['text'] : '';
$options['animation']  = isset($options['animation']) ? $options['animation'] : 'start';

if (isset($options) && ! empty($options)) {
    $fd = i2c_open("/dev/i2c-1");

    $sanitized_string = sanitize_string($options['text'], $options['wipe']);
    $grid = config_to_grid($sanitized_string, $options['same']);
    $array = set_delay($grid, $options['animation'], $options['slowdown']);
    run_carrousel($array);

    if(!$options['noblock']){
        block();
    }

    i2c_close($fd);
}
