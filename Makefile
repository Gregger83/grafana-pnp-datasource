TAGVERSION=$(shell git describe --tag --exact-match 2>/dev/null | sed -e 's/^v//')

build:
	docker run \
		-t \
		--rm \
		-v $(shell pwd):/src \
		-w "/src" \
		-u $(shell id -u) \
		-e GRAFANA_API_KEY="$(GRAFANA_API_KEY)" \
		node:latest \
		bash -c "yarn install && yarn run build && npx @grafana/toolkit plugin:sign"

clean:
	rm -rf dist

releasebuild:
	git checkout -b release-$(TAGVERSION)
	make GRAFANA_API_KEY=$(GRAFANA_API_KEY) build
	git add -f dist
	git commit -m "Release build v$(TAGVERSION)"
	git log -1
	git checkout master

releasepush:
	git push --set-upstream origin release-$(TAGVERSION)
	git checkout master
	git push
	git push --tags
