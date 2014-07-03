<?php

$objectFilePath = '../../../../engine/res/Object.js';

$requestBody = file_get_contents('php://input');

if (isset($requestBody)) {
	$requestBody = str_replace('../engine/res/', 'res/', $requestBody);

  	$body = "var gameData;

gameData = {$requestBody};

kiss.gameData = gameData;";

  file_put_contents($objectFilePath, $body);
}