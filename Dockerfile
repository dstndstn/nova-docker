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
    ca-certificates \
    libapache2-mod-wsgi \
    python-psycopg2 \
    python-pip \
    python-pil \
    sqlite3 \
    python-matplotlib \
    python-tk

RUN for x in \
    setuptools \
    wheel \
    fitsio \
    simplejson \
    ; do pip install $x; done

#     django-openid-auth \
#     social \
#     splinter \
#     networkx \
#     gmane \
#     lxml \
#     requests \
#     python-dateutil \
#     parsedatetime \
#     pytz \

RUN mkdir -p /src \
    && cd /src \
    && git clone http://github.com/dstndstn/astrometry.net.git astrometry \
    && cd astrometry \
    && make \
    && make py \
    && make extra \
    && make install INSTALL_DIR=/usr/local

###
#RUN cd /src/astrometry && git pull

COPY apache2.conf /etc/apache2/apache2.conf

RUN cd /etc/apache2/mods-enabled \
    && rm mpm_event.conf mpm_event.load mime.conf mime.load \
    && ln -s ../mods-available/mpm_worker.conf . \
    && ln -s ../mods-available/mpm_worker.load . \
    && ln -s ../mods-available/headers.load .

RUN adduser --disabled-password nova --gecos "Astrometry.net web service,,,"

RUN cd /src/astrometry/net \
    && mkdir /src/astrometry/net/secrets

COPY django_db.py /src/astrometry/net/secrets/
COPY auth.py      /src/astrometry/net/secrets/
COPY __init__.py  /src/astrometry/net/secrets/
COPY settings.py  /src/astrometry/net/
COPY docker.cfg   /src/astrometry/net/
COPY solvescript.sh /src/astrometry/net/

RUN cd /src/astrometry/net \
    && python manage.py makemigrations \
    && python manage.py migrate \
    && python manage.py loaddata fixtures/* \
    && chmod 755 solvescript.sh

RUN chown -R nova.nova /src/astrometry

RUN apt-get install -y --no-install-recommends \
    file \
    ssh

RUN mkdir ~nova/.ssh \
    && ssh-keygen -f ~nova/.ssh/id_an -N '' \
    && cp ~nova/.ssh/id_an.pub ~nova/.ssh/authorized_keys

COPY ssh-config ~nova/.ssh/config

RUN chown -R nova.nova ~nova/.ssh

RUN mkdir -p /var/run/sshd \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

RUN mkdir -p /INDEXES
COPY index-4119.fits /INDEXES/


#ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
#CMD apachectl start

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
