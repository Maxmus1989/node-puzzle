fs = require 'fs'
readline = require 'readline'

exports.countryIpCounter = (countryCode, cb) ->
  return cb() unless countryCode

  counter = 0
  input = fs.createReadStream "#{__dirname}/../data/geo.txt", 'utf8'
  rl = readline.createInterface { input }

  rl.on 'line', (line) ->
    line = line.toString().split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    # line[0],       line[1],       line[3]

    if line[3] == countryCode then counter += +line[1] - +line[0]

  rl.on 'close', -> cb null, counter
