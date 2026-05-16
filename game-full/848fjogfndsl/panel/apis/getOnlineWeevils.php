<?php
error_reporting(0);
include('../../../essential/backbone.php');

if(isset($_GET)) {
    $sock = new sock("144.91.93.101", 9339);

    if($sock->ConnectToSocket()) {
        $online = $sock->OnlineWeevils();
        $sock->CloseSocket();
        echo $online;
    }
    else echo json_encode(["responseCode" => 999, "message" => "could not connect to servers."]);
}
else echo json_encode(["responseCode" => 999, "message" => "error occured."]);
?>