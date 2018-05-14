FROM oydeu/oyd-shiny:latest
MAINTAINER "Christoph Fabianek" christoph@ownyourdata.eu

RUN apt-get -y update \
	&& apt-get install -y --no-install-recommends \
		libv8-3.14-dev \
		libsodium-dev \
		build-essential \
		gcc \
		r-cran-raster \
		libgeos-dev \
		libgdal-dev \
		gfortran \
		libudunits2-dev \
  && rm -rf /var/lib/apt/lists/*


RUN cd /srv/shiny-server \
        && rm -rf * \
        && git clone https://github.com/OwnYourData/app-answers.git \ 
        && mv app-answers/* . \
        && rm -r app-answers \
        && R -e "source('init.R')" \
        && sed -i '2s/.*/printf \"OYD_SECRET=$OYD_SECRET\\n\" > \/srv\/shiny-server\/.Renviron/' /usr/bin/shiny-server.sh

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]
