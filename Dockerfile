FROM ruby:2.6.6-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile* ./

RUN gem install bundler -v 2.4.22
RUN bundle install

EXPOSE 4000
