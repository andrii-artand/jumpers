-- WoW: Forever: UnitName gives the first name, addon messages come from "First Last". Our own
-- echo must not turn us into a second player.
local Mock = require("spec.wow_mock")

describe("addon on a client with surnames", function()
  local ns

  setup(function()
    Mock.sender = "Tester Vl-TestRealm"
    ns = Mock.load("Jumpers.toc", 1)
    Mock.fire("ADDON_LOADED", "Jumpers")
    Mock.fire("PLAYER_LOGIN")
    ns.board.records["Tester-TestRealm:" .. ns.Today()] = { p = "Tester-TestRealm", c = "PALADIN", n = 29,
      e = GetServerTime(), d = ns.Today(), u = 30, g = 0.8 }
    Mock.advance(12)
  end)

  teardown(function() Mock.sender = nil end)

  it("learns its full name from its own echo", function()
    assert.equal("Tester Vl-TestRealm", ns.Comm.Me())
    assert.is_true(ns.Comm.status.channel)
  end)

  it("shows one player, once", function()
    local top = ns.Board.top(ns.board, ns.Today(), 1)
    assert.equal(1, #top)
    assert.equal("Tester Vl-TestRealm", top[1].p)
    assert.is_nil(ns.board.peers["Tester Vl-TestRealm"])
    local online, n = ns.Comm.Online(), 0
    for _ in pairs(online) do n = n + 1 end
    assert.equal(1, n)
  end)

  it("doesn't take a namesake for itself", function()
    Mock.fire("CHAT_MSG_ADDON", "JMPR", ns.Wire.heartbeat("MAGE"), "GUILD", "Tester Xl-TestRealm")
    assert.equal("Tester Vl-TestRealm", ns.Comm.Me())
    assert.is_true(ns.Comm.Online()["Tester Xl-TestRealm"])
  end)
end)
