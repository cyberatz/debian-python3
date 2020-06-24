FROM python:slim
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
    
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
RUN curl https://packages.microsoft.com/config/debian/$(grep VERSION_ID /etc/os-release|sed 's/[^0-9]*//g')/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt-get -o Acquire::CompressionTypes::Order::=gz update \ 
     && apt-get -qq update 
RUN ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 \
    ## clean up
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds


RUN pip install pandas dask configparser simplejson SQLAlchemy PyMySQL Cython pandas dask requests chardet openpyxl ipython Alembic pyodbc toolz fsspec cloudpickle prettytable 
 #RUN apt-get -qq update && apt-get install -qq apt-transport-https locales krb5-user && apt-get -qq clean

RUN locale-gen "en_US.UTF-8"
RUN echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/default/locale

ENV KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM
ENV KRB5CCNAME=FILE:/app/tgt

COPY init-script.sh configureKerberosClient.sh /tmp/
CMD /tmp/init-script.sh
