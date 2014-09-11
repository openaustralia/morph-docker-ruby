FROM openaustralia/morph-base
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

# libcurl is needed by typhoeus gem
RUN apt-get -y install curl libxslt-dev libxml2-dev libcurl4-gnutls-dev poppler-utils libqt4-dev

RUN curl -sSL https://get.rvm.io | bash -s stable
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

RUN /bin/bash -l -c 'rvm install ruby-1.9.2-p320'

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

# Add prerun script which will disable output buffering
ADD prerun.rb /usr/local/lib/prerun.rb
