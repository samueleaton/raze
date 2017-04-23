# Raze

TODO: Write a description here

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  raze:
    github: samueleaton/raze
```

## Usage

```ruby
require "raze"

get "/hello" do |ctx|
  "hello, world!"
end

Raze.run
```


Raze takes a modular-first approach to middlewares

```ruby
require "raze"

# Define middlewares
class Authenticator < Raze::Handler
  def call(ctx, done)
    puts "Authenticate here..."
    done.call
  end
end

class DDoSBlocker < Raze::Handler
  def call(ctx, done)
    puts "Prevent DDoS attack here..."
    done.call
  end
end

class UserFetcher < Raze::Handler
  def call(ctx, done)
    # Fetch user record from DB here...
    ctx.locals["user_name"] = "Sam"
    done.call
  end
end

# Define routes, attach middlewares
get "/api/**", [Authenticator.new, DDoSBlocker.new]

get "/api/user/:user_id", UserFetcher.new do |ctx|
  "hello, #{ctx.locals["user_name"]}!"
end

Raze.run
```


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/[your-github-name]/raze/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Sam Eaton](https://github.com/samueleaton) Sam Eaton - creator, maintainer

## Todo

Note: File upload is not part of the scope of this project. This is a routing/middleware library. The line needs to be drawn somewhere for simplicity's sake. 👍

### MVP for project repo public:

- [x] Make sure params/query/json/x-www-form-urlencoded parsing works
- [x] Make sure special http protocols work (e.g. HEAD/OPTIONS request)
- [x] Have exception handling and error rescuing for dev and prod
- [x] implement websocket functionality
- [x] websocket routes should be able to parse params/query from url
- [ ] Design logos
- [ ] Test coverage
- [ ] make sure ssl/https is easy to enable/configure
- [ ] Design custom 404 and 500 pages
- [x] Keep an array of all paths at startup to check if a globbed path is being created after a more specific path (which is not allowed)
- [x] store paths that come after matching paths with "*" or ":" in sub trees
- [x] remove the `Raze.all` method
- [ ] have good examples in README
- [ ] don't fail if static directory doesn't exist
- [x] should return a 404 if trying to progress to next middleware or block that doesn't exist
- [ ] make accessing ctx.params and ctx.query lazy for better performance?
- [ ] Fix the routing block so that the return type is void or not inferred


### Future Plans:

- [ ] Add date goals to all of the checklist items
- [ ] form-data parsing
- [ ] Ability to opt out of static indexing?
- [ ] Create middleware (opt-in) that allows a non-indexed public folder
- [ ] create thorough examples for how to create a non-indexed public folder
- [ ] Design website
- [ ] Create a "good" website
- [ ] enable/disable features in dev and prod
- [ ] Create a very basic logging middleware and show examples for how to make a more advanced one.
- [ ] Create a raze-ws js library for easy websockets
- [ ] create a cli tool for creatig new projects (with webpack and stuff)
