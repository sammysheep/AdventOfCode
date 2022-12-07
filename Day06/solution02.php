<?php
// Sam Shepard - 2022

$data = str_split(file_get_contents("input.txt"));

for($offset = 0; $offset < sizeof($data) - 14; $offset++ ){
    $set = array();
    $window = array_slice($data,$offset,14);
    foreach ( $window as &$c ) {
        $set[$c] = 1;
    }
    
    if ( sizeof($set) == 14) {
        $offset += 14;
        echo "'" . implode("", $window). "' at $offset\n";
        break;
    }
}
?>
