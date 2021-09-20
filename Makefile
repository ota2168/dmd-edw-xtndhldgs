# MM Artifactory URL for pip installs
artifactory = https://artifactory.awsmgmt.massmutual.com/artifactory/api/pypi/python-virtual/simple

# Path to local Python Virtual Environment
python_venv = $(shell pwd)/venv

# Path to pip in Virtual Environment
pip = $(python_venv)/bin/pip

# Path to pre-commit in Virtual Environment
pre-commit = $(python_venv)/bin/pre-commit

# Package Name - keep in sync with name of package
package_name = edwxtndhldgs_etl


default: help

## help					Show available commands
.PHONY: help
help:
	@echo "The following make commands are available:"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/-/'


## venv.create / venv.delete		Create the local Virtual Environment (or delete it)
.PHONY: venv.create
venv.create:
	@echo "Creating Python3.7 Virtual Environment"
	@python3.7 -m venv $(python_venv)

.PHONY: venv.delete
venv.delete:
	@echo "Delete Python3.7 Virtual Environment"
	@python3.7 -m venv $(python_venv)


## package.install / package.uninstall 	Install the package in the local Virtual Environment (or uninstall it)
.PHONY: package.install
package.install:
	@echo "Installing package from local repo"
	@$(pip) install . --index-url=$(artifactory)

.PHONY: package.uninstall
package.uninstall:
	@echo "Uninstalling $(package_name)"
	@$(pip) uninstall $(package_name)


## devtools.install / devtools.uninstall	Install development dependencies in Virtual Environment (or uninstall them)
.PHONY: devtools.install
devtools.install:
	@echo "Installing development dependencies in Virtual Environment"
	@$(pip) install pytest-runner --index-url=$(artifactory)
	@$(pip) install -r requirements-dev.txt --index-url=$(artifactory)

.PHONY: devtools.uninstall
devtools.uninstall:
	@echo "Uninstalling development dependencies from Virtual Environment"
	@$(pip) uninstall -r requirements-dev.txt --index-url=$(artifactory)


## hooks.install / hooks.uninstall	Install git hooks in local repo (or uninstall them)
.PHONY: hooks.install
hooks.install:
	@echo "Installing git hooks in local repo"
	@$(pre-commit) install
	@$(pre-commit) install --hook-type=pre-push

.PHONY: hooks.uninstall
hooks.uninstall:
	@echo "Uninstalling git hooks from local repo"
	@$(pre-commit) uninstall
	@$(pre-commit) uninstall --hook-type=pre-push


## dev.setup / dev.unsetup 		Setup local environment for development (or undo setup)
.PHONY: dev.setup
dev.setup: venv.create package.install  devtools.install hooks.install

.PHONY: dev.unsetup
dev.unsetup: hooks.uninstall venv.delete


## version_num.update_prerelease		Update the version number for a pre-release build
.PHONY: version_num.update_prerelease
version_num.update_prerelease:
	@echo "Updating VERSION as Pre-Release VERSION"
	@echo "Ex: The first pre-release build of 1.5.2 is 1.5.2-alpha1"
	@echo "Current VERSION: $$(cat VERSION)"
	@read -r -p "New Pre-Release VERSION? (Major.Minor.Patch-alphaBuild): " new_version; \
	echo $${new_version} > VERSION;
	@echo "Updated VERSION: $(cat VERSION)";

## version_num.update			Update the version number, create a git tag, update the changelog
.PHONY: version_num.update
version_num.update:
	@echo "Updating VERSION as a Release VERSION"
	@echo "Current VERSION: $$(cat VERSION)"
	@read -r -p "New Release VERSION? (Major.Minor.Patch)" new_version; \
	cat $${new_version} > VERSION; \
	@git tag -a v$${new_version} -m 'v$$(new_version)';
	@$(MAKE) changelog.update


## changelog.update			Update the changelog
.PHONY: changelog.update
changelog.update:
	@echo "Updating CHANGELOG.md"
	@$(python_venv)/bin/gitchangelog > CHANGELOG.md
	@sed -i.bak '$$d' CHANGELOG.md
	@sed -i.bak '$$d' CHANGELOG.md
	@rm 'CHANGELOG.md.bak'
# The changelog that is generated always has three blank lines at the end
# so we remove two of those with sed and then remove the sed backup


## hooks.run				Run git hooks on staged files in repo
.PHONY: hooks.run
hooks.run:
	@echo "Running git hooks on staged files"
	@$(pre-commit) run

## hooks.run_all_files			Run git hooks on all files in repo
.PHONY: hooks.run_all_files
hooks.run_all_files:
	@echo "Running git hooks on staged files"
	@$(pre-commit) run --all-files


## test.lint				Run Style and Lint Tests in Tox Virtual Environment
.PHONY: test.lint
test.lint:
	@echo "Running Style and Lint Tests in local Virtual Environment"
	@$(python_venv)/bin/python -m tox --parallel=auto -e pre-commit-lint,mypy,black,flake8,isort

## test.unit				Run Unit Tests in Tox Virtual Environment
.PHONY: test.unit
test.unit:
	@echo "Running Unit Tests in Tox Virtual Environment"
	@$(python_venv)/bin/python -m tox -e clean,build
	@$(python_venv)/bin/python -m tox -e py37


## test.ci				Run Full CI Tests (Style, Lint, Unit) in local Docker Container
.PHONY: test.ci
test.ci:
	@echo "Running CI Tests (Style, Lint, PyTest) in local Docker Container"
	@source ./ci/local-docker-tests.sh; \
	_pull_testing_image; \
	run_citests;

## project				Create fresh repo
.ONESHELL:
.PHONY: project
project:
	@read -r -p "enter version of Python  (Ex: 3.7): " python_version; \
	python$${python_version} -m venv venv; \
	source venv/bin/activate; \
	python project_initial_setup.py; \
	$(MAKE) dev.setup
