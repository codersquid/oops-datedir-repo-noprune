SERVICE_PACKAGE = oops_datedir_repo
ENV = $(CURDIR)/env
PIP = $(ENV)/bin/pip
TMPDIR = $(CURDIR)/tmp
TESTS ?= $(SERVICE_PACKAGE).tests.test_suite

DEPENDENCY_REPO ?= https://git.launchpad.net/~launchpad/python-oops-datedir-repo/+git/dependencies
DEPENDENCY_DIR ?= $(TMPDIR)/dependencies


$(ENV)/.created: | $(DEPENDENCY_DIR)
	VIRTUALENV_SETUPTOOLS=1 virtualenv $(ENV) --python=python2
	ln -sfn env/bin bin
	$(PIP) install -f file://$(DEPENDENCY_DIR) --no-index pip==20.0.2
	$(PIP) install -f file://$(DEPENDENCY_DIR) --no-index \
		setuptools==44.0.0 wheel==0.34.2
	$(PIP) install -f file://$(DEPENDENCY_DIR) --no-index pbr==5.6.0
	$(PIP) install -f file://$(DEPENDENCY_DIR) --no-index \
		-r requirements.txt -e .
	@touch $@

$(DEPENDENCY_DIR):
	git clone $(DEPENDENCY_REPO) $(DEPENDENCY_DIR)

update-dependencies: $(DEPENDENCY_DIR)
	cd $(DEPENDENCY_DIR) && git pull $(DEPENDENCY_REPO)

bootstrap build: $(ENV)/.created

check:
	tox

clean:
	rm -rf $(ENV) .tox
	rm -rf $(TMPDIR)
	rm -f bin
	find -name '__pycache__' -print0 | xargs -0 rm -rf
	find -name '*.~*' -delete

.PHONY: update-dependencies check clean
