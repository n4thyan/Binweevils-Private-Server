<?php
include '../../../essential/backbone.php';
try{
    $description = $_GET['description'];
    $status = $_GET['status'];
    updateDevelopmentStatus($description, $status);
}
catch(Exception $e){
    echo "";
}

?>