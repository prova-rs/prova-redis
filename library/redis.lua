---@meta redis
--- prova-redis — Redis cache for Prova (docker-exec over redis-cli, zero native code).
---
--- Editor-only type stub for `require("redis")`: it gives consumers completion and signatures and
--- ships nothing at runtime. Keep it in sync with init.lua's public API.

local redis = {}

--- Options for `redis.container`.
---@class redis.ContainerOpts
---@field image? string    # override the base image repo (default "redis")
---@field tag? string      # override the image tag (default "7-alpine")
---@field timeout? string  # readiness deadline (default "60s")
---@field network? any     # a docker.network() handle or name — join a topology network
---@field alias? string    # DNS alias on that network (populates `resource.network`)

--- The docker-exec client attached to a provisioned container: each method shells out to the
--- `redis-cli` already in the image via `container:run` (no shell, no quoting) and returns the
--- trimmed stdout, raising on a non-zero exit.
---@class redis.Client
local Client = {}

--- PING the server; "PONG" when it is up.
---@return string
function Client:ping() end

--- SET `k` to `v`; returns redis's reply ("OK").
---@param k string
---@param v string
---@return string
function Client:set(k, v) end

--- GET `k`; nil when the key is missing.
---@param k string
---@return string|nil
function Client:get(k) end

--- INCRBY `k` by `by` (default 1); returns the new value.
---@param k string
---@param by? integer
---@return integer
function Client:incr(k, by) end

--- Does `k` exist?
---@param k string
---@return boolean
function Client:exists(k) end

--- DEL the given keys; returns how many were removed.
---@param ... string
---@return integer
function Client:del(...) end

--- Generic escape hatch: any redis-cli command → trimmed stdout (nil if empty).
---@param ... string
---@return string|nil
function Client:command(...) end

--- No-op: the docker-exec client holds no connection; teardown rides on the container's scope.
function Client:close() end

--- The provisioned resource (the standard `prova.ContainerResource` shape).
---@class redis.Resource
---@field url string           # host-vantage connection URL, e.g. "redis://127.0.0.1:<mapped>"
---@field host string          # "127.0.0.1"
---@field port integer         # the mapped host port
---@field container any        # the docker Container handle
---@field client redis.Client  # the attached docker-exec client (PING-gated on readiness)
---@field network? prova.NetworkVantage  # present when provisioned with opts.network + opts.alias

--- Provision an ephemeral Redis container, wait until it answers PING, tie teardown to `ctx`'s
--- scope, and return the resource with an attached client.
---@param ctx prova.Context|prova.TestContext
---@param opts? redis.ContainerOpts
---@return redis.Resource
function redis.container(ctx, opts) end

--- Attach a client (the standard `client` facet). This plugin's client is docker-exec — it drives
--- redis-cli inside a `container` handle — so attaching by URL alone is not supported; in practice
--- use the `client` field of `redis.container(ctx)` instead.
---@param url string
---@param opts table
---@param container any
---@return redis.Client
function redis.client(url, opts, container) end

return redis
