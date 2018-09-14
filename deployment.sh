#!/bin/sh

server=${1:-"none"}

#if [[ $server = "none" ]]; then
#	echo "Specify server: 'okk', 'oksk'"
#	exit
#fi

params="";
dryRun=0;
runBefore=1;
if [[ $1 != "exec" ]]; then
	params="${params} -t";
	dryRun=1;
fi
if [[ $2 == "quick" ]]; then
	runBefore=0;
fi

branch=`git rev-parse --abbrev-ref HEAD`

if [ $dryRun -eq 0 ] && [ $runBefore -eq 1 ]; then
	./lessmake.sh
	./translator-pull.sh
fi

php vendor/dg/ftp-deployment/deployment deployment.ini.php ${params}

exit


# migruj jen pokud existují nové migrace
if [ "`php www/index.php config:${server} migrations:status | grep 'New Migrations:'|tr -s ' '|cut -d ' ' -f 5`" != "0" ]; then
	php www/index.php config:${server} migrations:status

	if [ $dryRun -eq 0 ]; then
		php www/index.php config:${server} migrations:migrate
	fi

	if [ $? -ne 0 ] ; then
		echo 'EXIT php www/index.php config:${server} migrations:migrate'
		exit 7
	fi
fi
