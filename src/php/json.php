<?php

$sample_json = file_get_contents("../../res/template/sample.json");
$animation_json = file_get_contents("../../res/template/animation.json");
$sample = json_decode($sample_json, true);
$animation = json_decode($animation_json, true);


$plist_raw = explode("\n", file_get_contents("../../res/board.plist"));



function prefix_filter($values, $prefix_sets){
  $sets = array();
  foreach($values as $value){
    $set = false;
    foreach($prefix_sets as $major_prefix => $prefix_set){
      foreach($prefix_set as $prefix){
        if(strpos($value, $prefix) === 0){
          $set = $major_prefix;
        }
        if($set){
          break;
        }
      }
      if($set) {
        break;
      }
    }

    if($set){
      $sets[$set][] = $value;
    } else {
      echo "MISSING $value\n";
    }
  }
  return $sets;
}





$plist_prefix_sets = array(
  "shieldBreak"=>array("shield_break"),
  "lockForm"=>array("lock_form"),
  "animals"=>array("white","green","blue","orange","red","pink","shield","lock"),
  "effects"=>array("combo"),
  "bushs"=>array("bush"),
  "header_letter"=>array("header"),
  "letters"=>array("gem","bonus"),
);

foreach($plist_raw as $line) {
  if(strpos($line, ".png</key>") !== false){
    $plist_list[] =  substr(trim($line), 5, -6); 
  }
}

$plist_set = prefix_filter($plist_list, $plist_prefix_sets);


$animation_prefix_sets = array(
  "animals"=>array("Fall","Appear","Disappear","Idle","Snap"),
  "bush"=>array("bush"),
  "hole"=>array("hole"),
  "delay"=>array("delay"),
);

foreach($animation['animation_data'][0]['mov_data'] as $json_animation){
  $animation_list[] = $json_animation['name'];
  $animation_cache[$json_animation['name']] = $json_animation;
}

$animation_set = prefix_filter($animation_list, $animation_prefix_sets);





$clone_display_data = function () use ($sample){
  return $sample['armature_data'][0]['bone_data'][0]['display_data'][0];
};

$clone_texture_data = function() use ($sample){
  return $sample['texture_data'][0];
};




$animation_texture_data = [];
foreach ($animation['texture_data'] as $key => $value) {
  $animation_texture_data[$key] = $value['name'];
}


foreach($plist_list as $key => $filename){
  $texture_data = $clone_texture_data(); 
  $display_data = $clone_display_data(); 


  $display_data['name'] = $filename;
  $sample_display_data[] = $display_data;

  $filename = current((explode(".",$filename)));
  $texture_data['name'] = $filename;

  $sample_texture[] = $texture_data;
  $sample_texture_name[$filename] = $key;
}


foreach($plist_set['animals'] as $plist_animal){
  $filename = current((explode(".",$plist_animal)));
  foreach($animation_set['animals'] as $animation_animal){
    if(strpos($filename, "snap")!=0 and strpos($animation_animal, "Falling")===0){
      continue;
    }
    $clone = $animation_cache[$animation_animal];
    $clone['name'] = "{$filename}_{$animation_animal}";

    $clone['name'] = str_replace(" ", "", lcfirst(ucwords(str_replace("_", " ", $clone['name']))));

    $index = $sample_texture_name[$filename];
    echo "{$clone['name']}\n";

    $fi = 0;
    foreach($clone['mov_bone_data'][0]['frame_data'] as $key=>$frame_data){
      $clone['mov_bone_data'][0]['frame_data'][$key]['dI'] = $index;
      $fi = max($fi, $frame_data['fi']);
    }
    $clone['dr'] = $fi+1;

    $sample_animation_data[] = $clone;
  }
}



#Merging resources from static resources
$animation_sync = array_merge( $animation_set['hole'],  $animation_set['bush']);
if(isset($animation_set['delay'])){
  $animation_sync = array_merge( $animation_sync,  $animation_set['delay']);

}
foreach($animation_sync as $animation_name){
  #$animation_texture_data
  $clone = $animation_cache[$animation_name];

  $fi = 0;
  foreach($clone['mov_bone_data'][0]['frame_data'] as $key => $frame_data){
    $clone['mov_bone_data'][0]['frame_data'][$key]['dI']
      = $sample_texture_name[$animation_texture_data[$frame_data['dI']]];
    $fi = max($fi, $frame_data['fi']);
  }
  $clone['dr'] = $fi+1;
  
  $sample_animation_data[] = $clone;

    print $clone['name']."\n";

}



$sample['armature_data'][0]['bone_data'][0]['display_data'] =  $sample_display_data;
$sample['texture_data'] = $sample_texture;
$sample['animation_data'][0]['mov_data'] = $sample_animation_data;


$json = json_encode($sample);

file_put_contents("../../res/animation.json", $json);

//print_r($animation['animation_data'][0]['mov_data']);
