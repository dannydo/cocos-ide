<?php
require "directory_listing.php";


$coffee_files = directory_listing('../coffee', "coffee");

require "../../library/coffee-script/Init.php";
CoffeeScript\Init::load();

$_javascript_files = [];
foreach($coffee_files as $_coffee_file){
  $_coffee = file_get_contents($_coffee_file);
  $_javascript = CoffeeScript\Compiler::compile($_coffee, array('filename' => $_coffee_file));
  $_javascript_file = str_replace( ["../coffee", ".coffee"], ["../javascript",".js"], $_coffee_file) ;
  if (!file_exists(dirname($_javascript_file))) {
    mkdir(dirname($_javascript_file), 0777, true);
  }
  file_put_contents($_javascript_file, $_javascript);
  $_javascript_files[] = str_replace("../", "src/", $_javascript_file); 
}

?>

{
    "project_type": "javascript",

    "debugMode" : 1,
    "showFPS" : true,
    "frameRate" : 60,
    "id" : "gameCanvas",
    "renderMode" : 0,
    "engineDir":"frameworks/cocos2d-html5",

    "modules"  : ["cocos2d", "extensions", "external"],

    "jsList" : [ 
       "<?php
    echo implode("\,\n       \"", $_javascript_files);
    ?>"
    ]
}
