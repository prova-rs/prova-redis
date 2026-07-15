---@meta redis
--- LuaCATS annotations for the `redis` Prova plugin — the consumer-facing contract for
--- `local redis = require("redis")`. prova syncs this into a project's `annotations/` so
--- `require("redis")` resolves by module name. Keep in step with `../redis.lua`.

---A docker-exec Redis client (drives `redis-cli` inside the container).
---@class redis.Client
local Client = {}

---@return string
function Client:ping() end

---@param key string
---@param value string
---@return string
function Client:set(key, value) end

---@param key string
---@return string|nil value nil if the key is missing
function Client:get(key) end

---@param key string
---@param by integer? amount to increment by (default 1)
---@return integer
function Client:incr(key, by) end

---@param key string
---@return boolean
function Client:exists(key) end

---@param ... string keys to delete
---@return integer count of keys removed
function Client:del(...) end

---Run an arbitrary redis-cli command, returning its raw stdout.
---@param ... string
---@return string
function Client:command(...) end

---No-op; the container teardown reaps everything.
function Client:close() end

---The provisioned Redis: `{ client, url, container }`.
---@class redis.Resource
---@field client redis.Client the client to drive Redis
---@field url string the `redis://…` endpoint for the app under test
---@field container prova.Container the raw container (host_port, logs, run, exec, stop)

---@class redis
local redis = {}

---Provision an ephemeral Redis and return the resource. Teardown is tied to `ctx`.
---@param ctx prova.Context
---@param opts table? image/tag/port overrides
---@return redis.Resource
function redis.container(ctx, opts) end

return redis
