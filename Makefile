# Makefile for Robot Framework Testing Project

.PHONY: help setup install test test-crud test-validation test-testdata test-connection test-all clean docker-up docker-down docker-test report clean-reports lint format

help:
	@echo "Robot Framework Testing Project - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Full setup with venv and dependencies"
	@echo "  make install            - Install dependencies only"
	@echo ""
	@echo "Testing:"
	@echo "  make test               - Run all tests"
	@echo "  make test-crud          - Run CRUD operations tests"
	@echo "  make test-validation    - Run database validation tests"
	@echo "  make test-testdata      - Run test data management tests"
	@echo "  make test-connection    - Run connection management tests"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-up          - Start Docker services"
	@echo "  make docker-down        - Stop Docker services"
	@echo "  make docker-test        - Run tests in Docker"
	@echo ""
	@echo "Reporting:"
	@echo "  make report             - Generate Allure report"
	@echo "  make clean-reports      - Clean all report files"
	@echo ""
	@echo "Code Quality:"
	@echo "  make lint               - Run pylint"
	@echo "  make format             - Format code with black"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean              - Remove all generated files"

setup:
	python -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements.txt
	. venv/bin/activate && python -m playwright install

install:
	pip install -r requirements.txt
	python -m playwright install

test:
	robot -d ./reports tests/database/

test-crud:
	robot -d ./reports tests/database/01_CRUD_Operations.robot

test-validation:
	robot -d ./reports tests/database/02_Database_Validation.robot

test-testdata:
	robot -d ./reports tests/database/03_Test_Data_Management.robot

test-connection:
	robot -d ./reports tests/database/04_Connection_Management.robot

test-all: test-crud test-validation test-testdata test-connection

docker-up:
	docker-compose -f docker/docker-compose.yml up -d

docker-down:
	docker-compose -f docker/docker-compose.yml down

docker-test:
	docker-compose -f docker/docker-compose.yml up -d
	docker-compose -f docker/docker-compose.yml exec -T robot-runner robot tests/database/
	docker-compose -f docker/docker-compose.yml down

report:
	allure generate ./reports --clean -o ./allure-results
	allure open ./allure-results/

clean-reports:
	rm -rf ./reports/*
	rm -rf ./allure-results/*

lint:
	pylint keywords/**/*.robot || true

format:
	black . --exclude=venv

clean:
	rm -rf venv
	rm -rf reports
	rm -rf allure-results
	rm -rf __pycache__
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
