FROM rocker/binder:3.6.3

ARG NB_USER
ARG NB_UID

USER root
COPY . ${HOME}
RUN pwd
RUN ls -la
RUN ls -la .binder 

RUN R -e 'devtools::install_github("cytoscape/cyjShiny", dependencies=TRUE, upgrade=FALSE)'

RUN chown -R ${NB_USER} ${HOME}

USER ${NB_USER}
