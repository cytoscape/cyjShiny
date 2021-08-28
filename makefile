basic: roxy install

all: roxy install build check

build_check: build check

roxy:
	R -e "devtools::document()"
	
vig:
	R -e "devtools::build_vignettes()"

build:
	(R CMD build --no-build-vignettes .)

buildWithVignettes:
	(R CMD build .)

install_deps: 
        R -e 'paste0("Installed: ", paste(rownames(installed.packages()), collapse="|")); devtools::install_deps(dependencies = TRUE)'

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
