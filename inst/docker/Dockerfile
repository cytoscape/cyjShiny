FROM pshannon/trenashinybase
USER root
COPY Rprofile.site /usr/local/lib/R/etc/
USER trena
RUN mkdir -p /home/trena/app
WORKDIR /home/trena/app
COPY app/* /home/trena/app/
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/home/trena/app', port=3838, host='0.0.0.0')"]
