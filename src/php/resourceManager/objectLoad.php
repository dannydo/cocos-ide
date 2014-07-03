<?php

$objectFilePath = 'object.js';

$data = str_replace('res/', '../engine/res/', file_get_contents($objectFilePath));

die($data);