<?php
require_once "resourceManager/json.php";

$packerFilePath = '../../../engine/res/graphics/in-game/packerImage/';

if (!is_dir($packerFilePath)) {
    mkdir($packerFilePath, 0777, true);
}

$requestBody = file_get_contents('php://input');

if (isset($requestBody)) {
  $dataJson = json_decode($requestBody, true);
  
  file_put_contents($packerFilePath . $dataJson["filename"], jsonBeautifier(json_encode($dataJson["dataPacker"])));
}