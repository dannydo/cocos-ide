<?php

require_once "./json.php";

$objectFilePath = './object.js';

$requestBody = file_get_contents('php://input');

if (isset($requestBody)) {
	$requestBody = str_replace('../engine/res/', 'res/', $requestBody);

	$requestBody = convertVariableToString(json_decode($requestBody, true));
	$requestBody = jsonBeautifier(json_encode($requestBody));

  	file_put_contents($objectFilePath, $requestBody);
}