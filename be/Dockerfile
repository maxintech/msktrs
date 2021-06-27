# ./docker/app/Dockerfile
FROM ruby:2.7.3

# Adding gems
ADD Gemfile /app/Gemfile
WORKDIR /app
RUN bundle install

# Adding project files
ADD . /app

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "msktrs.ru"]