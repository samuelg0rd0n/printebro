ADT - Nette Web Project
=======================

This is a simple, skeleton application using the [Nette](https://nette.org). This is meant to
be used as a starting point for your new projects.

[Nette](https://nette.org) is a popular tool for PHP web development.
It is designed to be the most usable and friendliest as possible. It focuses
on security and performance and is definitely one of the safest PHP frameworks.


Requirements
------------

PHP 5.6 or higher.


Installation
------------

The best way to install Web Project is using Composer. If you don't have Composer yet,
download it following [the instructions](https://doc.nette.org/composer). Then use command:

    cd path/to/install
	git archive --format=tar --remote=ssh://git@git.appsdevteam.com:2222/adt/sandbox_web.git HEAD | tar xf 
	make init


Make directories `temp/` and `log/` writable.


Gulp
=================

Gulp v projekte zabezpecuje spajanie, buildovanie, minifikaciu a sourcemapy
`.js` a `.less` suborov. Zoznam spajanych `.js` suborov je definovany v subore
`gulpfile.js`. Zoznam spajanych css kniznic a `.less` suborov je uvedeny
v hlavnom less subore `www/src/less/app.less`.

Pred zacatim upravovania `.js` a `.less` suborov si treba spustit watcher:
```
gulp watch
```

Po pridani nove js kniznice do `pulpfile.js` je potreba rucne spustit:
```
gulp js
```
