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

boot:
	@echo "Starting application..."
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt
	.venv/bin/python manage.py run

define blue
  @tput setaf 6
  @echo $1
  @tput sgr0
endef
