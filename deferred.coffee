class ListenerList
  constructor: ->
    @listeners = []

  add: (listener) ->
    @listeners.push(listener)

  fire: ->
    listener.call() for listener in @listeners

  size: ->
    @listeners.length

class Promise
  constructor: ->
    @resolve_listeners = new ListenerList()
    @reject_listeners  = new ListenerList()
    # state = [open|resolved|rejected]
    @state             = "open"

  done: (listener) ->
    switch @state
      when "open"
        @resolve_listeners.add(listener)
      when "resolved"
        listener.call()
    this

  fail: (listener) ->
    switch @state
      when "open"
        @reject_listeners.add(listener)
      when "rejected"
        listener.call()
    this

  then: (oktask, ngtask) ->
    newdf = new Deferred()

    @done ->
      promise = oktask()
      promise.done(newdf.resolve)
      promise.fail(newdf.reject)

    if ngtask?
      @fail ->
        promise = ngtask()
        promise.done(newdf.resolve)
        promise.fail(newdf.resolve)

    newdf.promise()

# protected
  _resolve: ->
    switch @state
      when "open"
        @state = "resolved"
        @resolve_listeners.fire()

  _reject: ->
    switch @state
      when "open"
        @state = "rejected"
        @reject_listeners.fire()

class Deferred
  constructor: ->
    @_promise = new Promise()

  resolve: ->
    @_promise._resolve()

  reject: ->
    @_promise._reject()

  promise: ->
    @_promise

Deferred.when = (tasks...) ->
  newdf = new Deferred()
  tasks_yet_resolved = tasks.length

  resolve_handler = ->
    tasks_yet_resolved -= 1
    if tasks_yet_resolved == 0
      newdf.resolve()

  reject_handler = ->
    newdf.reject()

  tasks.forEach (task) ->
    promise = task()
    promise.done(resolve_handler)
    promise.fail(reject_handler)

  newdf.promise()

exports.ListenerList = ListenerList
exports.Promise      = Promise
exports.Deferred     = Deferred
