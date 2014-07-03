<?php

$objectFilePath = './object.js';

$requestBody = file_get_contents('php://input');

if (isset($requestBody)) {
	$requestBody = str_replace('../engine/res/', 'res/', $requestBody);

  	file_put_contents($objectFilePath, $requestBody);
}