md = require('../deferred.coffee')

ll = null
pm = null

describe "ListenerList", ->
  beforeEach ->
    ll = new md.ListenerList()

  it "#add", ->
    f = ->
    ll.add(f)
    expect(ll.listeners.length).toEqual(1)

  it "#empty", ->
    f = ->
    ll.add(f)
    ll.empty()
    expect(ll.listeners.length).toEqual(0)

  it "#fire", ->
    x = 1
    f = -> x = 2
    ll.add(f)
    ll.fire()
    expect(x).toEqual(2)

  it "#size", ->
    f = ->
    ll.add(f)
    expect(ll.size()).toEqual(1)

describe "Promise", ->
  beforeEach ->
    pm = new md.Promise()

  it "#constructor", ->
    expect(pm.resolve_listeners).toBeDefined()
    expect(pm.reject_listeners).toBeDefined()
    expect(pm.state).toEqual("open")
  
  describe "#done", ->
    it "when state is open", ->
      pm.state = "open"
      f = ->
      pm.done(f)
      expect(pm.resolve_listeners.size()).toEqual(1)

    it "when state is resolved", ->
      pm.state = "resolved"
      x = 1
      f = -> x = 2
      pm.done(f)
      expect(pm.resolve_listeners.size()).toEqual(0)
      expect(x).toEqual(2)

