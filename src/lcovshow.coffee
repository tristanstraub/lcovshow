parse = require 'lcov-parse'
file = process.argv[2]
fs = require 'fs'
coffee = require 'coffee-script'
async = require 'async'

mergeLines = (details, jsLines) ->
  for entry in details
    entry.line = jsLines[entry.line - 1]

merge = (fileCov, js) ->
  jsLines = js.split '\n'
  mergeLines fileCov.lines.details, jsLines
  mergeLines fileCov.functions.details, jsLines
  mergeLines fileCov.branches.details, jsLines

toCoffee = (jsPath) ->
  jsPath.replace /[.]js$/, '.coffee'

compileToJs = (file, cb) ->
  fs.readFile file, 'utf8', (err, data) ->
    compiled = coffee.compile data
    cb null, compiled

getJs = (file, cb) ->
  compileToJs toCoffee(file), cb

exports.main = ->
  parse file, (err, data) ->
    if err then throw err
    async.forEach data, (fileCov, cb) ->
      getJs fileCov.file, (err, js) ->
        if err then return cb err
        merge fileCov, js
        cb()
    , (err) ->
      if err then throw err
      for fileCov in data
        process.stdout.write '// FILE: '
        process.stdout.write fileCov.file
        process.stdout.write '\n'
        for entry in fileCov.lines.details
          hit = if entry.hit then 1 else 0
          process.stdout.write hit.toString()
          process.stdout.write ' '
          process.stdout.write entry.line.toString()
          process.stdout.write '\n'
