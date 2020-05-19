FROM elixir:1.10.3-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base yarn git python

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
COPY apps/dashboard/mix.exs apps/dashboard/mix.exs
COPY apps/dashboard_web/mix.exs apps/dashboard_web/mix.exs
RUN mix do deps.get, deps.compile


WORKDIR /app/apps/dashboard_web
COPY apps/dashboard_web/assets ./assets/

WORKDIR /app/apps/dashboard_web/assets
RUN yarn install

# compile javascript and css
#
# The web lib directory is required to be in the
# image BEFORE we yarn run deploy. This is because
# purgecss looks in those directories to know
# what CSS to keep during the purge.
COPY apps/dashboard_web/lib /app/apps/dashboard_web/lib
RUN yarn run deploy

COPY apps/dashboard/priv /app/apps/dashboard/priv
COPY apps/dashboard_web/priv /app/apps/dashboard_web/priv

WORKDIR /app/apps/dashboard_web
RUN mix phx.digest

WORKDIR /app
COPY apps/dashboard/lib apps/dashboard/lib
RUN mix do compile, release

#########################
# prepare release image
FROM alpine:3.11.6 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/dashboard ./

ENV HOME=/app

EXPOSE 4000

CMD ["bin/dashboard", "start"]
