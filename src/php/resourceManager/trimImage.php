<?php

function trimImage($pathImage) {
  if (!is_dir('./temp'))
    mkdir('./temp', 0777, true);

  $arrPath = explode('/', $pathImage);
  $pathFile = './temp/' . end($arrPath);
  $cmd = "convert -trim -verbose {$pathImage} $pathFile 2>&1";

  $result = `$cmd`;

  $arrExplode = explode($pathFile, $result);
  $str = explode(' ', $arrExplode[1]);

  $position = explode('+', $str[3]);

  $size = explode('=>', $str[2]);
  $realSize = explode('x', $size[0]);
  $trimSize = explode('x', end($size));

  $return = array('x'       => max(0, $position[1]-1),
                  'y'       => max(0, $position[2]-1),
                  'width'   => min($trimSize[0]+1, $realSize[0]*1),
                  'height'  => min($trimSize[1]+1, $realSize[1]*1)
                );

  return $return;
}
