FROM ruby:3.3
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
EXPOSE 3001
CMD ["bin/rails", "s", "-b", "0.0.0.0", "-p", "3001"]
