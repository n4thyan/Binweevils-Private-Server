<?php
include '../../../essential/backbone.php';
try{
    $name = $_GET['name'];
    $description = $_GET['description'];
    $icon = $_GET['icon'];
    AddDevelopmentTask($name, $description, $icon);
}
catch(Exception $e){
    echo "";
}

?>