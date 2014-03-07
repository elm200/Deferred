md = require('../deferred.coffee')

ll = null
pm = null
df = null

delay = (ms, task) ->
  setTimeout task, ms

describe "delay", ->
  it "better API than setTimeout", ->
    x = 1
    delay 100, ->
      expect(x).toEqual(1)

describe "ListenerList", ->
  beforeEach ->
    ll = new md.ListenerList()

  it "#add", ->
    f = ->
    ll.add(f)
    expect(ll.listeners.length).toEqual(1)

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
      res = pm.done(f)
      expect(pm.resolve_listeners.size()).toEqual(1)
      expect(res).toBe(pm)

    it "when state is resolved", ->
      pm.state = "resolved"
      x = 1
      f = -> x = 2
      res = pm.done(f)
      expect(x).toEqual(2)

  describe "#fail", ->
    it "when state is open", ->
      pm.state = "open"
      f = ->
      res = pm.fail(f)
      expect(pm.reject_listeners.size()).toEqual(1)
      expect(res).toBe(pm)

    it "when state is rejected", ->
      pm.state = "rejected"
      x = 1
      f = -> x = 2
      res = pm.fail(f)
      expect(x).toEqual(2)

  describe "#_resolve", ->
    it "is ok", ->
      x = 1
      f = -> x = 2
      pm.resolve_listeners.add(f)
      pm._resolve()
      expect(pm.state).toEqual("resolved")

  describe "#_reject", ->
    it "is ok", ->
      x = 1
      f = -> x = 2
      pm.resolve_listeners.add(f)
      pm._reject()
      expect(pm.state).toEqual("rejected")

  describe "#then", ->
    it "when promise is resolved", ->
      x = []
      task1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.resolve()
        df.promise()

      oktask = ->
        d = new Deferred()
        delay 100, ->
          x.push(2)
          d.resolve()
        d.promise()

      task2 = -> x.push(3)

      p1 = task1()
      expect(p1.then).toBeDefined()

      p2 = p1.then(oktask)
      expect(p2.done).toBeDefined()

      p2.done(task2)

      delay 300, ->
        expect(x).toEqual([1, 2, 3])

    it "when promise is rejected", ->
      x = []
      task1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.reject()
        df.promise()

      oktask = ->
        d = new Deferred()
        delay 100, ->
          x.push(2)
          d.resolve()
        d.promise()

      ngtask = ->
        d = new Deferred()
        delay 100, ->
          x.push(-2)
          d.reject()
        d.promise()

      task2 = -> x.push(3)

      p1 = task1()
      expect(p1.then).toBeDefined()

      p2 = p1.then(oktask, ngtask)
      expect(p2.done).toBeDefined()

      p2.fail(task2)

      delay 300, ->
        expect(x).toEqual([1, -2, 3])

    it "when promise is rejected and then recovered", ->
      x = []
      task1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.reject()
        df.promise()

      oktask = ->
        d = new Deferred()
        delay 100, ->
          x.push(2)
          d.resolve()
        d.promise()

      ngtask = ->
        d = new Deferred()
        delay 100, ->
          x.push(-2)
          d.resolve()
        d.promise()

      task2 = -> x.push(3)
      task3 = -> x.push(4)

      p1 = task1()
      expect(p1.then).toBeDefined()

      p2 = p1.then(oktask, ngtask)
      expect(p2.done).toBeDefined()

      p2.fail(task2).done(task3)

      delay 300, ->
        expect(x).toEqual([1, -2, 4])

describe "Deferred", ->
  beforeEach ->
    df = new md.Deferred()

  it "#constructor", ->
    expect(df._promise).toBeDefined()

  it "#resolve", ->
    expect(-> df.resolve()).not.toThrow()

  it "#resolve", ->
    expect(-> df.reject()).not.toThrow()

  it "#promise", ->
    promise = df._promise
    expect(df.promise()).toBe(promise)

  describe "usage of Deferred", ->
    it "when a resolve listener is added before resolved(normal case)", ->
      x = []
      f1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.resolve()
        df.promise()
      f2 = ->
        x.push(2)
      p = f1()
      expect(p.done).toBeDefined()
      p.done(f2)
      delay 200, ->
        expect(x).toEqual([1, 2])

    it "when a resolve listener added after resolved", ->
      x = []
      f1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.resolve()
        df.promise()
      f2 = ->
        x.push(2)
      p = f1()
      expect(p.done).toBeDefined()
      delay 200, ->
        p.done(f2)
        expect(x).toEqual([1, 2])

    it "when a reject listener is added before rejected(normal case)", ->
      x = []
      f1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.reject()
        df.promise()
      f2 = ->
        x.push(2)
      p = f1()
      expect(p.fail).toBeDefined()
      p.fail(f2)
      delay 200, ->
        expect(x).toEqual([1, 2])

    it "when a reject listener is added after rejected", ->
      x = []
      f1 = ->
        df = new md.Deferred()
        delay 100, ->
          x.push(1)
          df.reject()
        df.promise()
      f2 = ->
        x.push(2)
      p = f1()
      expect(p.fail).toBeDefined()
      delay 200, ->
        p.fail(f2)
        expect(x).toEqual([1, 2])

  describe ".when", ->
    it "when all tasks are resolved", ->
      x = []

      task1 = ->
        df = new md.Deferred()
        df.resolve()
        df.promise()

      task2 = ->
        d = new md.Deferred()
        d.resolve()
        d.promise()

      task3 = -> x.push(3)
      task4 = -> x.push(4)

      p = md.Deferred.when(task1, task2)
      expect(p.done).toBeDefined()
      p.done(task3).fail(task4)

      expect(x).toEqual([3])

    it "when one of the tasks is rejected", ->
      x = []

      task1 = ->
        df = new md.Deferred()
        df.resolve()
        df.promise()

      task2 = ->
        d = new md.Deferred()
        d.reject()
        d.promise()

      task3 = -> x.push(3)
      task4 = -> x.push(4)

      p = md.Deferred.when(task1, task2)
      expect(p.done).toBeDefined()
      p.done(task3).fail(task4)

      expect(x).toEqual([4])

    it "when all the tasks are resolved asynchronically", ->
      x = []

      task1 = ->
        df = new md.Deferred()
        delay 150, ->
          x.push(1)
          df.resolve()
        df.promise()

      task2 = ->
        d = new md.Deferred()
        delay 200, ->
          x.push(2)
          d.resolve()
        d.promise()

      task3 = -> x.push(3)
      task4 = -> x.push(4)

      p = md.Deferred.when(task1, task2)
      expect(p.done).toBeDefined()
      p.done(task3).fail(task4)
      delay 250, ->
        expect(x).toEqual([1, 2, 3])
