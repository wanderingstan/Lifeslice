<?php

// load our data
require_once('lifeslice-load-data.php');

// render dates and hours


$weekly_latlons = array();
$current_week_latlons = array();
foreach($days as $date=>$day){
  foreach($day as $hour=>$data){
    $filename = './hourly/'.$date.'T'.$hour.'.html';
    $face_filename = '../data/'.$data['face'];
    $screen_filename = '../data/'.$data['screen'];
    print_r($data);

    if (($data['face']) && (!file_exists($filename)) && file_exists($face_filename) && file_exists($screen_filename)) {
      $out .= '<html><head><style></style></head><body bgcolor="black">';
      $current_week_latlons[] = $data['latlon'];
      $out .= '<h1 style="font-family: helvetica; color:white;">'.$date.' '.$hour.'</h1>';
      $out .= '<table style=""><tr><td style="width:45%;" >';
      $out .= '<img style="width:100%" src="../'.$face_filename.'"/>';
      $out .= '</td><td style="width:45%;" >';
      $out .= '<img style="width:100%" src="../'.$screen_filename.'"/>';
      $out .= '</td></tr></table>';
      $out .= '</body><html>';
      $fh = fopen($filename, 'w') or die("can't open file:".$filename);
      fwrite($fh, $out);
      fclose($fh);

      unset($out);
    }
  }
}

?>
