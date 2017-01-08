through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 1
  characters = 0
  bytes = 0

  transform = (chunk, encoding, cb) ->
    characters = chunk.length
    bytes = Buffer.byteLength(chunk, encoding);
    lines = chunk.split(/\n/).filter((line) -> line.length).length
    tokens = chunk.trim().replace(/\n/g, ' ').replace(/("[^"]*")/g, 'quote').replace(/([a-z0-9])([A-Z])/g, '$1 $2').split(' ').filter((w) -> w.length)
    words = tokens.length
    return cb()

  flush = (cb) ->
    this.push { words, lines, characters, bytes }
    this.push null
    return cb()

  return through2.obj transform, flush
