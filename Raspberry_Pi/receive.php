#!/usr/bin/php
<?php
require(dirname(__FILE__) . "/library.php");
$data = i2c_read($fd, $modules);
foreach($data as $key => $value){
  echo "mod: " . $key; 
  echo ", pos: " . $value;
  echo "\n";
}
i2c_close($fd);
?>
