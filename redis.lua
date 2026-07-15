-- prova-redis — a cache resource plugin for Prova (Redis cache for Prova — docker-exec over redis-cli, zero native code). A docker-exec
-- plugin: zero native code. It provisions an ephemeral container via `prova.containerized`, waits for
-- readiness, and drives the CLI already in the image via `container:run` — the whole exec-CLI SDK.
--
--   local redis = require("redis")
--   local r = redis.container(ctx)      -- { client, url, container }
--   -- r.client:...   -- drive it (see the methods below)
--   -- r.url          -- the endpoint to hand the app under test

-- Drive the client CLI inside the container. `container:run{argv}` runs it directly (no shell, no
-- quoting) and returns stdout, raising on a non-zero exit. Use `prova.parse.*` on the output:
--   prova.parse.lines(out)          line-oriented CLIs
--   prova.parse.rows(out, sep)      delimited output → rows of columns
--   prova.parse.table(out, sep)     first line is a header → rows keyed by column name
--   prova.parse.json(out)           JSON (incl. one-object-per-line `--json` via lines + json)
local function make_client(container)
  -- run redis-cli directly (no shell, no quoting); trim the trailing newline.
  local function rc(...)
    return (container:run({ "redis-cli", ... }):gsub("%s+$", ""))
  end

  local client = {}
  function client:ping() return rc("PING") end
  function client:set(k, v) return rc("SET", k, v) end
  function client:get(k)
    local out = rc("GET", k)
    if out == "" then return nil end          -- empty output == missing key
    return out
  end
  function client:incr(k, by) return tonumber(rc("INCRBY", k, tostring(by or 1))) end
  function client:exists(k) return rc("EXISTS", k) == "1" end
  function client:del(...) return tonumber(rc("DEL", ...)) or 0 end
  -- Generic escape hatch: any redis-cli command → trimmed stdout (nil if empty).
  function client:command(...)
    local out = rc(...)
    if out == "" then return nil end
    return out
  end

  function client:close() end
  return client
end

local redis = prova.containerized{
  name = "redis",
  image = "redis", tag = "7-alpine",
  port = 6379,
  timeout = "60s",
  url = function(host_port)
    return "redis://127.0.0.1:" .. host_port
  end,
  -- The factory execs into the container; its PING is the readiness gate (redis-cli exits non-zero
  -- until the server answers, so container:run raises and prova.retry loops until it's up).
  client = function(_url, _opts, container)
    local client = make_client(container)
    if client:ping() ~= "PONG" then error("redis did not answer PING") end
    return client
  end,
}

return redis
