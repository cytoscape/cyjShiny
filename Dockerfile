FROM cannin/r-shiny-server

COPY inst/scripts/installPackage.R installPackage.R
RUN R -e 'source("installPackage.R")'

RUN cp -R /usr/local/lib/R/site-library/kidneyMetabProject/shinyApp/ /srv/shiny-server/kidneyMetabProject/

#CMD ["shiny-server"]
