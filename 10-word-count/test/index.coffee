assert = require 'assert'
WordCount = require '../lib'


helper = (input, expected, done) ->
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

  counter.write input
  counter.end()


describe '10-word-count', ->
  it 'should count a single word', (done) ->
    input = 'test'
    expected = words: 1, lines: 1
    helper input, expected, done

  it 'should count words in a phrase', (done) ->
    input = 'this is a basic test'
    expected = words: 5, lines: 1
    helper input, expected, done

  it 'should count quoted characters as a single word', (done) ->
    input = '"this is one word!"'
    expected = words: 1, lines: 1
    helper input, expected, done

  it 'should count 2 quoted characters as 2 words', (done) ->
    input = '"this is one word!" "but now will become two words!"'
    expected = words: 2, lines: 1
    helper input, expected, done

  it 'should count quoted camel cased characters as a single word', (done) ->
    input = '"thisIsOneWord"'
    expected = words: 1, lines: 1
    helper input, expected, done

  it 'should count 2 camel cased characters within a quote as a single word', (done) ->
    input = '"thisIs OneWord"'
    expected = words: 1, lines: 1
    helper input, expected, done

  it 'should count lines', (done) ->
    input = 'result\nshould be\n3 lines with 8 words'
    expected = words: 8, lines: 3
    helper input, expected, done

  it 'should count empty lines', (done) ->
    input = 'result\n\n\nshould have 4 lines with 8 words'
    expected = words: 8, lines: 4
    helper input, expected, done

  it 'should count words with multiple space in between as 2 words', (done) ->
    input = 'two     words'
    expected = words: 2, lines: 1
    helper input, expected, done

  it 'should count complex words in multiple lines correctly', (done) ->
    input = 'this sentence \n shouldHave \n\n 5 " linesAnd 7" \nWords'
    expected = words: 7, lines: 5
    helper input, expected, done
