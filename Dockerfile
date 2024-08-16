FROM --platform=$BUILDPLATFORM python:latest
# install cron and R package dependencies
ENV DEBIAN_FRONTEND noninteractive
 
RUN apt-get -qq update \
    && apt-get install -qq -y \
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
    unixodbc \
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
    krb5-user \
    python3-pip \
    && echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/default/locale \
    && locale-gen "en_US.UTF-8" 

RUN curl -O https://packages.microsoft.com/debian/11/prod/pool/main/m/msodbcsql18/msodbcsql18_18.0.1.1-1_amd64.deb \
    && ACCEPT_EULA=Y dpkg -i msodbcsql18_18.0.1.1-1_amd64.deb \
    && rm msodbcsql18_18.0.1.1-1_amd64.deb \
    && apt-get -qq clean \
    && python -m pip install --upgrade pip \
    && pip install pandas dask configparser simplejson SQLAlchemy PyMySQL Cython requests chardet openpyxl ipython Alembic pyodbc toolz fsspec cloudpickle prettytable ciscoconfparse paramiko scp webdavclient3 \
    && pip install jupyterlab notebook voila
    

#lower TLS version requirement
RUN curl -o /etc/ssl/openssl.cnf https://github.com/openssl/openssl/blob/master/apps/openssl.cnf \
    && echo "[default_conf]\nssl_conf = ssl_sect\n[ssl_sect]\nsystem_default = system_default_sect\n[system_default_sect]\nMinProtocol = TLSv1\nCipherString = DEFAULT@SECLEVEL=1" >> /etc/ssl/openssl.cnf \
    && chmod +rwx /etc/ssl/openssl.cnf \
    && sed -i 's/TLSv1.2/TLSv1/g' /etc/ssl/openssl.cnf \
    && sed -i 's/SECLEVEL=2/SECLEVEL=1/g' /etc/ssl/openssl.cnf

ENV KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM
ENV KRB5CCNAME=FILE:/app/tgt

COPY init-script.sh configureKerberosClient.sh /tmp/
CMD /tmp/init-script.sh

WORKDIR /app
