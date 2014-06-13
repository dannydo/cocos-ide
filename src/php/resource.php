<?php
require_once "directory_listing.php";
$file_names = directory_listing("../../res");

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


$res = array();
$name = array();
$g_resources = array();


function populate_array($file_names, &$res, &$g_resources, &$name){
  foreach($file_names as $file_name){
    $key = strtolower(str_replace(array('../../res/','.',' ','-',"/","_"), " ", $file_name));
    $key = lcfirst (str_replace(" ", "", ucwords($key)));

    $file_name = str_replace("../../", "", $file_name);

    $name_file_name = end((explode("/",$file_name)));
    
    $res[$key] = "        $key : '{$file_name}'";
    $name[$key] = "        $key : '{$name_file_name}'";
    $g_resources[] = "        '{$file_name}'";
  }
}

populate_array($exportjson, $res, $g_resources, $name);
populate_array($json, $res, $g_resources, $name);
populate_array($plist, $res, $g_resources, $name);


$json_res = implode("\n",$res);
$json_g_resources = implode("\n",$g_resources);
$json_name = implode("\n",$name);

if($json_res){
  $json_res="    res:\n$json_res";
}
if($json_name){
  $json_name="    name:\n$json_name";
}


$json_image = array();
foreach($imageList as $file_name){
    $key = strtolower(str_replace(array('../../res/','.',' ','-',"/","_"), " ", $file_name));
    $key = lcfirst (str_replace(" ", "", ucwords($key)));
    $file_name = str_replace("../../", "", $file_name);
    $json_image[] = "        $key:\"$file_name\"";
}
$json_image = implode("\n",$json_image);
if($json_image){
  $json_image="    images:\n$json_image";
}


$coffee = <<<EOF
# This is an automatically generated file
# your changes will be lost
resource =
    load: [
$json_g_resources
    ]
$json_res
$json_name
$json_image

if window?
    window.resource = resource
resource_ready()
EOF;
file_put_contents("../coffee/Resource.coffee", $coffee);