FROM ubuntu:12.04
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

RUN apt-get update
RUN apt-get -y install curl git libxslt-dev libxml2-dev time

RUN curl -sSL https://get.rvm.io | bash -s stable
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

RUN /bin/bash -l -c 'rvm install ruby-1.9.2-p320'
RUN mkdir /repo
# Give the scraper user the same uid as deploy on the docker server
# TODO Currently hardcoded values
RUN addgroup --gid 4243 scraper
RUN adduser --home /data --disabled-login --gecos "Scraper User" --uid 4243 --gid 4243 scraper

# libcurl is needed by typhoeus gem
RUN apt-get -y install libcurl4-gnutls-dev
ADD Gemfile /etc/Gemfile
RUN /bin/bash -l -c 'bundle install --gemfile /etc/Gemfile'

# Special handling for scraperwiki gem because rubygems doesn't support
# gems from git repositories. So we have to explicitly install it.
RUN mkdir /build
RUN git clone https://github.com/openaustralia/scraperwiki-ruby.git /build
RUN cd /build; git checkout morph_defaults
# rake install is not working so doing it in two steps
# TODO Figure out what is going on here
RUN /bin/bash -l -c 'cd /build; rake build'
RUN /bin/bash -l -c 'cd /build; gem install /build/pkg/scraperwiki-3.0.1.gem'
RUN rm -rf /build

RUN apt-get -y install pdftohtml

VOLUME /repo
VOLUME /data
WORKDIR /data
