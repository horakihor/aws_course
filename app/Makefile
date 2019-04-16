.PHONY: build test

setup:
	$(call blue, "Prepare debug environment...")
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt

run:
	$(call blue, "Run application in debug mode localy...")
	.venv/bin/python manage.py run

test:
	$(call blue, "Run unit tests localy...")
	.venv/bin/python manage.py test

init:
	$(call blue, "Run unit tests localy...")
	.venv/bin/python manage.py db init

migrate:
	$(call blue, "Run unit tests localy...")
	.venv/bin/python manage.py db migrate

upgrade:
	$(call blue, "Run unit tests localy...")
	.venv/bin/python manage.py db upgrade

define blue
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
