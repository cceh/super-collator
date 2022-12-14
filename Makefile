.PHONY: lint test dist upload docs

DIRS=src/ tests/unit/ docs/ scripts/ # tests/performance/
BROWSER=firefox
PYTEST=pytest --doctest-modules --doctest-glob="*.rst" --doctest-ignore-import-errors

all: lint test

black:
	-black $(DIRS)

blackdoc:
	-blackdoc $(DIRS)

pylint:
	-pylint src/

mypy:
	-mypy $(DIRS)

doc8:
	-doc8 README.rst

pydocstyle:
	pydocstyle src/

lint: black blackdoc pylint mypy pydocstyle

test:
	python3 -m $(PYTEST) src/ tests/ docs/ README.rst

test-performance:
	python3 -m $(PYTEST) --performance tests/performance/

coverage:
	coverage erase
	coverage run --branch --source=src -m $(PYTEST) tests/
	coverage run --append --branch --source=src -m $(PYTEST) --debug-mode tests/
	coverage report
	coverage html
	$(BROWSER) htmlcov/index.html

profile:
	python3 -O -m scripts.profile

docs:
	cd docs; make html

badges: coverage
	python docs/make_badges.py

tox:
	tox

dist: clean test coverage badges
	python3 -m build
	twine check dist/*

upload: dist
	twine check dist/*
	twine upload dist/*

install:
	pip3 install --force-reinstall -e .

uninstall:
	pip3 uninstall super_collator

clean:
	-rm -rf dist build *.egg-info
	-rm *~ .*~ pylintgraph.dot
	-find . -name __pycache__ -type d -exec rm -r "{}" \;
