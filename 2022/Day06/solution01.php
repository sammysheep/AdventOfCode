<?php
// Sam Shepard - 2022

$data = str_split(file_get_contents("input.txt"));

for($offset = 0; $offset < sizeof($data) - 4; $offset++ ){
    $set = array();
    $window = array_slice($data,$offset,4);
    foreach ( $window as &$c ) {
        $set[$c] = 1;
    }
    
    if ( sizeof($set) == 4) {
        $offset += 4;
        echo "'" . implode("", $window). "' at $offset\n";
        break;
    }
}
?>
