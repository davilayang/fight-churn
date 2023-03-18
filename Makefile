.PHONY:

build:
	python3 -m build

clean:
	rm -rf dist
	rm -rf build
	rm -rf fightchurn.egg-info

test:
	pytest tests --verbose

test_verbose:
	pytest tests --verbose --capture=no

publish:
	python3 -m twine upload dist/*

compose-up:
	docker compose up

compose-jupyter:
	docker compose exec -it python-env \
		/app/venv/bin/jupyter lab \
		--ip 0.0.0.0 --allow-root --port 8888 --no-browser
