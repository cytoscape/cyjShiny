FROM cannin/r-shiny-server

COPY inst/scripts/installPackage.R installPackage.R
RUN R -e 'source("installPackage.R")'

RUN cp -R /usr/local/lib/R/site-library/rcytoscapejs/examples/shiny/ /srv/shiny-server/rcytoscapejs/

#CMD ["shiny-server"]
