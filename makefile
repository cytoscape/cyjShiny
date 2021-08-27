basic: roxy install

all:  roxy install build check

roxy:
	R -e "devtools::document()"
vig:
	R -e "devtools::build_vignettes()"

build:
	(R CMD build --no-build-vignettes .)

buildWithVignettes:
	(R CMD build .)

install:
	(R CMD INSTALL --no-test-load .)

check:
	R -e "devtools::check(cran=TRUE)"

biocCheck:
	(cd ..; R CMD BiocCheck `ls -t cyjShiny_* | head -1`)

cranCheck:
	R CMD check --as-cran `ls -t cyjShiny_* | head -1`

test:
	(for x in inst/unitTests/test_*.R; do echo ============== $$x; R -f $$x; done)

demo:
	R -f inst/demos/basicDemo/cyjShinyDemo.R
