<?php
error_reporting(0);
include('../../essential/backbone.php');

if(isset($_COOKIE['weevil_name']) && isset($_COOKIE['sessionId'])) {
    $username = $_COOKIE['weevil_name'];
    $key = $_COOKIE['sessionId'];

    if(confirmSessionKey($username, $key)) {
        session_destroy();
        $db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
		$q = $db->prepare("SELECT * FROM users WHERE username = ? LIMIT 1;");
		$q->bind_param('s', $username);
		$q->execute();
		
        $res = $q->get_result();

        if($res = $res->fetch_array()) {
            $db->query("UPDATE users SET sessionKey = '', loginKey = '' WHERE id = " . $res['id'] . ";");
        }
        else header("Location: ../../game.php");
    }
    else header("Location: ../../game.php");
}
else header("Location: ../../game.php");

?>