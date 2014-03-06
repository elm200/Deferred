hm = require('../hello.coffee')

describe "hello", ->
  it "explains hello", ->
    expect(hm.hello()).toEqual("hello!")
