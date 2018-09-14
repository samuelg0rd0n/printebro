# https://stackoverflow.com/a/14061796/4837606
# ulož si všechny přepínače za "--" do proměnné
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(RUN_ARGS):;@:)

ROOT_DIR=$(shell pwd)
WWW_DIR=$(ROOT_DIR)/www
#PRIVATE_DIR=$(ROOT_DIR)/private
#CONFIG_DIR=$(PRIVATE_DIR)/app/config
#CSS_DIR=$(WWW_DIR)/css
#LESS_DIR=$(WWW_DIR)/less
#TESTS_DIR=$(PRIVATE_DIR)/tests
#VENDOR_DIR=$(PRIVATE_DIR)/vendor
#VENDOR_BIN_DIR=$(VENDOR_DIR)/bin
#TESTER=$(VENDOR_BIN_DIR)/tester
APP=php $(WWW_DIR)/index.php $(shell [[ "$(NETTE_ENV)" != "" ]] && echo "env:$(NETTE_ENV)")

CODECEPT=./private/vendor/bin/codecept
SHELL=/bin/bash

# vypíše seznam možných příkazů
list:
	@echo -e "\033[0;33mMožnosti nastavení environment:\033[0m"
	@echo -e "  \033[0;37m$$ make <command> NETTE_ENV=prod"
	@echo -e "  \033[0;37m$$ export NETTE_ENV=prod; make <command>"
	@echo -e ""
	@echo -e "\033[0;33mDostupné úkoly:\033[0m"
	@echo -e "  \033[0;32mbackground-queue-reload\033[0m   Reload consumerů v adt/background-queue"
	@echo -e "  \033[0;32mcheckout\033[0m           Provede potřebné věci po přepnutí do jiné git branche"
	@echo -e "  \033[0;32mclean | rmcache\033[0m    Vyčistí temp adresář a vyprázdní redis"
	@echo -e "  \033[0;32mconfig\033[0m             Zkontroluje, že existují všechny potřebné config soubory zkopírované z jejich '*.example' kopií"
	@echo -e "  \033[0;32mdependencies\033[0m       Provede stáhnutí závislostí: composer, bower, js, less, translate"
	@echo -e "  \033[0;32mdeploy | dep\033[0m       Deployne projekt pro kontrolu. Konkrétní stage lze specifikovat pomocí:"
	@echo -e "                     \033[0;37m$$ make deploy -- <stage>"
	@echo -e "  \033[0;32mdeploy-publish | dep-pub\033[0m  Publishne deploynutý projekt. Konkrétní stage lze specifikovat pomocí:"
	@echo -e "                     \033[0;37m$$ make deploy-publish -- <stage>"
	@echo -e "  \033[0;32minit\033[0m               Provede install a build"
	@echo -e "  \033[0;32minstall\033[0m            Nainstaluje všechny potřebné nástroje"
	@echo -e "  \033[0;32mmigrations\033[0m         Spustí Doctrine migrace. Dry run lze specifikovat pomocí:"
	@echo -e "                     \033[0;37m$$ make migrations -- -d"
	@echo -e "  \033[0;32mmigrations-status\033[0m  Zobrazí status Doctrine migrací."
	@echo -e "  \033[0;32mtranslate\033[0m          Stáhne překlady. Konkrétní jazyk lze specifikovat pomocí:"
	@echo -e "                     \033[0;37m$$ make translate -- -l <lang>"
	@echo -e "  \033[0;32mwatch\033[0m              Začne sledovat změny v *.js a *.less souborech"
	@echo -e ""
	@echo -e "\033[0;33mTesty:\033[0m"
	@echo -e "  \033[0;32mfunctional\033[0m         Spustí funkční testy"
	@echo -e "  \033[0;32mphantomJs\033[0m          Spustí phantomjs a akceptační testy"
	@echo -e "  \033[0;32mphpBrowser\033[0m         Spustí PhpBrowser testy"
	@echo -e "  \033[0;32mrecreateDatabase\033[0m   Smaže a vytvoří novou testovací databázi, spustí nové migrace,"
	@echo -e "                     stáhne překlady a smaže cache."
	@echo -e "  \033[0;32mselenium\033[0m           Spustí selenium testy"
	@echo -e "  \033[0;32mstartSelenium\033[0m      Nastartuje selenium server"
	@echo -e "  \033[0;32mstartSeleniumLinux\033[0m Nastartuje selenium server pro Linux"
	@echo -e "  \033[0;32mtest\033[0m               Spustí všechny testy"
	@echo -e "  \033[0;32munit\033[0m               Spustí unit testy"


