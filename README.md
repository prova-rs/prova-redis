# prova-redis

A cache resource plugin for [Prova](https://github.com/prova-rs/prova) — Redis cache for Prova — docker-exec over redis-cli, zero native code.

A **docker-exec** plugin: zero native code. It provisions an ephemeral `redis` container, waits
for readiness, and drives the CLI already in the image (`redis-cli`) — all through Prova's
`prova.containerized` + `container:run` SDK.

## Use it

Declare the plugin in your `prova.toml`:

```toml
[plugins]
redis = "prova-rs/prova-redis@v1"   # org/repo shorthand (fetched, pinned, cached)
```

Then in a test:

```lua
local redis = require("redis")

local resource = prova.fixture("redis", Scope.File, function(ctx)
  return redis.container(ctx)          -- provisions, waits, attaches a client, ties teardown
end)

prova.group("example", { requires = { "docker" } }, function(g)
  g:test("does the thing", function(t)
    local r = t:use(resource)
    -- r.client:...   -- drive it
    t:expect(r.url):matches("^redis://")
  end)
end)
```

Hand `r.url` (a `redis://…` endpoint) to the app under test via its env, and assert the effect
either through the app's API (black-box) or directly with the client here.

## API

`redis.container(ctx, opts?)` → `{ client, url, container }`

- `url` — `redis://127.0.0.1:<port>`, the endpoint for the app under test.
- `container` — the Docker handle (`:host_port`, `:run`, `:logs`, …).
- `client` — the docker-exec client (implemented in `init.lua`; typed in `library/redis.lua`).

`opts`: `image`, `tag` (default `7-alpine`), `timeout` — the `prova.containerized` options.

## Requirements

Docker at test time. Gate tests with `requires = { "docker" }` so they skip cleanly where the daemon
is absent.

## Develop

```bash
prova                       # runs proofs/ against ./init.lua (needs Docker)
prova plugin lint init.lua
```

MIT licensed.
