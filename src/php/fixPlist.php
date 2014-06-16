<?php

$plist = explode("\n", file_get_contents("../../res/board.plist"));

foreach ($plist as  $k => $p) {
  if (strpos($p, "png</key>") !== false){
    $content = substr(trim($p), 5, -6);
    $spacing = strpos($p, "<");
    if(strpos($content, "/") !== false) {
      $content = array_pop( (explode("/", $content) ));
      $plist[$k] = str_repeat(" ", $spacing) . "<key>{$content}</key>";
    }
  }
}

$plist = implode("\n", $plist);

file_put_contents("../../res/boardv2.plist", $plist);