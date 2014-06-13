<?php

$objectFilePath = '../../coffee/Object.coffee';

$requestBody = file_get_contents('php://input');

if (isset($requestBody)) {
  file_put_contents($objectFilePath, $requestBody);
}