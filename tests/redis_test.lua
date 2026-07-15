-- Self-test for prova-redis: provision Redis, then set/get/exists/incr/del/command round-trips
-- through the docker-exec client. Requires docker; skips gracefully otherwise.

local cache = prova.fixture("redis", Scope.File, function(ctx)
  return require("redis").container(ctx).client
end)

prova.group("redis", { requires = { "docker" } }, function(g)
  g:test("set / get round-trips a value", function(t)
    local r = t:use(cache)
    r:set("greeting", "hello")
    t:expect(r:get("greeting")):equals("hello")
    t:expect(r:get("missing")):is_nil()
  end)

  g:test("exists, incr, and del", function(t)
    local r = t:use(cache)
    t:expect(r:exists("counter")):is_false()
    t:expect(r:incr("counter")):equals(1)
    t:expect(r:incr("counter", 4)):equals(5)
    t:expect(r:exists("counter")):is_true()
    t:expect(r:del("counter")):equals(1)
    t:expect(r:exists("counter")):is_false()
  end)

  g:test("ping and the generic command escape hatch", function(t)
    local r = t:use(cache)
    t:expect(r:ping()):equals("PONG")
    r:command("SET", "color", "blue")
    t:expect(r:command("GET", "color")):equals("blue")
  end)
end)
