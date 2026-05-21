<?php
$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$baseUrl = $scheme . '://' . $_SERVER['HTTP_HOST'];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account | Bin Weevils Private Server</title>
    <meta name="description" content="Create your Bin Weevils Private Server account and jump into classic Bin Weevils gameplay with custom community features.">
    <link rel="icon" type="image/png" href="/assets/images/icons/favicon.ico">
    <link rel="stylesheet" href="/assets/css/bwps-site-refresh.css">
    <link rel="stylesheet" href="/assets/css/bulma.min.css">
    <link rel="stylesheet" href="/assets/css/font-awesome.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Fredoka+One&family=McLaren&family=Nunito:wght@400;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/@sweetalert2/theme-dark@3/dark.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@9/dist/sweetalert2.min.js"></script>
    <style>
        body.bwps-public-page {
            min-height: 100vh;
            margin: 0;
            background: #70c940 url('/assets/images/bg.png') center top repeat;
            font-family: 'Nunito', Arial, sans-serif;
        }

        .bwps-shell {
            width: min(1080px, calc(100% - 32px));
            margin: 0 auto;
            padding: 22px 0 34px;
        }

        .bwps-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 14px;
        }

        .bwps-logo img {
            width: 190px;
            max-width: 42vw;
            display: block;
        }

        .bwps-nav {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: flex-end;
            gap: 8px;
        }

        .bwps-nav a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 36px;
            padding: 7px 14px;
            border-radius: 18px;
            background: linear-gradient(#ffed78, #ffc928);
            color: #6c3900;
            font-family: 'McLaren', 'Nunito', sans-serif;
            font-weight: 800;
            text-decoration: none;
            border: 2px solid rgba(124, 68, 0, .35);
            box-shadow: 0 3px 0 rgba(99, 58, 0, .25);
        }

        .bwps-nav a:hover {
            color: #3f2400;
            transform: translateY(1px);
        }

        .bwps-main-card {
            position: relative;
            overflow: hidden;
            min-height: 620px;
            border-radius: 28px;
            border: 5px solid #7b4b18;
            background: linear-gradient(180deg, rgba(255, 196, 63, .96), rgba(237, 133, 28, .96));
            box-shadow: 0 14px 0 rgba(87, 43, 0, .22), 0 18px 44px rgba(45, 20, 0, .28);
        }

        .bwps-main-card::before {
            content: '';
            position: absolute;
            inset: 14px;
            border-radius: 20px;
            border: 2px solid rgba(255, 255, 255, .28);
            pointer-events: none;
        }

        .bwps-hero-art-left,
        .bwps-hero-art-right {
            position: absolute;
            z-index: 1;
            bottom: 30px;
            max-height: 430px;
            pointer-events: none;
        }

        .bwps-hero-art-left {
            left: 18px;
            width: 260px;
            object-fit: contain;
        }

        .bwps-hero-art-right {
            right: 18px;
            width: 280px;
            object-fit: contain;
        }

        .bwps-register-content {
            position: relative;
            z-index: 2;
            width: min(520px, calc(100% - 40px));
            margin: 0 auto;
            padding: 74px 0 58px;
            text-align: center;
        }

        .bwps-register-content h1 {
            margin: 0 0 10px;
            color: #fff7d0;
            font-family: 'Fredoka One', 'McLaren', cursive;
            font-size: clamp(2.2rem, 5vw, 3.6rem);
            line-height: 1;
            text-shadow: 0 4px 0 #8a3d00, 0 6px 12px rgba(0,0,0,.25);
        }

        .bwps-register-copy {
            margin: 0 auto 20px;
            max-width: 480px;
            color: #673600;
            font-family: 'McLaren', 'Nunito', sans-serif;
            font-size: 1.05rem;
            font-weight: 700;
        }

        .bwps-register-panel {
            margin: 0 auto;
            padding: 22px;
            border-radius: 24px;
            background: rgba(255, 244, 194, .94);
            border: 4px solid rgba(115, 62, 0, .45);
            box-shadow: inset 0 2px 0 rgba(255,255,255,.65), 0 8px 0 rgba(110, 57, 0, .2);
            text-align: left;
        }

        .bwps-field {
            margin-bottom: 15px;
        }

        .bwps-field label {
            display: block;
            margin-bottom: 6px;
            color: #6a3900;
            font-family: 'McLaren', 'Nunito', sans-serif;
            font-weight: 800;
            font-size: 1rem;
        }

        .bwps-field input {
            width: 100%;
            box-sizing: border-box;
            min-height: 46px;
            padding: 10px 13px;
            border-radius: 14px;
            border: 3px solid #9f6416;
            background: #fffdf3;
            color: #442400;
            font-family: 'Nunito', Arial, sans-serif;
            font-size: 1.05rem;
            outline: none;
        }

        .bwps-field input:focus {
            border-color: #ffbc20;
            box-shadow: 0 0 0 4px rgba(255, 203, 59, .35);
        }

        .bwps-submit-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            align-items: center;
            justify-content: center;
            margin-top: 18px;
        }

        .bwps-yellow-btn {
            border: 0;
            border-radius: 999px;
            padding: 12px 24px;
            min-height: 46px;
            cursor: pointer;
            background: linear-gradient(#fff27b, #ffc51d 55%, #efa000);
            color: #6d3900;
            font-family: 'McLaren', 'Nunito', sans-serif;
            font-size: 1rem;
            font-weight: 900;
            text-decoration: none;
            box-shadow: 0 5px 0 #9b5a00, 0 8px 16px rgba(55, 25, 0, .24);
        }

        .bwps-yellow-btn:hover {
            color: #462400;
            transform: translateY(1px);
            box-shadow: 0 4px 0 #9b5a00, 0 7px 14px rgba(55, 25, 0, .22);
        }

        .bwps-login-link {
            color: #6a3900;
            font-weight: 800;
            text-decoration: underline;
        }

        .bwps-footer-nav,
        .bwps-footer-copy {
            margin-top: 14px;
            border-radius: 18px;
            background: rgba(255, 238, 166, .94);
            border: 3px solid rgba(105, 59, 7, .35);
            box-shadow: 0 5px 0 rgba(88, 49, 0, .16);
        }

        .bwps-footer-nav {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 22px;
            padding: 12px;
            font-family: 'McLaren', 'Nunito', sans-serif;
            font-weight: 800;
        }

        .bwps-footer-nav a {
            color: #6b3900;
            text-decoration: none;
        }

        .bwps-footer-nav img {
            height: 30px;
        }

        .bwps-footer-copy {
            padding: 15px 22px;
            text-align: center;
            color: #704000;
            font-weight: 700;
        }

        .bwps-footer-copy p {
            margin: 0 0 6px;
        }

        .bwps-footer-copy p:last-child {
            margin-bottom: 0;
        }

        @media (max-width: 860px) {
            .bwps-topbar {
                flex-direction: column;
            }

            .bwps-nav {
                justify-content: center;
            }

            .bwps-hero-art-left,
            .bwps-hero-art-right {
                opacity: .2;
                width: 220px;
            }

            .bwps-footer-nav {
                flex-wrap: wrap;
                gap: 12px;
            }
        }
    </style>
</head>
<body class="bwps-public-page">
    <div class="bwps-shell">
        <header class="bwps-topbar">
            <a class="bwps-logo" href="/"><img src="/assets/images/logo.png" alt="Bin Weevils Private Server"></a>
            <nav class="bwps-nav" aria-label="Main navigation">
                <a href="/">Home</a>
                <a href="/play/">Play</a>
                <a href="/blog/">Blog</a>
                <a href="/help/">Help</a>
                <a href="/legal/">Legal</a>
                <a href="/login/">Login</a>
            </nav>
        </header>

        <main class="bwps-main-card">
            <img class="bwps-hero-art-left" src="/assets/images/login/Tink_Clott.png" alt="">
            <img class="bwps-hero-art-right" src="/assets/images/weevil.png" alt="">

            <section class="bwps-register-content" aria-labelledby="register-title">
                <h1 id="register-title">Create Your Weevil</h1>
                <p class="bwps-register-copy">Pick your Bin Weevil name, choose a password and get ready to play on our community private server.</p>

                <div class="bwps-register-panel">
                    <div class="bwps-field">
                        <label for="userID">Bin Weevil Name</label>
                        <input type="text" name="userID" id="userID" autocomplete="username" maxlength="20" required>
                    </div>

                    <div class="bwps-field">
                        <label for="password">Password</label>
                        <input type="password" name="password" id="password" autocomplete="new-password" required>
                    </div>

                    <input type="hidden" name="recaptcha_response" id="recaptchaResponse">

                    <div class="bwps-submit-row">
                        <button type="button" class="bwps-yellow-btn" id="registerButton"><i class="fa fa-user-plus" aria-hidden="true"></i> Create Account</button>
                        <a class="bwps-login-link" href="/login/">Already have an account?</a>
                    </div>
                </div>
            </section>
        </main>

        <nav class="bwps-footer-nav" aria-label="Footer navigation">
            <a href="/privacy/">Privacy</a>
            <a href="https://github.com/n4thyan/Binweevils-Private-Server" target="_blank" rel="noopener">GitHub</a>
            <img src="/assets/images/weevil.png" alt="">
            <a href="/credits/">Credits</a>
            <a href="/848fjogfndsl/">Admin</a>
        </nav>

        <footer class="bwps-footer-copy">
            <p>A community Bin Weevils private server with classic gameplay, Ruffle support, relaxed chat, XP banking, prestige progression and more coming soon.</p>
            <p>Based on the original KnowYourKnot source. Full credit to the original private-server authors and original Bin Weevils creators.</p>
        </footer>
    </div>

    <script>
        (function () {
            const button = document.getElementById('registerButton');
            const userID = document.getElementById('userID');
            const password = document.getElementById('password');

            function showError(message) {
                Swal.fire('Error', message, 'error');
            }

            function createAccount() {
                const username = userID.value.trim();
                const pass = password.value;

                if (!username || !pass) {
                    showError('Please fill out all fields.');
                    return;
                }

                button.disabled = true;
                button.textContent = 'Creating...';

                const xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    if (this.readyState !== 4) return;

                    button.disabled = false;
                    button.innerHTML = '<i class="fa fa-user-plus" aria-hidden="true"></i> Create Account';

                    if (this.status !== 200) {
                        showError('The register server did not respond. Please try again.');
                        return;
                    }

                    if (this.responseText.includes('responseCode=2')) {
                        showError('There was a problem creating your account. Please check your details and try again.');
                    } else if (this.responseText.includes('responseCode=3')) {
                        showError('That Bin Weevil name is reserved or already taken.');
                    } else if (this.responseText.includes('responseCode=999')) {
                        Swal.fire('Information', 'An error has occurred.', 'info');
                    } else if (this.responseText.includes('Please download the latest build')) {
                        window.location.replace('/game.php');
                    } else {
                        Swal.fire('Information', this.responseText, 'info');
                    }
                };

                xhttp.open('POST', 'create-new-weevil.php');
                xhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhttp.send('userID=' + encodeURIComponent(username) + '&password=' + encodeURIComponent(pass) + '&recap=1');
            }

            button.addEventListener('click', createAccount);
            password.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') createAccount();
            });
        })();
    </script>
</body>
</html>
