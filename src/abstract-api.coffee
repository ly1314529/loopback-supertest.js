chai      = require 'chai'
expect    = chai.expect

Request   = require './'
inherits  = require 'inherits-ex/lib/inherits'
extend    = require 'util-ex/lib/_extend'
isObject  = require 'util-ex/lib/is/type/object'


module.exports = class AbstractApi
  inherits AbstractApi, Request

  constructor: (aServer, aApp, aName)->
    return new AbstractApi(aServer, aApp, aName) unless this instanceof AbstractApi
    super aServer, aApp, aName
  createItem: (aItem, stCode = 200)->
    vData = data: aItem if aItem
    @post vData
    .expect stCode
    .expect 'Content-Type', /application\/json/
    .then (response)->
      if stCode is 200
        aItem.id = response.body.id if !aItem.id? and response.body.id?
        expected = extend {}, aItem
        delete expected.password
        delete expected.accessToken
        expect(response.body).to.containSubset expected
      response
  delItem: (aItem, stCode = 200)->
    @delete encodeURIComponent aItem.id
    .expect stCode
  getItem: (aItem, stCode = 200)->
    @get encodeURIComponent aItem.id
    .expect stCode
    .then (response)->
      # expect(response).to.have.property 'status', stCode
      if stCode is 200
        expected = extend {}, aItem
        delete expected.password
        delete expected.accessToken
        expect(response.body).to.containSubset expected
      response
  editItem: (aItem, stCode = 200)->
    @put encodeURIComponent aItem.id
    .expect stCode
    .then (response)->
      if stCode is 200
        expected = extend {}, aItem
        delete expected.password
        delete expected.accessToken
        expect(response.body).to.containSubset expected
      response
  isExists: (aItem, aIsExists = true)->
    stCode = if aIsExists then 200 else 404
    @head encodeURIComponent aItem.id
    .expect stCode
    .then (res)->
      res.statusCode is 200
  find: (aFilter, stCode = 200)->
    result = @get()
    if isObject aFilter
      for key, value of aFilter
        aFilter[key] = JSON.stringify value
      result.query filter: aFilter
    result.expect stCode
  findOne: (aFilter, stCode = 200)->
    result = @get 'findOne'
    if isObject aFilter
      for key, value of aFilter
        aFilter[key] = JSON.stringify value
      result.query filter: aFilter
    result.expect stCode
