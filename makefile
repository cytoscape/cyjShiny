basic: roxy install

all:  roxy install build check

roxy:
	R -e "devtools::document()"
vig:
	R -e "devtools::build_vignettes()"

build:
	(R CMD build --no-build-vignettes .)

install:
	(R CMD INSTALL --no-test-load .)

check:
	(cd ..; R CMD check --no-vignettes --no-manual `ls -t cyjShiny_* | head -1`)

biocCheck:
	(cd ..; R CMD BiocCheck `ls -t cyjShiny_* | head -1`)

test:
	(for x in inst/unitTests/test_*.R; do echo ============== $$x; R -f $$x; done)
