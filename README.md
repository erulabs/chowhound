A time tracking tool for hungry developers
==================

Chowhound is a NodeJS web app built with the following goodies:

- express
- gulp
- browserify
- bootstrap
- angularjs
- redis

### Things to know

Run `gulp watch` to develop - browse to localhost:8080

- static content server at /
- JSON only api server at /api

In production, something like NGINX would serve / and proxy pass /api to the app.

In development, gulp-connect and the proxy middleware does that for us (with livereload!)

Because we use redis as a backend, we could face memory loss in the event of system failure.

Because it's a lunch tracker, I don't care. It's super fast and super fun. Plus redis sentinel can resolve that issue.

### Production instructions

Nginx should listen on port 80 serving / out of the apps `./public` directory. It should proxy pass (ideally) on a socket file to the app all requests to ^/api/*. You should set an NODE_ENV (see ./shared/config.js) of something other than "dev", drop a newrelic.js file in the app root, `npm install --production`` and run `node server`. Make sure you have redis available and configured via ENV variables (again see ./shared/config.js). We use redis as a database, so please enable saving!
