<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
include('../../essential/backbone.php');

function bwRedeemFail($code) {
    echo 'responseCode=' . $code;
    exit;
}

if(!isset($_POST['code']) || !isset($_POST['userIDX'])) {
    bwRedeemFail(999);
}

$code = trim($_POST['code']);
$id = intval($_POST['userIDX']);

if($code === '' || $id <= 0) {
    bwRedeemFail(3);
}

if(!isset($_COOKIE['weevil_name']) || !isset($_COOKIE['sessionId'])) {
    bwRedeemFail(3);
}

if(confirmSessionKey($_COOKIE['weevil_name'], $_COOKIE['sessionId']) != true) {
    bwRedeemFail(3);
}

$weevilData = getAllWeevilStats($id);

if($weevilData == false || !isset($weevilData['username'])) {
    bwRedeemFail(3);
}

if(strtolower($weevilData['username']) !== strtolower($_COOKIE['weevil_name'])) {
    bwRedeemFail(3);
}

$db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if($db->connect_error) {
    bwRedeemFail(3);
}

$db->begin_transaction();

try {
    $q = $db->prepare("SELECT * FROM rewardCodes WHERE redeemable = 1 AND code = ? AND quantity != 0 LIMIT 1 FOR UPDATE;");
    $q->bind_param('s', $code);
    $q->execute();
    $res = $q->get_result();
    $rewards = $res->fetch_array(MYSQLI_ASSOC);

    if(!$rewards) {
        $db->rollback();
        bwRedeemFail(3);
    }

    $q = $db->prepare("SELECT COUNT(*) FROM redeemedCodes WHERE useridx = ? AND code = ?;");
    $q->bind_param('is', $id, $code);
    $q->execute();
    $res = $q->get_result();
    $redeemed = $res->fetch_array();

    if(intval($redeemed[0]) > 0) {
        $db->rollback();
        bwRedeemFail(2);
    }

    $xp = intval($rewards['xp']);
    $mulch = intval($rewards['mulch']);
    $dosh = intval($rewards['dosh']);
    $item = intval($rewards['item']);
    $seed = intval($rewards['seed']);
    $gardenItem = intval($rewards['gardenItem']);

    if($mulch > 0) {
        $q = $db->prepare("UPDATE users SET mulch = mulch + ? WHERE id = ?;");
        $q->bind_param('ii', $mulch, $id);
        $q->execute();

        if($q->affected_rows != 1) {
            throw new Exception('mulch reward failed');
        }
    }

    if($dosh > 0) {
        $q = $db->prepare("UPDATE users SET dosh = dosh + ? WHERE id = ?;");
        $q->bind_param('ii', $dosh, $id);
        $q->execute();

        if($q->affected_rows != 1) {
            throw new Exception('dosh reward failed');
        }
    }

    if($xp > 0) {
        $q = $db->prepare("UPDATE users SET xp = xp + ? WHERE id = ?;");
        $q->bind_param('ii', $xp, $id);
        $q->execute();

        if($q->affected_rows != 1) {
            throw new Exception('xp reward failed');
        }
    }

    if($item > 0) {
        if(rewardItem($id, $item) != true) {
            throw new Exception('item reward failed');
        }
    }

    if($seed > 0) {
        if(rewardSeed($seed) != true) {
            throw new Exception('seed reward failed');
        }
    }

    if($gardenItem > 0) {
        if(rewardGardenItem($gardenItem) != true) {
            throw new Exception('garden item reward failed');
        }
    }

    $q = $db->prepare("INSERT INTO redeemedCodes (`useridx`, `code`) VALUES (?, ?);");
    $q->bind_param('is', $id, $code);
    $q->execute();

    if($q->affected_rows != 1) {
        throw new Exception('redeemed code insert failed');
    }

    $q = $db->prepare("UPDATE rewardCodes SET quantity = quantity - 1 WHERE code = ?;");
    $q->bind_param('s', $code);
    $q->execute();

    if($q->affected_rows != 1) {
        throw new Exception('quantity update failed');
    }

    $q = $db->prepare("SELECT mulch, xp, dosh FROM users WHERE id = ? LIMIT 1;");
    $q->bind_param('i', $id);
    $q->execute();
    $res = $q->get_result();
    $latest = $res->fetch_array(MYSQLI_ASSOC);

    if(!$latest) {
        throw new Exception('latest user values failed');
    }

    $db->commit();

    echo 'responseCode=1'
        .'&latestMulchValue='.strval($latest['mulch'])
        .'&mulchReward='.strval($mulch)
        .'&xpReward='.strval($xp)
        .'&latestXPValue='.strval($latest['xp'])
        .'&doshReward='.strval($dosh)
        .'&latestDoshValue='.strval($latest['dosh'])
        .'&seedReward='.strval($seed)
        .'&gardenItem='.strval($gardenItem)
        .'&itemReward='.strval($item);
}
catch(Exception $e) {
    $db->rollback();
    echo 'responseCode=3';
}
?>
