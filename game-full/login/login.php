<?php
error_reporting(0);
include('../essential/backbone.php');

function verifyUser($username, $password) {
    $aes = new AES256();
    $loginIP = GetIP();
    /*if($_SERVER['REMOTE_ADDR'] != "32.211.183.44") {
        header("Location: https://play.bwrewritten.com/?err=" . urlencode($aes->encrypt("#UnbanJjs https://discord.gg/F9F6zN8RhY", "hdjjsdarkkarecool")));
        return;
    }*/

    if(!empty($username) && !empty($password)) {
        echo "gi";
        $db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
		$q = $db->prepare("SELECT * FROM users WHERE username = ? LIMIT 1;");
		$q->bind_param('s', $username);
		$q->execute();
		
        $res = $q->get_result();
        
        if($res = $res->fetch_array()) {
            if($password == $res['password']) {
                if($res["active"] == 1) {
                    $bannedUntil = json_decode(time_until(time(), $res['bannedUntil']));

                    if($bannedUntil->days <= 0 && $bannedUntil->hours <= 0 && $bannedUntil->minutes <= 0 && $bannedUntil->seconds <= 0) {
                        // logged in successfully, set everything
                        $sessKey = generateSessionKey();
                        $logKey = generateLogKey();
                        $timestamp = time();
                        
                        $db->query("UPDATE users SET sessionKey = '" . $sessKey . "', loginKey = '" . $logKey . "', lastLogin = '" . $timestamp . "', loginIP = '" . $loginIP . "' WHERE username = '" . $username . "';");

                        setcookie("sessionId", $sessKey, time() + 86400, '/'); // Eh ... we'll leave it for now ...
                        setcookie("weevil_name", $res['username'], time() + 86400, '/');
                            
                        header('Location: ../game.php');
                    }
                    else header("Location: http://localhost/?err=" . urlencode($aes->encrypt("This account has been temporarily banned for:<br>" . $bannedUntil->days . " days, " . $bannedUntil->hours . " hours, " . $bannedUntil->minutes . " minutes, " . $bannedUntil->seconds . " seconds.", "hdjjsdarkkarecool")));
                }
                else header("Location: http://localhost/?err=" . urlencode($aes->encrypt("This account has been permanently banned.", "hdjjsdarkkarecool")));
            }
            else header("Location: http://localhost/?err=" . urlencode($aes->encrypt("Username or password is incorrect!", "hdjjsdarkkarecool")));
        }
        else header("Location: http://localhost/?err=" . urlencode($aes->encrypt("Username or password is incorrect!", "hdjjsdarkkarecool")));
    }
    else header("Location: http://localhost/?err=" . urlencode($aes->encrypt("Username or password is incorrect!", "hdjjsdarkkarecool")));
}

function logout() {
    if(isset($_COOKIE['weevil_name']) && isset($_COOKIE['sessionId'])) {
        $weevil_name = $_COOKIE['weevil_name'];
        //session_destroy();
        setcookie("sessionId", $_COOKIE['sessionId'], time() - 86400, '/'); // Eh ... we'll leave it for now ...
        setcookie("weevil_name", $_COOKIE['weevil_name'], time() - 86400, '/');
        session_destroy();

        $db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
		$q = $db->prepare("SELECT * FROM users WHERE username = ? LIMIT 1;");
		$q->bind_param('s', $weevil_name);
		$q->execute();
		
        $res = $q->get_result();
        
        if($res = $res->fetch_array()) {
            $db->query("UPDATE users SET sessionKey = '', loginKey = '' WHERE id = " . $res['id'] . ";");
        }
    }

    header("Location: ../");
}

if(isset($_POST['userID']) && isset($_POST['password'])) {
    $username = $_POST['userID'];
    $password = $_POST['password'];

    verifyUser($username, $password);
}
else logout();
?>