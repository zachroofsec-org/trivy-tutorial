FROM debian:stretch-20210208-slim

ENV DEBIAN_FRONTEND noninteractive

# +--------------------+
# SYSTEM-LEVEL PACKAGE MANAGER INSTALLATION
# (and misc dependencies)
# +--------------------+

RUN apt-get update -y &&\
    apt-get dist-upgrade &&\
    apt-get install -y apache2 \
        wget \
        build-essential &&\
    apt-get autoremove &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# +--------------------+
# MAKE INSTALLATION (shellshock)
# (system-level installation WITHOUT package manager)
# +--------------------+

#RUN wget https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz && \
#    tar zxvf bash-4.3.tar.gz && \
#    cd bash-4.3 && \
#    ./configure && \
#    make && \
#    make install

# +--------------------+
# APPLICATION-LEVEL PACKAGE MANAGER INSTALLATION (regex DoS)
# +--------------------+

#COPY lang_dependencies/Pipfile.lock /app/Pipfile.lock
