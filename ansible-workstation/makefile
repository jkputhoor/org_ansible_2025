# Makefile

# Variables
VENV_NAME := .venv
PYTHON := python3
PIP := $(VENV_NAME)/bin/pip

#Default target
all: venv

venv:
	$(PYTHON) -m venv $(VENV_NAME)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

clean:
	rm -rf $(VENV_NAME)

.PHONY: all venv clean
