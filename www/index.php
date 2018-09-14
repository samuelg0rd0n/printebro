<?php

define("IS_CLI", php_sapi_name() === "cli");

$container = require __DIR__ . '/../app/bootstrap.php';

if (IS_CLI) {
	// https://github.com/Kdyby/Console/blob/master/docs/en/index.md#running-the-console
	$console = $container->getByType(\Symfony\Component\Console\Application::class);
	exit($console->run());

} else {
	$container->getByType(\Nette\Application\Application::class)
		->run();
}
