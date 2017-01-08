assert = require 'assert'
WordCount = require '../lib'


helper = (input, encoding, expected, done) ->
  pass = false
  counter = new WordCount()

  counter.on 'readable', ->
    return unless result = this.read()
    assert.deepEqual result, expected
    assert !pass, 'Are you sure everything works as expected?'
    pass = true

  counter.on 'end', ->
    if pass then return done()
    done new Error 'Looks like transform fn does not work'

  counter.write input, encoding
  counter.end()


describe '10-word-count', ->
  encoding = 'utf8'

  it 'should count a single word', (done) ->
    input = 'test'
    expected = words: 1, lines: 1, characters: 4, bytes: 4
    helper input, encoding, expected, done

  it 'should count words in a phrase', (done) ->
    input = 'this is a basic test'
    expected = words: 5, lines: 1, characters: 20, bytes: 20
    helper input, encoding, expected, done

  it 'should count words with multiple space in between as 2 words', (done) ->
    input = 'two     words'
    expected = words: 2, lines: 1, characters: 13, bytes: 13
    helper input, encoding, expected, done

  describe 'quote string', ->
    it 'should count quoted characters as a single word', (done) ->
      input = '"this is one word!"'
      expected = words: 1, lines: 1, characters: 19, bytes: 19
      helper input, encoding, expected, done

    it 'should count 2 quoted characters as 2 words', (done) ->
      input = '"this is one word!" "but now will become two words!"'
      expected = words: 2, lines: 1, characters: 52, bytes: 52
      helper input, encoding, expected, done

    it 'should count quoted camel cased characters as a single word', (done) ->
      input = '"thisIsOneWord"'
      expected = words: 1, lines: 1, characters: 15, bytes: 15
      helper input, encoding, expected, done

    it 'should count 2 camel cased characters within a quote as a single word', (done) ->
      input = '"thisIs OneWord"'
      expected = words: 1, lines: 1, characters: 16, bytes: 16
      helper input, encoding, expected, done

  describe 'camel cased words', ->
    it 'should count camel cased word as 4 words', (done) ->
      input = 'thisIsFourWord'
      expected = words: 4, lines: 1, characters: 14, bytes: 14
      helper input, encoding, expected, done

    it 'should count as all uppercase word as one words ', (done) ->
      input = 'THISISONEWORD'
      expected = words: 1, lines: 1, characters: 13, bytes: 13
      helper input, encoding, expected, done

  describe 'count lines', ->
    it 'should count multiple lines', (done) ->
      input = 'result\nshould be\n3 lines with 8 words'
      expected = words: 8, lines: 3, characters: 37, bytes: 37
      helper input, encoding, expected, done

    it 'should not count empty lines', (done) ->
      input = 'result\n\n\nshould have 4 lines with 8 words'
      expected = words: 8, lines: 2, characters: 41, bytes: 41
      helper input, encoding, expected, done

  describe 'fixture and complex case', ->
    it 'should pass fixture 1,9,44', (done) ->
      input = 'The quick brown fox jumps over the lazy dog\n'
      expected = words: 9, lines: 1, characters: 44, bytes: 44
      helper input, encoding, expected, done

    it 'should pass fixture 3,7,46', (done) ->
      input = 'The\n"Quick Brown Fox"\njumps over the lazy dog\n'
      expected = words: 7, lines: 3, characters: 46, bytes: 46
      helper input, encoding, expected, done

    it 'should pass fixture 5,9,40', (done) ->
      input = 'TheQuick\nBrownFox\njumps\nOverTheLazy\ndog\n'
      expected = words: 9, lines: 5, characters: 40, bytes: 40
      helper input, encoding, expected, done

    it 'should count complex words in multiple lines correctly', (done) ->
      input = 'this sentence \n shouldHave \n\n 5 " linesAnd 7" \nWords'
      expected = words: 7, lines: 4, characters: 52, bytes: 52
      helper input, encoding, expected, done

  describe 'count characters', ->
    it 'should count characters in word', (done) ->
      input = '11Characters'
      expected = words: 2, lines: 1, characters: 12, bytes: 12
      helper input, encoding, expected, done

    it 'should count empty string as 0 characters', (done) ->
      input = ''
      expected = words: 0, lines: 0, characters: 0, bytes: 0
      helper input, encoding, expected, done

    it 'should count space as a character', (done) ->
      input = ' '
      expected = words: 0, lines: 1, characters: 1, bytes: 1
      helper input, encoding, expected, done

    it 'should count 2 empty lines as 2 characters', (done) ->
      input = '\n\n'
      expected = words: 0, lines: 0, characters: 2, bytes: 2
      helper input, encoding, expected, done

  describe 'bytes with encoding', ->
    it 'should return 4 bytes for 4 characters word with utf8 encoding', (done) ->
      input = 'TEST'
      expected = words: 1, lines: 1, characters: 4, bytes: 4
      helper input, encoding, expected, done

    it 'should return 4 bytes for 4 character word with ascii encoding', (done) ->
      input = 'TEST'
      encoding = 'ascii'
      expected = words: 1, lines: 1, characters: 4, bytes: 4
      helper input, encoding, expected, done

    it 'should return 8 bytes for 4 characters word with utf16le encoding', (done) ->
      input = 'TEST'
      encoding = 'utf16le'
      expected = words: 1, lines: 1, characters: 4, bytes: 8
      helper input, encoding, expected, done

    it 'should return 8 bytes for 4 characters word with ucs2 encoding', (done) ->
      input = 'TEST'
      encoding = 'ucs2'
      expected = words: 1, lines: 1, characters: 4, bytes: 8
      helper input, encoding, expected, done

    it 'should return 3 bytes for 4 characters word with base64 encoding', (done) ->
      input = 'TEST'
      encoding = 'base64'
      expected = words: 1, lines: 1, characters: 4, bytes: 3
      helper input, encoding, expected, done

    it 'should return 4 bytes for 4 character word with latin1 encoding', (done) ->
      input = 'TEST'
      encoding = 'latin1'
      expected = words: 1, lines: 1, characters: 4, bytes: 4
      helper input, encoding, expected, done

    it 'should return 4 bytes for 4 characters word with binary encoding', (done) ->
      input = 'TEST'
      encoding = 'binary'
      expected = words: 1, lines: 1, characters: 4, bytes: 4
      helper input, encoding, expected, done

    it 'should return 2 bytes for 4 characters word with hex encoding', (done) ->
      input = 'TEST'
      encoding = 'hex'
      expected = words: 1, lines: 1, characters: 4, bytes: 2
      helper input, encoding, expected, done