# ./docker/app/Dockerfile
FROM ruby:2.2

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

# Adding gems
ADD Gemfile /app/Gemfile
WORKDIR /app
RUN bundle install

# Adding project files
ADD . /app

# Run
EXPOSE 9292
CMD ./run.sh