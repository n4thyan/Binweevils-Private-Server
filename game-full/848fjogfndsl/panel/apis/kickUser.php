<?php
session_start();
error_reporting(0);
include('../../../essential/backbone.php');

if(isset($_GET)) {
    $adminName = $_SESSION['admin'];
    $adminPassword = $_SESSION['adminPassword'];
    $weevilName = $_GET['weevilName'];
    //echo $adminName . ":" . $adminPassword;

    if(!empty($adminName) && !empty($adminPassword) && !empty($weevilName)) {
        $sock = new sock("144.91.93.101", 9339);

        if($sock->ConnectToSocket()) {
            $sock->SendRawPackets("%xt%login%7#200%-1%$adminName%$adminPassword%$weevilName%");
            $sock->CloseSocket();

            logAdminAction($adminName, $weevilName, strval(time()), 1);
        }
        else echo json_encode(["responseCode" => 999, "message" => "could not connect to servers."]);
    }
    else echo json_encode(["responseCode" => 999, "message" => "error occured."]);
}
else echo json_encode(["responseCode" => 999, "message" => "error occured."]);
?>