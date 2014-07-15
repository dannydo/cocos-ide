<?php
#require_once "resource.php";


header('Content-Type: text/javascript');
require_once "directory_listing.php";


$coffee_files = directory_listing('../coffee', "coffee");
$codes = array();
$main = "";
$resource = "";

foreach($coffee_files as $_coffee_file){
  $_coffee_file = str_replace("../", "src/", $_coffee_file);
  if(strpos($_coffee_file, "Resource.coffee") > 0){
    $resource = "  CoffeeScript.load '$_coffee_file'";
  } else if(strpos($_coffee_file, "Main.coffee") > 0){
    $main = "  CoffeeScript.load '$_coffee_file'";
  } else {
    $codes[] = "CoffeeScript.load '$_coffee_file'";
  }
}

$codes = implode("\n", $codes) . "\n";

?>


window.$Model = {}

<?=$codes?>

cc.game.onStart = ->
<?=$resource ?>

window.resource_ready = ->
<?=$main?>


cc.game.run()
