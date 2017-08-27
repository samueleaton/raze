# Raze Core Middlewares

### proxy

*Proxies the request to another endpoint*

This allows Raze to proxy to external servers and also function as a load balancer.

`host : String | Array(String)` - The target(s) the the proxy should pass to.

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: "http://example.com"
)
#=> http://exmaple.com/yeezy/*
```

Raze will load balance (round robin) to mutlitple targets if `host` is an array. The following example will split traffic to `http://yeezy1.example.com` and `http://yeezy2.example.com`:

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: ["http://yeezy1.example.com", "http://yeezy2.example.com"]
)

```

**`path : String` - appends a path to the proxy target**

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: "http://example.com",
  path: "/dank"
)
#=> http://example.com/dank/yeezy/*
```

**`lchop_proxy_path : String` - will chop a string from the beginning of the request path**

In the following example, if Raze is running on `http://localhost:7777`, then a request to `http://localhost:7777/yeezy/dank` will proxy to `http://example.com/dank`

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: "http://example.com",
  lchop_proxy_path: "/yeezy"
)
# http://localhost:7777/yeezy/dank -> http://example.com/dank
```

**`ignore_proxy_path : Bool` - will ignore request path and will not pass it to the target**

In the following example, if Raze is running on `http://localhost:7777`, then a request to `http://localhost:7777/yeezy/dank` will proxy to `http://example.com/banana`

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: "http://example.com",
  path: "/banana",
  ignore_proxy_path: true
)
# http://localhost:7777/yeezy/dank -> http://example.com/banana
```

**`headers : Hash(String, String)` - adds headers to the original request headers before proxying to the target**

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: "http://example.com",
  headers: {"X-Forwarded-By" => "Raze", "Proxy-Auth": "my-secret-key"}
)
```

**`timeout : Int32 | Nil` - The number of seconds until timeout when trying to establish a connection and/or read the response body**

```ruby
all "/yeezy/*" Raze::Proxy.new(
  host: "http://example.com",
  timeout: 5
)
```

### body_parser

[*In Development*]

*Parses `x-www-form-urlencoded` and `application/json` request bodies*

### static_cache

[*In Development*]

*Caches static assets to decrease IO operations*

### cors

[*In Development*]

Enable/configures CORS

### secure_headers

[*In Development*]

Makes application more secure by responding with various HTTP headers
