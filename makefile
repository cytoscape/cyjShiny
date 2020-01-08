basic: npm docs install

all:  npm docs install build check

docs:
	R -e "devtools::document()"
vig:
	R -e "devtools::build_vignettes()"

npm:
	(cd browserCode; make)

build:
	(cd ..; R CMD build --no-build-vignettes cyjShiny)

install:
	(cd ..; R CMD INSTALL --no-test-load cyjShiny)

check:
	(cd ..; R CMD check --no-vignettes --no-manual `ls -t cyjShiny_* | head -1`)

biocCheck:
	(cd ..; R CMD BiocCheck `ls -t cyjShiny_* | head -1`)

test:
	(for x in inst/unitTests/test_*.R; do echo ============== $$x; R -f $$x; done)
