<html>
<style>
  body {background-color:#000;color:white;font-family:helvetica,arial,sans-serif;text-shadow: black 1px 1px 1px}
  .hour {width:50px;height:40px;color:white;overflow:hidden;margin:0 0 0 0;padding 0 0 0 0;background-size:50px 40px;background-repeat:no-repeat;}
  .hour img {width:50px;height:40px;position:absolute;}
  .heading {background-color:#000;height:40px;text-align:center;}
  .total-hours {background-color:#000;width:50px; height: 40px;text-align:center; font-size:xx-large;}
  #face-table   {position:absolute;top:0px;z-index:1;}
  #screen-table {position:absolute;top:0px;z-index:2;display:none;}
  .screen-thumb {display:none;}
  table {border-collapse: collapse;}
  td {padding: 0 0 0 0; margin: 0 0 0 0; border: height: 40px;}

  .floatingHeader {
    position: fixed;
    top: 0;
    visibility: hidden;
  }

  .lightbox-image {
    max-width: 800px;
    max-height: 600px;
  }

</style>

<!--<script type="text/javascript" src="http://code.jquery.com/jquery-1.4.2.min.js"></script>-->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>

<!-- lightbox -->
<script type="text/javascript" src="js/jquery.lightbox-0.5.js"></script>
<link rel="stylesheet" type="text/css" href="css/jquery.lightbox-0.5.css" media="screen" />
<script type="text/javascript">
$(function() {
    $('#face-table a').lightBox();
});
</script>

<body>

<?php

$screens = array();
$face = array();
$latlons = array();
// check for thumbnails dir
if (!is_dir('thumbnails')) {
  mkdir('thumbnails');
}

// open directory 
$images_directory = "../data"; // (we're assuming images are one directory above us)
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
    if (date('Y-m-d', strtotime($date))==$date) {

      // see if it's the earliest date
      if ((strtotime($date) < $earliest_date) || (!$earliest_date)) {
        $earliest_date = strtotime($date);
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

// create array of our dates and hours
// $current_date = '2011-12-21'; // date of first record 
$current_date = date('Y-m-d', strtotime('previous sunday',$earliest_date));

$days = array();
while (strtotime($current_date) < time()) {
  $hours = array();
  for ($hour=0;$hour<24;$hour++) {
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

// reverse dates
$days = array_reverse($days);


// render dates and hours
?>


<script>
$("body").keydown(function(e) {
  if(e.keyCode == 13) { // left
    //$("#screen-table").toggle();
    $(".screen-thumb").toggle();
    $(".face-thumb").toggle();
  }
});
</script>

<?

$weekly_latlons = array();
$current_week_latlons = array();
print "\n".'<table id="face-table">';
foreach($days as $date=>$day){
  print '<tr>';
  $do_labels = (date( "w", strtotime($date)) == 0);

  // keep track of weekly locations
  if ($do_labels) {
    $weekly_latlons[$date]=$current_week_latlons;
    unset($current_week_latlons);
    $current_week_latlons = array();
  }

  // day header
  $header=date( "n/j D", strtotime($date));
  //$header=str_replace(' ','<br>',$header);  
  print '<td class="hour heading" >'.$header.'<td>';

  $filled_hour_count = 0;  
  foreach($day as $hour=>$data){
    $current_week_latlons[] = $data['latlon'];

    unset($img);
    unset($style);
    $face_thumb='thumbnails/'.$data['face'].'.thumbnail.jpg';
    $screen_thumb='thumbnails/'.$data['screen'].'.thumbnail.jpg';

    $img = ($data['face'] ? '<img src="thumbnails/'.$data['face'].'.thumbnail.jpg"/>' : '');
    print '<td><div class="hour">';
//    print '<div class="hour" style="'.$style.'">';
    print '<a class="face-thumb" href="../data/'.$data['face'].'">'.$img.'</a>';

//    $img = ($data['screen'] ? '<img src="thumbnails/'.$data['screen'].'.thumbnail.png"/>' : '');
//    print '<a class="screen-thumb" href="../'.$data['screen'].'">'.$img.'</a>';

    $display_hour = intval(substr($hour, 0, -3));
    if ($display_hour>12) {
      $display_hour-=12;
    }
    if ($display_hour==0) {
      $display_hour=12;
    }
    print ($do_labels ? '<div style="position:abolute;top:0;right:0;">'.$display_hour.'</div>' : '');
    print '</div>';
    print '</td>';
    $filled_hour_count += ($data['face']?1:0);
  }
  print "\n".'<td class="total-hours">' . ($filled_hour_count?$filled_hour_count:'') . '</td>';
  print "\n".'</tr>';
}

/*
print "\n".'<tr>';
array_shift($weekly_latlons);
foreach($weekly_latlons as $date=>$current_week_latlons){
  unset($latlons_url);
  $current_week_latlons = array_unique($current_week_latlons);
  foreach($current_week_latlons as $latlon) {
    if ($latlon) {
      $latlons_url .= 'mcenter,'.$latlon . "|";
    }
  }
  if ($latlons_url) {
    $latlons_url = '<img src="http://open.mapquestapi.com/staticmap/v3/getmap?size=350,200&type=map&pois=' . $latlons_url . '&imagetype=PNG" />';
  }
  print '<td colspan="7"><div style="display:inline-block; width:350px; height:200px;">' . $latlons_url . '<br>'.$date . '</div></td>';
}
print "\n".'</tr>';
*/

print '</table>';



print '</body>';
print '</html>'
?>
