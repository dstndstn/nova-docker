FROM debian
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
    git
#cfitsio-dev
#\
#&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /src/cfitsio \
    && curl -SL http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3390.tar.gz \
    | tar -xzC /src/cfitsio \
    && cd /src/cfitsio/cfitsio \
    && ./configure --prefix=/usr/local \
    && make \
    && make install

# RUN mkdir -p /src/astrometry \
#     && curl -SL http://astrometry.net/downloads/astrometry.net-latest.tar.gz \
#     | tar -xzC /src/astrometry \
#     && cd /src/astrometry/astrometry.net-* \
#     && make \
#     && make py \
#     && make extra \
#     && make install INSTALL_DIR=/usr/local

RUN cd /src \
    && git clone https://github.com/dstndstn/astrometry.net.git astrometry \
    && cd astrometry \
    && make \
    && make py \
    && make extra \
    && make install INSTALL_DIR=/usr/local

RUN mkdir -p /etc/apache2
COPY apache2.conf /etc/apache2/apache2.conf

EXPOSE 80
