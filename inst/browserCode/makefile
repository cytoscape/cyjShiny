build: webpack  package

webpack:
	npm update
	webpack
	cp dist/bundle.js ../htmlwidgets/lib/

package:
	(cd ../..; R CMD install .)
clean:
	- rm -rf dist/
	- rm -rf node_modules

install:
	npm install
