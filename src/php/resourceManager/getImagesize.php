<?php

require_once "../directory_listing.php";
require_once "./json.php";
require_once "./trimImage.php";

ini_set('max_execution_time', 0);
set_time_limit(0);
error_reporting(E_ALL);

$file_names = directory_listing("../../../../engine/res");

$exportjson = array();
$json = array();
$plist = array();
$other = array();

$ignore_list = array("template");

foreach($file_names as $file_name){
  $ignore_file = false;
  foreach($ignore_list as $ignore){
    if(strpos($file_name, $ignore)!==false){
      $ignore_file = true;
      break;
    }
  }

  if ($ignore_file){
    continue;
  }

  $_extension = strtolower(end((explode(".", $file_name))));
  switch ($_extension) {
    case 'exportjson':
      $exportjson[] = $file_name;
      break;
    case 'json':
      $json[] = $file_name;
      break;
    case 'plist':
      $plist[] = $file_name;
      break;
    case 'jpeg':
    case 'gif':
    case 'png':
      $imageList[] = $file_name;
      break;
    default:
      $other[] = $file_name;
      break;
  }
}

$images = array();
foreach($imageList as $file_name){
  list($width, $height, $type, $attr) = getimagesize($file_name);


  $key = strtolower(str_replace(array('../../res/','.',' ','-',"/","_"), " ", $file_name));
  $key = lcfirst (str_replace(" ", "", ucwords($key)));
  $filenameUsed = str_replace("../../../", "", $file_name);

  //echo $file_name . "\n";

  $boundRect = array();
  if (strpos($file_name, "res/graphics/in-game") !== false) {
    $boundRect = trimImage($file_name);
  }

  $images[$filenameUsed] = array(
    'width'  => $width,
    'height' => $height,
    'boundRect' => $boundRect
  );
  unset($boundRect);
}
`rm -rf temp`;

$jsonData          = str_replace('..\/engine\/res\/', 'res\/', json_encode($images));
$imagesizeFilePath = '../../../../engine/res/Resources.js';
//$imagesizeFilePath = 'Resources.js';

$resouceImagesize  = 'var resources;

resources = ' . jsonBeautifier($jsonData) . ';

kiss.resources = resources;';

file_put_contents($imagesizeFilePath, $resouceImagesize); 
