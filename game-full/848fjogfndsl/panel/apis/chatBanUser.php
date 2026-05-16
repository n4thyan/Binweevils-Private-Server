<?php
session_start();
error_reporting(0);
include('../../../essential/backbone.php');

if(isset($_GET)) {
    $adminName = $_SESSION['admin'];
    $adminPassword = $_SESSION['adminPassword'];
    $weevilName = $_GET['weevilName'];
    $duration = $_GET['duration'];
    $reason = $_GET['reasonForMute'];
    if(!empty($adminName) && !empty($adminPassword) && !empty($weevilName) && !empty($duration)) {
        $sock = new sock("144.91.93.101", 9339);
        $time = intval($duration) + 1;

        if($sock->ConnectToSocket()) {
            $sock->SendRawPackets("%xt%login%7#2%-1%$adminName%$adminPassword%$weevilName%$time%");
            $sock->CloseSocket();

            logAdminActionBans($adminName, $weevilName, strval(strtotime('+' . $duration . ' minutes', time())), strval(time()), 2, $reason);
        }
        else echo json_encode(["responseCode" => 999, "message" => "could not connect to servers."]);
    }
    else echo json_encode(["responseCode" => 999, "message" => "error occured."]);
}
else echo json_encode(["responseCode" => 999, "message" => "error occured."]);
?>