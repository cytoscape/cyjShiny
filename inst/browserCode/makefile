build: webpack  package

webpack:
	npm update
	node_modules/webpack/bin/webpack.js
	mv dist/bundle.js ../htmlwidgets/lib/

package:
	(cd ../..; R CMD install .)
clean:
	- rm -rf dist/
	- rm -rf node_modules

install:
	npm install