################################################################################
# TARGETS

background-queue-reload:
	$(APP) adt:backgroundQueue:consumerReload

_bower:
	bower install

checkout: config build migrations clean

clean:
	$(eval CREDENTIALS = $(shell $(APP) app:config-parameters -- "-h %redis.host% -n %redis.database.value%"))
	@if ! [[ "$(CREDENTIALS)" =~ "-h %redis.host% -n %redis.database.value%"$$ ]]; then \
		redis-cli $(CREDENTIALS) flushdb; \
	fi

	rm -rf temp/*

_composer:
	composer install

config:
	@if [ ! -f 'app/config/config.local.neon' ]; then \
		echo 'Vytvor app/config/config.local.neon'; \
		exit 1; \
	fi;

dependencies: _composer _bower _gulp translate

deploy:
	dep deploy $(RUN_ARGS) -vvv

deploy-publish:
	dep deploy:publish $(RUN_ARGS) -vvv

_gulp:
	gulp build

init: config install dependencies rdb

install: _npm

migrations:
	$(APP) migrations:migrate --no-interaction $(RUN_ARGS)

migrations-status:
	$(APP) migrations:status $(RUN_ARGS)

_npm:
	npm install

recreateDatabase:
	@# Při změně hledej S_recreateDatabase

	$(eval CREDENTIALS = $(shell $(APP) app:config-parameters -- "-u %database.user% --password=%database.password% %database.dbname%"))

	@if ! [[ "$(CREDENTIALS)" =~ _loc$$ ]]; then \
		echo 'Target recreateDatabase lze spouštět pouze na *_loc databáze,'; \
		exit 1; \
	fi

	mysql $(CREDENTIALS) < $(ROOT_DIR)/migrations/recreate.sql
	mysql $(CREDENTIALS) < $(ROOT_DIR)/migrations/dump.sql

	$(APP) migrations:status
	$(APP) migrations:migrate --allow-no-migration -n
	make clean

translate:
	$(APP) adt:onesky -d $(RUN_ARGS)

watch:
	gulp watch


################################################################################
# TESTY

acceptation: phpBrowser phantomJs selenium

functional:
	$(CODECEPT) build
	$(CODECEPT) run functional

phantomJs:
	if [ "`pgrep phantomjs`" = "" ]; then\
		phantomjs --webdriver=4445 > /dev/null &\
		sleep 5;\
	fi

	$(CODECEPT) build
	$(CODECEPT) run phantomJs

phpBrowser:
	$(CODECEPT) build
	$(CODECEPT) run phpBrowser

recreateDatabase-test:
	@# Při změně hledej S_recreateDatabase

	$(eval CREDENTIALS = $(shell $(APP) env:test app:config-parameters -- "-u %database.user% --password=%database.password% %database.dbname%"))

	@if ! [[ $(CREDENTIALS) =~ _test$$ ]]; then \
		echo 'Target recreateDatabase-test lze spouštět pouze na *_test databáze,'; \
		exit 1; \
	fi

	mysql $(CREDENTIALS) < $(ROOT_DIR)/migrations/recreate.sql
	mysql $(CREDENTIALS) < $(ROOT_DIR)/migrations/dump.sql

	$(APP) env:test migrations:status
	$(APP) env:test migrations:migrate --allow-no-migration -n
	make clean

selenium:
	$(CODECEPT) build
	$(CODECEPT) run selenium

startSelenium:
	java -Dwebdriver.gecko.driver=tests/selenium-server/geckodriver -jar tests/selenium-server/selenium-server-standalone-3.4.0.jar

startSeleniumLinux:
	java -Dwebdriver.gecko.driver=tests/selenium-server/geckodriver_linux -jar tests/selenium-server/selenium-server-standalone-3.4.0.jar

test: unit functional acceptation

unit:
	$(CODECEPT) build
	$(CODECEPT) run unit --coverage --coverage-html --coverage-xml


################################################################################
# ALIASY

dep: deploy
dep-pub: deploy-publish
rdb: recreateDatabase
rdbtest: recreateDatabase-test
rdb-test: recreateDatabase-test
rmcache: clean
