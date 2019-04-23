.PHONY: build test

setup:
	@echo "Prepare debug environment..."
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt

run:
	@echo "Run application in debug mode localy..."
	.venv/bin/python manage.py run

test:
	@echo "Run unit tests localy..."
	.venv/bin/python manage.py test

boot:
	@echo "Starting application..."
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt
	.venv/bin/python manage.py run
