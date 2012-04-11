<?php
// This file is included by others

//
// Make thumbnails (if needed) and create our data structure of data:
//  $screens : array of screenshots
//  $faces : array of webcam shots of user face
//  $latlons : array of lattitude/longitude pairs
//
date_default_timezone_set('America/Denver'); // need to figure out how to set this to whatever the server is
$screens = array();
$faces = array();
$latlons = array();
// check for thumbnails dir
if (!is_dir('thumbnails')) {
  mkdir('thumbnails');
}

// open directory 
$images_directory = "../data";
$my_directory = opendir($images_directory);
while ($entry_name = readdir($my_directory)) {
  $dir_array[] = $entry_name;
  if (strpos($entry_name,'face_')===0) {
    $date = substr($entry_name,strlen('face_'),4+1+2+1+2); 
    $time = substr($entry_name,strlen('face_')+4+1+2+1+2+1,8);
    // // ignore non on-the-hour times
    // if (substr($time,3,2) != '00') {
    //   continue;
    // }

    // drop the minutes and seconds..we don't care
    $time = substr($time,0,2);

    // check for valid date
    date_default_timezone_set('America/Denver');
    if (date('Y-m-d', strtotime($date))==$date) {

      // see if it's the earliest date
      if ((strtotime($date) < $earliest_date) || (!$earliest_date)) {
        $earliest_date = strtotime($date);
        //print ("New earliest:" . $date ."-->" . strtotime($date) . " " . date('Y-m-d', $earliest_date). "<--". $earliest_date . "\n");
      }
      if (!isset($faces[$date.'T'.$time])) {
        $faces[$date.'T'.$time] = $entry_name;
        //print($date . " x " . $time . " ");
        // make thumbnail
        $face_thumbnail_filename = 'thumbnails/'.$entry_name.'.thumbnail.jpg';
        if (!file_exists($face_thumbnail_filename)) {

          $shell_command = 'cp '.$images_directory.'/'.$entry_name.' '.$face_thumbnail_filename.' 2>&1';
          $output = shell_exec($shell_command);
          $shell_command = 'sips --resampleWidth 120 '.$face_thumbnail_filename.' 2>&1';
          $output = shell_exec($shell_command);

          /* Using ImageMagick:
          $shell_command = 'convert -define jpeg:size=100x80 '.$images_directory.'/'.$entry_name.' -auto-orient -thumbnail 250x90 -unsharp 0x.5  '.$face_thumbnail_filename.' 2>&1';
          $output = shell_exec($shell_command);
          */

          echo "<!-- made thumbnail for ".$entry_name."-->\n";
        }
      }
    }
  }
  elseif (strpos($entry_name,'screen_')===0) {
    $date = substr($entry_name,strlen('screen_'),4+1+2+1+2); 
    $time = substr($entry_name,strlen('screen_')+4+1+2+1+2+1,8); 
    // if (substr($time,3,2) != '00') {
    //   continue;
    // }    

    // drop the minutes and seconds..we don't care
    $time = substr($time,0,2);
    // check for valid date    
    if (date('Y-m-d', strtotime($date))==$date) { 
      if (!isset($screens[$date.'T'.$time])) {
        $screens[$date.'T'.$time] = $entry_name;
        //print($date . " x " . $time . " ");
        // make thumbnail
        $screen_thumbnail_filename = 'thumbnails/'.$entry_name.'.thumbnail.png';
        if (!file_exists($screen_thumbnail_filename)) {
          
          $shell_command = 'cp '.$images_directory.'/'.$entry_name.' '.$screen_thumbnail_filename.' 2>&1';
          $output = shell_exec($shell_command);
          $shell_command = 'sips --resampleWidth 120 '.$screen_thumbnail_filename.' 2>&1';
          $output = shell_exec($shell_command);

          /* Using ImageMagick
          $shell_command = 'convert -define jpeg:size=100x80 '.$images_directory.'/'.$entry_name.' -auto-orient -thumbnail 250x90 -unsharp 0x.5  '.$screen_thumbnail_filename.' 2>&1';
          $output = shell_exec($shell_command);
          */

          echo "<!-- made thumbnail for ".$entry_name."-->\n";
        }
      }
    }
  } 
  elseif (strpos($entry_name,'latlon_')===0) {
    $date = substr($entry_name,strlen('latlon_'),4+1+2+1+2); 
    $time = substr($entry_name,strlen('latlon_')+4+1+2+1+2+1,8); 
    // drop the minutes and seconds..we don't care
    $time = substr($time,0,2);
    // check for valid date    
    if (date('Y-m-d', strtotime($date))==$date) { 
      if (!isset($screens[$date.'T'.$time])) {
        $latlons[$date.'T'.$time] = $entry_name;
      }
    }
  }
}

// close directory
closedir($my_directory);

//
// create array of our dates and hours
//

// $current_date = '2011-12-21'; // Uncomment to manually set date of first record 
$current_date = date('Y-m-d', strtotime('previous sunday',$earliest_date));

$days = array();
while (strtotime($current_date) < time()) {
  $hours = array();
  for ($hour=0;$hour<24;$hour++) {
    $data = array();

    // on the hour
    $current_date_time = $current_date.'T'.($hour<10?'0':'') . $hour; // '-00-00'
    if ($faces[$current_date_time]) {
      $data['face'] = $faces[$current_date_time];
    }
    if ($screens[$current_date_time]) {
      $data['screen'] = $screens[$current_date_time];
    }
    if ($latlons[$current_date_time]) {
      $latlon = file_get_contents('../data/'.$latlons[$current_date_time]);
      if (trim($latlon)) {
        $data['latlon'] = $latlon;
      }
    }

    $hours[$hour.'-00'] = $data;
    unset($data);
    /*
    // now on the half hour
    $current_date_time = $current_date.'T'.$hour.'-30-00';
    if ($faces[$current_date_time]) {
      //print $faces[$current_date_time] . "<<<\n";
       $data = $faces[$current_date_time];      
    }
    else {
      $data = '';
    }
    $hours[$hour.'-30'] = $data;
    unset($data);
    */
  }
  $days[$current_date] = $hours;

  // move to next day
  $current_date_ts = strtotime($current_date);
  $current_date = date('Y-m-d', strtotime('+1 day', $current_date_ts)); 
}

?>
