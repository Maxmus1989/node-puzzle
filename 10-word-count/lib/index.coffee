through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 1
  characters = 0

  transform = (chunk, encoding, cb) ->
    characters = chunk.length
    lines = chunk.split(/\n/).length
    tokens = chunk.trim().replace(/\n/g, ' ').replace(/("[^"]*")/g, 'quote').replace(/([A-Z])/g, ' $1').split(' ').filter((w) -> w.length)
    words = tokens.length
    return cb()

  flush = (cb) ->
    this.push { words, lines, characters }
    this.push null
    return cb()

  return through2.obj transform, flush
