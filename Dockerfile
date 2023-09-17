FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y apt-utils
RUN apt-get install -y --no-install-recommends \
    python3-django \
    apache2 \
    apache2-dev \
    curl \
    make \
    gcc \
    zlib1g-dev \
    libcairo2-dev \
    libnetpbm10-dev \
    netpbm \
    libpng-dev \
    libjpeg-dev \
    python3-numpy \
    python3-dev \
    python3-setuptools \
    libbz2-dev \
    swig \
    pkg-config \
    git \
    libcfitsio-dev \
    ssl-cert \
    ca-certificates \
    python3-psycopg2 \
    python3-pip \
    python3-pil \
    sqlite3 \
    python3-matplotlib \
    python3-tk \
    file \
    apt-utils \
    libgsl-dev \
    unhide \
    wget

# Python related stuff
RUN pip3 install --upgrade\
    pip
RUN for x in \
    setuptools \
    wheel \
    fitsio \
    simplejson \
    social-auth-core \
    social-auth-app-django \
    mod_wsgi \
    ; do pip3 install $x; done

# TODO: install pyfits as dependency

RUN mkdir -p /src \
    && cd /src \
    && git clone http://github.com/dstndstn/astrometry.net.git astrometry \
    && cd astrometry \
    && make -j \
    && make py -j \
    && make extra -j \
    && make install INSTALL_DIR=/usr/local

RUN cd /etc/apache2/mods-enabled \
    && rm mpm_event.conf mpm_event.load mime.conf mime.load \
    && ln -s ../mods-available/mpm_worker.conf . \
    && ln -s ../mods-available/mpm_worker.load . \
    && ln -s ../mods-available/headers.load .

RUN adduser --disabled-password nova --gecos "Astrometry.net web service,,,"

RUN mkdir -p /src/astrometry/net/secrets && mkdir -p /INDEXES

COPY start.sh        .
COPY process_submission.sh .
COPY django_db.py    /src/astrometry/net/secrets/
COPY auth.py         /src/astrometry/net/secrets/
COPY __init__.py     /src/astrometry/net/secrets/
COPY settings.py     /src/astrometry/net/
COPY docker.cfg      /src/astrometry/net/
COPY solvescript.sh  /src/astrometry/net/
COPY apache2.conf    /etc/apache2/

#WARNING : you need to run this in you shell before building image
#RUN cd /INDEXES/ \
#  && for i in 4100 4200; do \
#    wget -r -l1 --no-parent -nc -nd -A ".fits" http://data.astrometry.net/$i/;\
#    done

RUN cd /src/astrometry/net \
    && cp -ar appsecrets-example appsecrets \
    && python3 manage.py makemigrations \
    && python3 manage.py migrate \
    && python3 manage.py loaddata fixtures/* \
    && chmod 755 solvescript.sh

RUN mkdir /data2
RUN mkdir /data2/nova
RUN chown -R nova:nova /data2
# Uncomment to download the data file for Skyplot
# https://github.com/dstndstn/nova-docker/issues/1#issuecomment-359441985
# RUN wget http://data.astrometry.net/tycho2.kd -o /data2/nova/tycho2.kd

RUN chown -R nova.nova /src/astrometry
RUN mkdir /data
RUN mkdir /data/nova
RUN chown -R nova:nova /data/nova
RUN ln -s /bin/python3 /bin/python

# Necessary to add the site-packages into system path for Apache2 to properly load django.
# Should be safe to hard code the python version given 20.04 is already pretty outdated.
RUN echo 'export PATH="$PATH:/usr/local/lib/python3.8/dist-packages"' >> ~/.bashrc

EXPOSE 80
CMD ["/bin/bash", "./start.sh"]
# Build with docker build -t astrometryserver .
# Launch with docker run -d -p 80:80 --mount type=bind,source=$PWD/INDEXES,target=/INDEXES astrometryserver
