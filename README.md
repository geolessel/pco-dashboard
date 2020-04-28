# Planning Center Dashboard

This will hopefully be further fleshed out as we go. For now...

## Getting Started

To get this running locally, you will need an instance of Postgres
running. You can either edit config/dev.exs to match your local
instance, or you can use Docker to run a self-contained instance
(which is what I'm doing).

### postgres with Docker cheat sheet

If you are running it for the first time, you can create a container
with

``` shell
docker container run --name pco-dashboard-db --publish 5432:5432 --detach -e POSTGRES_PASSWORD=postgres postgres
```

You can stop the container with

``` shell
docker container stop pco-dashboard-db
```

If you've previously run the `docker container run` command before,
you will not be able to again since the name of `pco-dashboard-db` has
already been taken (by your previous container). Instead, start up the
previously-created container with

``` shell
docker container start pco-dashboard-db
```

### Install Dependencies, Create, Migrate, and Seed the Database

To go through initial setup, you can run

``` shell
mix setup
```

This will fetch all dependencies, ensure the database is created, and
migrate the database.

### Seed Components

For now, dashboard components are stored in the database though they
will unlikely change. To get the default starting components into your
database, you can run

``` shell
mix run apps/dashboard/priv/repo/seeds.exs
```

Seeding is idempotent, so you can run it as many times as you'd like
and you won't overwrite anything already in there. In these early days
of development there is going to be lots of components added so **run
early, run often**.

Even though `mix setup` will seed the database, you should only need
to run that command once. It is likely you should seed the database
many times during development to get any new components.

### Start the app

If you don't know Phoenix, you can start the server with

``` shell
mix phx.server
```

The app will be available at [http://localhost:4000](http://localhost:4000).

### Create a user

In order to use the app, you'll need to register a user. You can do so
at [/users/register](http://locahost:4000/users/register).

Once you register, check the logs back in your terminal. You should
see some debug output that contains a link to "confirm" your
account. Since we don't have this hooked up to any messaging services,
this is your only way to find the confirmation link. Just copy and
paste that link into your browser, and your account will be
confirmed. You currently should be able to do everything without
confirming, but that may change in the future.

### Get a Personal Access Token from Planning Center

Once you create your user, you need to let the app know your personal
access token. To get one, go to
[https://api.planningcenteronline.com/oauth/applications](https://api.planningcenteronline.com/oauth/applications).
In there, create a Personal Access Token. Describe the app however
you'd like (that value is for your benefit only).

Copy your app id and secret and paste those values into the
appropriate fields at
[/users/settings](http://locahost:4000/users/settings).
