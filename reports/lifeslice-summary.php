<html>

<head>

<title>LifeSlice Report</title>

<style>
  body {background-color:#000;color:white;font-family:helvetica,arial,sans-serif;text-shadow: black 1px 1px 1px}
  .hour {width:50px;height:40px;color:white;overflow:hidden;margin:0 0 0 0;padding 0 0 0 0;background-size:50px 40px;background-repeat:no-repeat;}
  .hour img {width:50px;height:40px;position:absolute;}
  .heading {background-color:#000;height:60px;text-align:center;}
  .total-hours {background-color:#000;width:50px; height: 60px;text-align:center; font-size:xx-large;}
  #face-table   {position:absolute;top:0px;z-index:1;}
  #screen-table {position:absolute;top:0px;z-index:2;display:none;}
  .screen-thumb {display:none;}
  table {border-collapse: collapse;}
  td {padding: 0 0 0 0; margin: 0 0 0 0;}

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
</head>

<body>

<?php

// load our data
require_once('lifeslice-load-data.php');

// render dates and hours
?>

<script>
$("body").keydown(function(e) {
  if(e.keyCode == 13) { // left
    //$("#screen-table").toggle();
    $(".screen-thumb").toggle();
    $(".face-thumb").toggle();
    alert('toggling');
  }
});
</script>

<?
/*
print "\n".'<table id="screen-table"><tr>';
foreach($days as $date=>$day){
  $do_labels = (date( "w", strtotime($date)) == 0);  
  print '<td>';
  $header=date( "Y n/j D", strtotime($date));
  $header=str_replace(' ','<br>',$header);
  print '<div class="hour heading">'.$header.'</div>';
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
*/

$weekly_latlons = array();
$current_week_latlons = array();
print "\n".'<table id="face-table"><tr>';
foreach($days as $date=>$day){
  $do_labels = (date( "w", strtotime($date)) == 0);

  if ($do_labels) {
    $weekly_latlons[$date]=$current_week_latlons;
    unset($current_week_latlons);
    $current_week_latlons = array();
  }

  print '<td>';
  $header=date( "n/j D", strtotime($date));
  $header=str_replace(' ','<br>',$header);  
  print '<div class="hour heading" >'.$header.'</div>';
  $filled_hour_count = 0;  
  foreach($day as $hour=>$data){
    $current_week_latlons[] = $data['latlon'];

    unset($img);
    unset($style);
    $face_thumb='thumbnails/'.$data['face'].'.thumbnail.jpg';
    $screen_thumb='thumbnails/'.$data['screen'].'.thumbnail.jpg';

    $img = ($data['face'] ? '<img src="thumbnails/'.$data['face'].'.thumbnail.jpg"/>' : '');
    print '<div class="hour" style="'.$style.'">';
    print '<a class="face-thumb" href="../data/'.$data['face'].'">'.$img.'</a>';

    $img = ($data['screen'] ? '<img src="thumbnails/'.$data['screen'].'.thumbnail.png"/>' : '');
    print '<a class="screen-thumb" href="../data/'.$data['screen'].'">'.$img.'</a>';

    $display_hour = intval(substr($hour, 0, -3));
    if ($display_hour>12) {
      $display_hour-=12;
    }
    if ($display_hour==0) {
      $display_hour=12;
    }
    print ($do_labels ? '<div style="position:abolute;top:0;right:0;">'.$display_hour.'</div>' : '');
    print '</div>'. "\n";
    $filled_hour_count += ($data['face']?1:0);
  }
  print "\n".'<div class="total-hours">' . ($filled_hour_count>0 ? $filled_hour_count : '') . '</div>';
  print "\n".'</td>';
}
print "\n".'</tr>';
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
  print '<td colspan="7"><div style="display:inline-block; width:350px; height:200px;">' . $latlons_url . '</div></td>';
}
print "\n".'</tr>';
print '</table>';



print '</body>';
print '</html>'
?>
