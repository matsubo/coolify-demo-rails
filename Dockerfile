# syntax=docker/dockerfile:1

# ---- Base ----
FROM ruby:3.4-alpine AS base
WORKDIR /app
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT=1

# ---- Build stage ----
FROM base AS build

RUN apk add --no-cache build-base postgresql-dev curl yaml-dev

COPY Gemfile ./
RUN bundle lock && \
    bundle install --jobs 4 && \
    rm -rf ~/.bundle /usr/local/bundle/cache

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile 2>/dev/null || true
RUN rm -rf tmp/cache vendor/bundle/ruby/*/cache

# ---- Runtime stage ----
FROM base AS runtime

RUN apk add --no-cache libpq curl tzdata yaml && \
    adduser -D -h /app rails

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

RUN mkdir -p db storage log tmp/pids && \
    chown -R rails:rails db storage log tmp

USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD wget -qO- http://localhost:3000/up || exit 1

CMD ["sh", "-c", "bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000"]
