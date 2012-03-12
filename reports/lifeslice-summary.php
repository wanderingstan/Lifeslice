<html>
<style>
  body {background-color:#000;color:white;font-family:helvetica,arial,sans-serif;text-shadow: black 1px 1px 1px}
  .hour {width:50px;height:40px;color:white;overflow:hidden;margin:0 0 0 0;padding 0 0 0 0;background-size:50px 40px;background-repeat:no-repeat;}
  .hour img {width:50px;height:40px;position:absolute;}
  .heading {background-color:#000;}
  .total-hours {background-color:#000;width:50px; height: 40px;text-align:center; font-size:xx-large;}
  #face-table   {position:absolute;top:0px;z-index:1;}
  #screen-table {position:absolute;top:0px;z-index:2;display:none;}
  table {border-collapse: collapse;}
  td {padding: 0 0 0 0; margin: 0 0 0 0;}
</style>


<!-- <script src="js/jquery-1.7.1.min.js"></script> -->
<script type="text/javascript" src="http://code.jquery.com/jquery-1.4.2.min.js"></script>

<body>

<?php

$screens = array();
$face = array();

// check for thumbnails dir
if (!is_dir('thumbnails')) {
  mkdir('thumbnails');
}

// open directory 
$images_directory = ".."; // (we're assuming images are one directory above us)
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
        print ("New earliest:" . $date ."-->" . strtotime($date) . " " . date('Y-m-d', $earliest_date). "<--". $earliest_date . "\n");
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
}

// close directory
closedir($my_directory);

// create array of our dates and hours
// $current_date = '2011-12-21'; // date of first record 
$current_date = date('Y-m-d', $earliest_date);

$days = array();
while (strtotime($current_date) < time()) {
  $hours = array();
  for ($hour=0;$hour<24;$hour++) {
    // on the hour
    $current_date_time = $current_date.'T'.($hour<10?'0':'') . $hour; // '-00-00'
    if ($faces[$current_date_time]) {
      //print $faces[$current_date_time] . "<<<\n";
      $data['face'] = $faces[$current_date_time];
    }
    if ($screens[$current_date_time]) {
      //print $faces[$current_date_time] . "<<<\n";
      $data['screen'] = $screens[$current_date_time];
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
//print_r($days);

// render dates and hours
?>



<script>
$("body").keydown(function(e) {
  if(e.keyCode == 13) { // left
    $("#screen-table").toggle();
  }
});
</script>

<?
print "\n".'<table id="screen-table"><tr>';
foreach($days as $date=>$day){
  $do_labels = (date( "w", strtotime($date)) == 0);  
  print '<td>';
  print '<div class="hour heading">'.$date.'</div>';
  foreach($day as $hour=>$data){
    $screen_thumb='thumbnails/'.$data['screen'].'.thumbnail.png';
    $style = (($data['screen'] && $data['face']) ? $style='background-image:url(thumbnails/'.$data['screen'].'.thumbnail.png)' : '');
    print '<div class="hour" style="'.$style.'">';
    print $img;
//    print '<div style="position:abolute;top:0;right:0;">'.($data['screen']?substr($hour, 0, -3):'').'</div>';
    print ($do_labels ? '<div style="position:abolute;top:0;right:0;">'.substr($hour, 0, -3).'</div>' : '');
    print '</div>'. "\n";
  }
  print '</td>';
}
print "\n".'</tr></table>';

print "\n".'<table id="face-table"><tr>';
foreach($days as $date=>$day){
  $do_labels = (date( "w", strtotime($date)) == 0);
  print '<td>';
  print '<div class="hour heading">'.$date.'</div>';
  $filled_hour_count = 0;  
  foreach($day as $hour=>$data){
    $face_thumb='thumbnails/'.$data['face'].'.thumbnail.jpg';
    $screen_thumb='thumbnails/'.$data['screen'].'.thumbnail.jpg';
    $style = (($data['screen'] && $data['face']) ? $style='background-image:url(thumbnails/'.$data['face'].'.thumbnail.jpg)' : '') . ';';
//    $style .= 'background-color:#00'.(7-min(abs(12-$hour),7));
//    $style .= 'background-color:' . (($hour>6) && ($hour<18) ? '#82CAFF' : '#000');
    //$img = ($data['face'] ? '<img src="thumbnails/'.$data['face'].'.thumbnail.jpg"/>' : '');
    //$img = ($data['face'] ? '<img src="'.$face_thumb.'" onmouseover="alert(\'yo\');this.src='.$screen_thumb.'" onmouseout="this.src='.$face_thumb.'"/>' : '');
    // with mouseover
    //$img = ($data['face'] ? "<img src='".$face_thumb."' onmouseover='this.src=\"" . $screen_thumb . "\"' onmouseout='this.src=\"" . $face_thumb . "\"'/>" : '');

    print '<div class="hour" style="'.$style.'">';
    print $img;
//    print '<div style="position:abolute;top:0;right:0;">'.($data['screen']?substr($hour, 0, -3):'').'</div>';
    print ($do_labels ? '<div style="position:abolute;top:0;right:0;">'.substr($hour, 0, -3).'</div>' : '');
    print '</div>'. "\n";
    $filled_hour_count += ($data['face']?1:0);
  }
  print "\n".'<div class="total-hours">' . $filled_hour_count . '</div>';
  print "\n".'</td>';
}
print "\n".'</tr></table>';



print '</body>';
print '</html>'
?>
