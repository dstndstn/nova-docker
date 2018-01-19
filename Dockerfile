FROM ubuntu:16.04
RUN apt-get -y update && apt-get install -y apt-utils
RUN apt-get install -y --no-install-recommends \
    python-django \
    apache2 \
    curl \
    make \
    gcc \
    zlib1g-dev \
    libcairo2-dev \
    libnetpbm10-dev \
    netpbm \
    libpng12-dev \
    libjpeg-dev \
    python-numpy \
    python-pyfits \
    python-dev \
    libbz2-dev \
    swig \
    pkg-config \
    git \
    libcfitsio-dev \
    ssl-cert \
    ca-certificates \
    libapache2-mod-wsgi \
    python-psycopg2 \
    python-pip \
    python-pil \
    sqlite3 \
    python-matplotlib \
    python-tk \
    file \
    apt-utils \
    libgsl-dev \
    unhide \
    wget

# Remove APT files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Python related stuff
RUN pip install --upgrade\
    pip
RUN for x in \
    setuptools \
    wheel \
    fitsio \
    simplejson \
    social-auth-core \
    social-auth-app-django \
    ; do pip install $x; done

RUN mkdir -p /src \
    && cd /src \
    && git clone http://github.com/dstndstn/astrometry.net.git astrometry \
    && cd astrometry \
    && make \
    && make py \
    && make extra \
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

#WARNING : you need to run this in you shell before nuilding image
#RUN cd /INDEXES/ \
#  && for i in 4100 4200; do \
#    wget -r -l1 --no-parent -nc -nd -A ".fits" http://data.astrometry.net/$i/;\
#    done

RUN cd /src/astrometry/net \
    && python manage.py makemigrations \
    && python manage.py migrate \
    && python manage.py loaddata fixtures/* \
    && chmod 755 solvescript.sh

RUN chown -R nova.nova /src/astrometry

EXPOSE 80
CMD ["/bin/bash", "./start.sh"]
#Build with docker build -t astrometryserver .
#Launch with docker run -d -p 80:80 --mount type=bind,source=$PWD/INDEXES,target=/INDEXES astrometryserver
