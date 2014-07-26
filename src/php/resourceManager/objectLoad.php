<?php

require_once "../directory_listing.php";
require_once "./json.php";

$objectFilePath     = './objects';
$objectTimeFilePath = './object-time.js';

$data       = array('object' => array());
$oldObjects = directory_listing($objectFilePath);
foreach ($oldObjects as $oldObject) {
	$objectName = pathinfo($oldObject, PATHINFO_FILENAME);

	$data['object'][$objectName] = json_decode(correctImagePath(file_get_contents($oldObject)), true);
}


function correctImagePath($content) {
	return str_replace('res\/', '..\/engine\/res\/', $content);
}

die(json_encode($data));