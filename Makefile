.PHONY: lint test dist upload docs

BIN=.venv/bin
DIRS=src/ tests/unit/ docs/ scripts/ # tests/performance/
BROWSER=firefox
PYTEST=pytest --doctest-modules --doctest-glob="*.rst" --doctest-ignore-import-errors

all: lint test

black:
	-$(BIN)/black $(DIRS)

blackdoc:
	-$(BIN)/blackdoc $(DIRS)

pylint:
	-$(BIN)/pylint src/

mypy:
	-$(BIN)/mypy $(DIRS)

doc8:
	-doc8 README.rst

pydocstyle:
	$(BIN)/pydocstyle src/

lint: black blackdoc pylint mypy pydocstyle

test:
	$(BIN)/python3 -m $(PYTEST) src/ tests/ docs/ README.rst

test-performance:
	$(BIN)/python3 -m $(PYTEST) --performance tests/performance/

coverage:
	$(BIN)/coverage erase
	$(BIN)/coverage run --branch --source=src -m $(PYTEST) tests/
	$(BIN)/coverage run --append --branch --source=src -m $(PYTEST) --debug-mode tests/
	$(BIN)/coverage report
	$(BIN)/coverage html
	$(BROWSER) htmlcov/index.html

profile:
	$(BIN)/python3 -O -m scripts.profile

docs:
	cd docs; make html

badges: coverage
	$(BIN)/python docs/make_badges.py

tox:
	$(BIN)/tox

dist: clean test coverage badges
	$(BIN)/python3 -m build
	$(BIN)/twine check dist/*

upload: dist
	$(BIN)/twine check dist/*
	$(BIN)/twine upload dist/*

install:
	$(BIN)/pip3 install --force-reinstall -e .

uninstall:
	$(BIN)/pip3 uninstall super_collator

clean:
	-rm -rf dist build *.egg-info
	-rm *~ .*~ pylintgraph.dot
	-find . -name __pycache__ -type d -exec rm -r "{}" \;
