<?php

$developers = [
	'127.0.0.1',
];

define('TMP_DIR',  __DIR__ . '/../temp');
define('LOG_DIR',  __DIR__ . '/../log');

include __DIR__ . '/../vendor/adt/after-deploy/src/AfterDeploy.php';
(new ADT\AfterDeploy\AfterDeploy())
	->runBase([
	    'key' => 'afterDeploy159',
		'tempDir' => TMP_DIR, // required
		'logDir' => LOG_DIR, // required
	]
);

require __DIR__ . '/../vendor/autoload.php';
include __DIR__ . '/shortcuts.php';

$configurator = new ADT\Configurator;

// Uncomment line below to create hash for new developer.
// ADT\Configurator::newDeveloper('JohnDoe');

$configurator
	->setIps($developers)
	->addDeveloper('MichalLohnisky@$2y$10$7c27T0LSdQ7gu5knRgWq7OnOvybyHoTUuLrxjK0FdtFrymGvSmKCi', TRUE)
	->addDeveloper('TomasKudelka@$2y$10$O6XsqSDw9kDUAE.evIc.pe9aM.mCiDhTO5Ehd5WpWDQXAzZWKfTfG', TRUE)
	->addDeveloper('SamoLisy@$2y$10$EWnf1MYUHDuEz87EwC38peYx3VVubXck0pZYFnt0z9cpGw4o6wps2', TRUE)
	->addDeveloper('AdamStepanek@$2y$10$QctS/0BN8FHstVdzVhXbQ.AyH4tvIfWx6CY74O9ZNI3GcQjB9TMVu', TRUE)
	->setDebugMode();

$configurator->enableDebugger(LOG_DIR);

$configurator->setTempDirectory(TMP_DIR);

$configurator->createRobotLoader()
	->addDirectory(__DIR__)
	->addDirectory(__DIR__ . '/../lib')
	->register();

$configurator->addConfig(__DIR__ . '/config/config.neon');

// Podle tohoto se později rozhoduje mezi verzemi. Je třeba rozlišit master, beta, dev.
$domains = [
	'printebro.cz' => 'master',
	'www.printebro.cz' => 'master',
];

$configurator
	->setDomains($domains)
	->setEnvironment()
	->addEnvironmentConfig(__DIR__ . '/config');

\Kdyby\DoctrineForms\ToManyContainer::register();

$container = $configurator->createContainer();

return $container;
