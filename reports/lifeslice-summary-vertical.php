<html>
<head>
<title>LifeSlice Report</title>
<style>
/*
  @font-face { font-family: "Ostrich"; font-weight: normal;  src: url('./ostrich-sans/ostrich-regular.ttf') format("truetype"); }
  @font-face { font-family: "Ostrich"; font-weight: bold;    src: url('./ostrich-sans/ostrich-bold.otf') format("truetype");; }
  @font-face { font-family: "Ostrich"; font-weight: bolder;  src: url('./ostrich-sans/ostrich-black.otf') format("truetype");; }
  @font-face { font-family: "Ostrich"; font-weight: lighter; src: url('./ostrich-sans/ostrich-light.otf') format("truetype");; }
*/

  body {background-color:#000;color:white;font-family:Ostrich,helvetica,arial,sans-serif;text-shadow: black 1px 1px 1px}
  .hour {width:50px;height:40px;color:white;overflow:hidden;margin:0 0 0 0;padding 0 0 0 0;background-size:50px 40px;background-repeat:no-repeat;}
  .hour img {width:50px;height:40px;position:absolute;}
  .heading {background-color:#000;height:40px;text-align:right; font-size:40px;padding-right:5px;}
  .total-hours {background-color:#000;width:50px; height: 40px;text-align:left; font-size:40px; padding-left:5px;}
  .hour-label {font-family: Ostrich, helvetica,arial,sans-serif; font-size: 25px; width:100%; text-align:right;}
  #face-table   {position:absolute;top:100px;z-index:1;}
  #screen-table {position:absolute;top:100px;z-index:2;display:none;}
  .screen-thumb {display:none;}
  table {border-collapse: collapse;}
  td {padding: 0 0 0 0; margin: 0 0 0 0; border: height: 40px;}

  .floatingHeader {
    position: fixed;
    top: 0;
    visibility: hidden;
  }

  #lightbox-image {
    max-width: 800px;
    max-height: 500px;
  }
  #lightbox-container-image-box, 
  #lightbox-container-image-data-box {
    max-width: 850px;
    max-height: 550px;
  }

  h1 {
    margin: 0px;
    margin-right: 10px;        
    color: #92D270;
    font-size:60px;
    font-family: helvetica, arial, sans-serif;
    letter-spacing: -3px;
    display: inline-block;    
  }

</style>

<!--<script type="text/javascript" src="http://code.jquery.com/jquery-1.4.2.min.js"></script>-->
<!--<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>-->
<script type="text/javascript" src="js/jquery.min.1.6.2.js"></script>

<!-- lightbox -->
<script type="text/javascript" src="js/jquery.lightbox-0.5.js"></script>
<link rel="stylesheet" type="text/css" href="css/jquery.lightbox-0.5.css" media="screen" />
<script type="text/javascript">
$(function() {
    $('#face-table a').lightBox();
});
</script>

</head>
<h1>LifeSlice</h1>
<div>Be sure to bookmark this page so you can see it later. Check for <a href="https://github.com/wanderingstan/Lifeslice">updates here</a>. Use Command +/- to zoom in and out.</div>
<body>
<script>
//$('#jquery-overlay').width($(window).width()).height($(window).height());
</script>
<?php
// load our data
require_once('lifeslice-load-data.php');

// reverse dates (So that most recent is at the top)
$days = array_reverse($days);

// render dates and hours
?>

<script>
$("body").keydown(function(e) {
  if(e.keyCode == 13) { 
    //$("#screen-table").toggle();
    $(".screen-thumb").toggle();
    $(".face-thumb").toggle();
    alert($(".face-thumb").length + "=face  " + $(".screen-thumb").length + "=screen");
  }
});
</script>

<?php

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
  $header=date( "n/j", strtotime($date));
  $header=str_replace(' ','&nbsp;',$header);
  //$header=str_replace(' ','<br>',$header);  
  print '<td class="hour heading" >'.$header.'<td>';

  $filled_hour_count = 0;  
  foreach($day as $hour=>$data){
    $current_week_latlons[] = $data['latlon'];

    unset($img);
    unset($style);

    print '<td><div class="hour">';
    if ($data['face']) {
      $img = '<img src="thumbnails/'.$data['face'].'.thumbnail.jpg"/>';
      print '<a class="face-thumb" href="../data/'.$data['face'].'">'.$img.'</a>';  
      if ($data['screen']) {
        $img = '<img src="thumbnails/'.$data['screen'].'.thumbnail.png"/>';
        print '<a class="screen-thumb" href="../data/'.$data['screen'].'">'.$img.'</a>';          
      }
    }
    
    $display_hour = intval(substr($hour, 0, -3));
    if ($display_hour>12) {
      $display_hour-=12;
    }
    if ($display_hour==0) {
      $display_hour=12;
    }
    print ($do_labels ? '<div class="hour-label" style="position:abolute;top:0;right:0;">'.$display_hour.'</div>' : '');
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
