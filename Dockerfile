FROM python:latest
# install cron and R package dependencies
ENV DEBIAN_FRONTEND noninteractive
 
RUN apt-get -qq update && apt-get install -qq -y \
    odbc-postgresql \
    libsqliteodbc \
    git \
    gcc \
    libssl-dev \
    python-dev \
    cython3 \
    g++ \
    freetds-dev \
    freetds-bin \
    unixodbc-dev \
    libopenblas-base \
    cfortran \
    liblapack-dev \
    apt-transport-https \
    curl \
    gnupg \
    unixodbc-dev \
    apt-transport-https \ 
    locales \
    krb5-user 
    
## USE when Microsoft mirror works
#RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
#    && curl https://packages.microsoft.com/config/debian/$(grep VERSION_ID /etc/os-release|sed 's/[^0-9]*//g')/prod.list > /etc/apt/sources.list.d/mssql-release.list \
#    && apt-get -qq update \
#    && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 \
#    ## clean up
#    && apt-get clean \ 
#    && rm -rf /var/lib/apt/lists/ \ 
#    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## Microsoft broken mirror workaround
RUN apt-get install -qq -y unixodbc unixodbc-dev \
    && curl -O https://packages.microsoft.com/debian/10/prod/pool/main/m/msodbcsql17/msodbcsql17_17.5.2.1-1_amd64.deb \
    && ACCEPT_EULA=Y dpkg -i msodbcsql17_17.5.2.1-1_amd64.deb

RUN pip install pandas dask configparser simplejson SQLAlchemy PyMySQL Cython pandas dask requests chardet openpyxl ipython Alembic pyodbc toolz fsspec cloudpickle prettytable ciscoconfparse
 #RUN apt-get -qq update && apt-get install -qq apt-transport-https locales krb5-user && apt-get -qq clean

RUN locale-gen "en_US.UTF-8"
RUN echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/default/locale

#lower TLS version requirement
RUN curl -o /etc/ssl/openssl.cnf https://github.com/openssl/openssl/blob/master/apps/openssl.cnf
RUN echo "[default_conf]\nssl_conf = ssl_sect\n[ssl_sect]\nsystem_default = system_default_sect\n[system_default_sect]\nMinProtocol = TLSv1\nCipherString = DEFAULT@SECLEVEL=1" >> /etc/ssl/openssl.cnf

ENV KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM
ENV KRB5CCNAME=FILE:/app/tgt

COPY init-script.sh configureKerberosClient.sh /tmp/
CMD /tmp/init-script.sh

WORKDIR /app
