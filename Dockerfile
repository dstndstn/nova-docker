FROM ubuntu
#RUN apt-get -y update && apt-get install -y \
RUN apt-get -y update
RUN apt-get install -y \
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
    --no-install-recommends
#\
#&& rm -rf /var/lib/apt/lists/*

RUN apt-get install -y --no-install-recommends \
    ssl-cert \
    ca-certificates


# RUN mkdir -p /src/cfitsio \
#     && curl -SL http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3390.tar.gz \
#     | tar -xzC /src/cfitsio \
#     && cd /src/cfitsio/cfitsio \
#     && ./configure --prefix=/usr/local \
#     && make \
#     && make install

# RUN mkdir -p /src/astrometry \
#     && curl -SL http://astrometry.net/downloads/astrometry.net-latest.tar.gz \
#     | tar -xzC /src/astrometry \
#     && cd /src/astrometry/astrometry.net-* \
#     && make \
#     && make py \
#     && make extra \
#     && make install INSTALL_DIR=/usr/local

RUN mkdir -p /src \
    && cd /src \
    && git clone http://github.com/dstndstn/astrometry.net.git astrometry \
    && cd astrometry \
    && make \
    && make py \
    && make extra \
    && make install INSTALL_DIR=/usr/local

RUN apt-get install -y --no-install-recommends \
    libapache2-mod-wsgi \
    python-psycopg2 \
    python-pip

RUN for x in \
    setuptools \
    wheel \
    django-openid-auth \
    social \
    ; do pip install $x; done

COPY apache2.conf /etc/apache2/apache2.conf

RUN cd /etc/apache2/mods-enabled \
    && rm mpm_event.conf mpm_event.load mime.conf mime.load \
    && ln -s ../mods-available/mpm_worker.conf . \
    && ln -s ../mods-available/mpm_worker.load . \
    && ln -s ../mods-available/headers.load .

RUN adduser --system --disabled-password --disabled-login nova \
    && addgroup --system nova \
    && adduser nova nova

RUN chown -R nova.nova /src/astrometry \
    && mkdir /src/astrometry/net/secrets

COPY django_db.py /src/astrometry/net/secrets/django_db.py
COPY auth.py      /src/astrometry/net/secrets/auth.py
COPY __init__.py  /src/astrometry/net/secrets/

#ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
#CMD apachectl start

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
