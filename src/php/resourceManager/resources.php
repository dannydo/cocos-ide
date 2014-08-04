<?php
require_once "../directory_listing.php";
$graphicPath = "../../../../engine/res/graphics";
$soundPath   = "../../../../engine/res/sounds";

$filenames   = array_merge(directory_listing($graphicPath), directory_listing($soundPath));

$resouceList = array("graphics" => array(), "sounds" => array());
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
			$group = getGraphicGroup($filename, $graphicPath);
			if (! isset($resouceList['graphics'][$group])) $resouceList['graphics'][$group] = array();

			$resouceList['graphics'][$group][] = $filename;
			break;
		case 'wav':
			$name = pathinfo($filename, PATHINFO_FILENAME);
			$resouceList['sounds'][$name] = $filename;
			break;
		default:
			//$resouceList['other'][] = $filename;
		break;
	}
}

function getGraphicGroup($filename, $path) {
	$string 		= str_replace($path, "", $filename);
	$firstDirectory = explode("/", $string);

	return $firstDirectory[1];
}

function getFullPathFile($filenames) {
	$files = array();
	foreach($filenames as $key => $filename) {
		$filename    = str_replace("../../../", "", $filename);
		$files[$key] = $filename;
	}

	return $files;
}
// echo "<pre>";
// print_r($resouceList);exit;

foreach ($resouceList as $type => $resouces) {
  $resouceList[$type] = getFullPathFile($resouces);
}


if (isset($_GET['type']) && isset($resouceList[$_GET['type']])) {
  $resources = $resouceList[$_GET['type']];
} else {
  $resources = $resouceList['graphics'];
}

die(json_encode($resouceList));
