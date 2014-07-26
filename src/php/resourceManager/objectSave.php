<?php

require_once "../directory_listing.php";
require_once "./json.php";

$objectFilePath = './objects';
$requestBody    = file_get_contents('php://input');

if (isset($requestBody)) {
	$requestBody = str_replace('../engine/res/', 'res/', $requestBody);

	$requestBody = convertVariableToString(json_decode($requestBody, true));

	foreach ($requestBody['object'] as $objectName => $object) {
		$objectFileName = $objectName . '.js';

		if (count($object) == 0) {
			unlink($objectFilePath . '/' . $objectFileName);
		} else {
			$content 		= jsonBeautifier(json_encode($object));

	  		file_put_contents($objectFilePath . '/' . $objectFileName, $content);
	  	}
	}
}



/**
 * Generate game data
 */
$gameDataPath = '../../../../engine/res/Object.js';

$data         = array();
$oldObjects   = directory_listing($objectFilePath);
foreach ($oldObjects as $oldObject) {
	$objectName = pathinfo($oldObject, PATHINFO_FILENAME);

	$data[$objectName] = json_decode(file_get_contents($oldObject), true);
}

$jsonString = jsonBeautifier(json_encode($data));
$body 		= "var gameData;

gameData = {$jsonString};

kiss.gameData = gameData;";

file_put_contents($gameDataPath, $body);