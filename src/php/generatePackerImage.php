<?php

function drawImage($imageDst, $boundRect, $pathImage) {
  $imgSrc = imagecreatefrompng($pathImage);
  imagecopyresampled($imageDst, $imgSrc, 
    $boundRect->x, $boundRect->y, $boundRect->minX, $boundRect->minY, 
    $boundRect->w, $boundRect->h, $boundRect->w, $boundRect->h);

  imagealphablending($imageDst,false);
}

$filename = $_GET['filename'];
if ($filename == '')
  die;

$packerFilePath = '../../../engine/res/graphics/in-game/packerImage/';
$fileJson = $packerFilePath . $filename;
if (file_exists($fileJson)) {
  $dataFile = file_get_contents($fileJson, true);
}
else
  die("File not exists");

$jsonResource =  json_decode($dataFile);

$maxWidth = $jsonResource->size->w;
$maxHeight = $jsonResource->size->h;

$image = imagecreatetruecolor($maxWidth, $maxHeight);
imagealphablending($image, false);

$col = imagecolorallocatealpha($image,255,255,255,127);
imagefilledrectangle($image, 0, 0, $maxWidth, $maxHeight, $col);
imagealphablending($image, false);

foreach ($jsonResource->blocks as $key => $value) {
  $pathImage = "../../../engine/".$key;
  drawImage($image, $value, $pathImage);
}

$fileImage = explode('.', $filename)[0] . '.png';
imagealphablending($image,false);
imagesavealpha($image,true);
imagepng($image, $packerFilePath . $fileImage, 1);
imagedestroy($image);















/*

function drawRect($imageDst, $poisition, $boundRect, $color) {
  $rect = imagecreatetruecolor(485, 500);
  imagealphablending($rect, false);

  $col = imagecolorallocatealpha($rect, $color['r'], $color['g'], $color['b'], 0);
  imagefilledrectangle($rect, 0, 0, 485, 500, $col);
  imagealphablending($rect, true);

  imagecopyresampled($imageDst, $rect, 
    $poisition['x'], $poisition['y'], $boundRect['x'], $boundRect['y'], 
    $boundRect['w'], $boundRect['h'], $boundRect['w'], $boundRect['h']);

  imagealphablending($imageDst,true);
}
 
$width = $widthIamgeSrc = 107-10;
$height = $heightImageSrc = 110-24;
$poisition = ["x"=>0, "y"=>0];
$boundRect = ["x"=>10, "y"=>24, 'w'=>$widthIamgeSrc, 'h'=>$heightImageSrc];
$pathImage = "../../../../engine/res/graphics/board/blue/blue_combo_4.png";

drawImage($image, $poisition, $boundRect, $pathImage);

$widthIamgeSrc = 110-10;
$heightImageSrc = 100-16;
$poisition = ["x"=>$width, "y"=>0];
$boundRect = ["x"=>16, "y"=>10, 'w'=>$widthIamgeSrc, 'h'=>$heightImageSrc];
$pathImage = "../../../../engine/res/graphics/board/blue/blue_combo_5.png";

drawImage($image, $poisition, $boundRect, $pathImage);
$width += $widthIamgeSrc;

$arrRect = array(
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>50, 'h'=>80),
    'color' => array('r'=>255, 'g'=>0, 'b'=>0)
  ),
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>70, 'h'=>70),
    'color' => array('r'=>255, 'g'=>255, 'b'=>0)
  ),
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>100, 'h'=>50),
    'color' => array('r'=>255, 'g'=>0, 'b'=>255)
  ),
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>100, 'h'=>80),
    'color' => array('r'=>0, 'g'=>255, 'b'=>0)
  ),
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>100, 'h'=>80),
    'color' => array('r'=>0, 'g'=>255, 'b'=>255)
  ),
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>120, 'h'=>100),
    'color' => array('r'=>0, 'g'=>0, 'b'=>255)
  ),
  array(
    'boundRect' => array("x"=>0, "y"=>0, 'w'=>150, 'h'=>70),
    'color' => array('r'=>0, 'g'=>0, 'b'=>0)
  )
);

usort($arrRect, "cmpRect");

$width = 0;
$height = 0;
$margin = 5;
$maxHeightRow = 0;

for($count=0; $count<4; $count++) {
  foreach ($arrRect as $key => $value) {
    if ($margin + $width + $value['boundRect']['w'] > $maxWidth) {
      $height += $maxHeightRow + $margin;
      if ($height + $value['boundRect']['h']> $maxHeight) {
        echo 'break';
        break;
      }
      $width = 0;
      $maxHeightRow = 0;
    }

    $poisition = ["x"=>$margin + $width, "y"=>$height + $margin];
    drawRect($image, $poisition, $value['boundRect'], $value['color']);

    $width +=  $value['boundRect']['w'] + $margin;
    if ($maxHeightRow < $value['boundRect']['h']) {
      $maxHeightRow = $value['boundRect']['h'];
    }
  }
}
*/