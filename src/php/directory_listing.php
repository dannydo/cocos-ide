<?php

function directory_listing($directory, $extension=NULL){
  $_file_names = scandir($directory);
  array_shift($_file_names);
  array_shift($_file_names);

  $_coffee = array();
  foreach($_file_names as $key => $_file_name){
    $_path = "{$directory}/{$_file_name}";
    if(is_dir($_path)){
      $_coffee = array_merge($_coffee, directory_listing($_path, $extension));
    } else {
      $_extension = strtolower(end((explode(".",$_path))));
      if($extension == NULL | $_extension == $extension){
        $_coffee[] = $_path;
      }
    }
  }

  return $_coffee;
}