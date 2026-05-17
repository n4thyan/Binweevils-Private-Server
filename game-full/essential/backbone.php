<?php
    error_reporting(0);
    
    if(session_status() === PHP_SESSION_NONE)
    session_start();

    foreach(['sessionId', 'weevil_name'] as $bw_cookie_name) {
        if(isset($_COOKIE[$bw_cookie_name]) && trim((string) $_COOKIE[$bw_cookie_name]) === '') {
            unset($_COOKIE[$bw_cookie_name]);
            setcookie($bw_cookie_name, '', time() - 86400, '/');
        }
    }
    unset($bw_cookie_name);
    
    header("X-XSS-Protection: 1; mode=block");
    header("X-Content-Type-Options: nosniff");
    //header_status(500);
    /*foreach($_POST as $data){
        echo $data;
    }*/
    include_once(dirname(__FILE__) . '/checksum.php');
    if(isset($_POST))
    $checksum = new Checksum($_POST);
    /*if($checksum != $_POST['checksum']){
        header_status(500);
    }*/


	include_once(dirname(__FILE__) . '/config.php');
	include_once(dirname(__FILE__) . '/internal.php');
	include_once(dirname(__FILE__) . '/protections.php'); // Their anti reverse-engineer system rewritten!
    include_once(dirname(__FILE__) . '/aes256.php');
    include_once(dirname(__FILE__) . '/funcs.php');
    include_once(dirname(__FILE__) . '/sock.php');
    //echo $checksum;
?>
