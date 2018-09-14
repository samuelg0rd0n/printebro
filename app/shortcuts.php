<?php

// debug functions

use Tracy\Debugger;


function bd($val)
{
	foreach (func_get_args() as $var) {
		Debugger::barDump($var);
	}
	return $val;
}
function d($val)
{
	foreach (func_get_args() as $var) {
		Debugger::dump($var);
	}
	return $val;
}
function dd()
{
	call_user_func_array('d', func_get_args());
	die();
}
function ed($var)
{
	echo($var);
	die();
}
function f($var)
{
	Debugger::fireLog($var);
	return $var;
}
function pr($var)
{
	foreach (func_get_args() as $var) {
		print_r($var);
	}
	return $var;
}
function prd($var)
{
	call_user_func_array('pr', func_get_args());
	die();
}

class ms_time {
	protected static $ms_time = 0;

	/**
	 * Měří rozdíl časů mezi jednotlivými voláními fce ms. Do souboru "microtime.txt" (umístěný u index.php) zapisuje jednotlivé časy.
	 * @param string $s Komentář k danému odečtu času.
	 */
	public static function ms($s = '') {
		if(!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
			return;
		}

		if (empty(self::$ms_time)) {
			//file_put_contents('microtime.txt', '');
			self::$ms_time = microtime(TRUE);
			return;
		}

		$microtimeStep = microtime(TRUE);
		file_put_contents('microtime.txt', (($microtimeStep - self::$ms_time) * 1000) .'ms: '. $s ."\n", FILE_APPEND);
		self::$ms_time = $microtimeStep;
	}
}
