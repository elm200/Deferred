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

  then: (resolve_listener, reject_listener) ->
    df = new Deferred()
    @done(resolve_listener)
    @fail(reject_listener)

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

exports.ListenerList = ListenerList
exports.Promise      = Promise
exports.Deferred     = Deferred

#delay = (ms, task) ->
#  setTimeout task, ms
#
#task1 = ->
#  d = new Deferred()
#  delay 1000, ->
#    console.log "task1!!"
#    d.resolve()
#  d.promise()
#
#task2 = ->
#  d = new Deferred()
#  delay 1000, ->
#    console.log "task2!!"
#    d.resolve()
#  d.promise()
#
#task3 = ->
#  console.log "task3!!"
#
#task1().done(task2)
