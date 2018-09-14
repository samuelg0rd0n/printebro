<?php

// aktuální branch dle GITu
$branch = exec("git rev-parse --abbrev-ref HEAD");

$defaults = [
	'local' => '.',
	'test' => FALSE,
	'ignore' => '
		/app/config/config.local.neon
		/app/bootstrap-local.php
		/log/*
		/sessions/*
		/temp/*
		
		/www/data/*
		/data/*
		/deployment.*
		.git*
		/tests
		
		/www/src/*
		
		/node_modules
		/package*
		/gulpfile.js
		/yarn-error.log
	',
	'allowdelete' => TRUE,
	'preprocess' => FALSE,
];
/*
 */

$branchToApp = [
	'master' => [
		'printebro.cz'
	],
];

$branch = 'master';

$apps = [];
$apps['printebro.cz'] = $defaults;
$apps['printebro.cz']['remote'] = 'ftp://w200036:fvbsKWHc@200036.w36.wedos.net';

return array_intersect_key($apps, array_flip($branchToApp[$branch])) + [
	'tempdir' => __DIR__ . '/temp',
	'colors' => TRUE,
];
