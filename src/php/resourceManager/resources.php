<?php
require_once "../directory_listing.php";
$filenames   = directory_listing("../../../../engine/res");

$resouceList = array();
$ignore_list = array("template");

foreach($filenames as $filename){
  $ignore_file = false;
  foreach($ignore_list as $ignore){
    if(strpos($filename, $ignore)!==false){
      $ignore_file = true;
      break;
    }
  }

  if ($ignore_file){
    continue;
  }

  $_extension = pathinfo($filename, PATHINFO_EXTENSION);

  switch ($_extension) {
    case 'exportjson':
      //$resouceList['exportjson'][] = $filename;
      break;
    case 'json':
      //$resouceList['json'][] = $filename;
      break;
    case 'plist':
      //$resouceList['plist'][] = $filename;
      break;
    case 'jpeg':
    case 'gif':
    case 'png':
      $resouceList['graphics'][] = $filename;
      break;
    case 'wav':
      $resouceList['sounds'][] = $filename;
      break;
    default:
      //$resouceList['other'][] = $filename;
      break;
  }
}

function getFullPathFile($filenames) {
  $files = array();
  foreach($filenames as $filename) {
      $filename = str_replace("../../../", "", $filename);
      $files[] = $filename;
  }

  return $files;
}

foreach ($resouceList as $type => $resouces) {
  $resouceList[$type] = getFullPathFile($resouces);
}
//var_dump($resouceList);exit;


if (isset($_GET['type']) && isset($resouceList[$_GET['type']])) {
  $resources = $resouceList[$_GET['type']];
} else {
  $resources = $resouceList['graphics'];
}

die(json_encode($resouceList));
