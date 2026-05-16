<?php
	function bw_env($name, $fallback) {
		$value = getenv($name);

		if ($value === false || $value === '') {
			return $fallback;
		}

		return $value;
	}

	define('DB_HOST', bw_env('DB_HOST', 'localhost'));
	define('DB_USER', bw_env('DB_USER', 'root'));
	define('DB_PASS', bw_env('DB_PASSWORD', ''));
	define('DB_NAME', bw_env('DB_NAME', 'bwps'));
?>