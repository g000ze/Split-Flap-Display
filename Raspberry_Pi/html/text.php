<?php
require (__DIR__ . "/../split-flap.php");

if (isset($_POST['text']) && ! empty($_POST['text'])) {
  $fd = i2c_open("/dev/i2c-1");
  get_current_positions();
  $options = filter_options($_POST);

  $rawtext = sanitize_string($options['text'], $options['wipe']);
  $array = text_to_array($rawtext, $options['same']);
  $text = set_delay ($array, $options['animation']);
  $options['noblock'] = true;
  run_carrousel($text);
  i2c_close($fd);
}

?>
