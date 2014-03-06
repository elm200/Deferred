class ListenerList
  constructor: ->
    @listeners = []

  add: (listener) ->
    @listeners.push(listener)

  empty: ->
    @listeners = []

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

  fail: (listener) ->
    switch @state
      when "open"
        @reject_listeners.add(listener)
      when "rejected"
        listener.call()

# protected
  _resolve: ->
    @state = "resolved"
    @resolve_listeners.fire()
    @_empty_listeners()

  _rejected: ->
    @state = "rejected"
    @reject_listeners.fire()
    @_empty_listeners()

# private
  _empty_listeners: ->
    @resolve_listeners.empty()
    @reject_listeners.empty()

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
