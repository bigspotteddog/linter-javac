{exec, child} = require 'child_process'
linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
{XRegExp} = require 'xregexp'
require 'shelljs/global'
path = require 'path'

class LinterJavac extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  # TODO: research if there are other java resources must be added
  @syntax: 'source.java'

  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  cmd: 'javac'

  linterName: 'javac'

  # A regex pattern used to extract information from the executable's output.
  regex: 'java:(?<line>\\d+): ((?<error>error)|(?<warning>warning)): (?<message>.+)\\n'

  constructor: (editor) ->
    super(editor)

    atom.config.observe 'linter-javac.javaExecutablePath', =>
      @executablePath = atom.config.get 'linter-javac.javaExecutablePath'

  destroy: ->
    atom.config.unobserve 'linter-javac.javaExecutablePath'

  errorStream: 'stderr'

  # Private: get command and args for atom.BufferedProcess for execution
  getCmdAndArgs: (filePath) ->
    cmd = @cmd

    @filePath = filePath

    # here guarantee `cmd` does not have space or quote mark issue
    #cmd_list = cmd.split(' ').concat [this.editor.buffer.file.path]
    cmd_list = cmd.split(' ').concat [filePath]

    if @executablePath
      cmd_list[0] = @executablePath + path.sep + cmd_list[0]

    command = atom.project.rootDirectories[0].path + path.sep + 'linter-javac'

    if test '-e', command
      cmd_list[0] = command

    # if there are "@filename" placeholders, replace them with real file path
    cmd_list = cmd_list.map (cmd_item) ->
      if /@filename/i.test(cmd_item)
        return cmd_item.replace(/@filename/gi, filePath)
      else
        return cmd_item

    if atom.config.get('linter.lintDebug')
      console.log 'command and arguments', cmd_list

    {
      command: cmd_list[0],
      args: cmd_list.slice(1)
    }

  processLines: (message) ->
    messages = []
    return messages if !message.length

    file = @editor.buffer.file.path
    split = message.split("\n")

    match = null

    for m in split
      if m.substring(0,1) is " "
        continue if !match
        match.message += ", " + m.trim()
      else
        if match
          try
            range = @computeRange match
          catch error
            console.log error
            range = new Range(
              [0, 0],
              [0, 0]
            )

          item =
            line: match.line
            level: match.type
            message: match.message
            linter: @linterName
            range: range

          messages.push item

        match = null

        l = m.split(/:\s?/)
        continue if l.length < 4

        filename = l[0]
        #continue if filename isnt file
        continue if filename isnt @filePath
        line = l[1]
        type = l[2]
        msg = l[3]
        info = l[4]

        match =
          filename: filename
          line: line
          type: type
          message: msg
          info: info

        match.message += ': ' + info if info
    messages

  processMessage: (message, callback) ->
    messages = @processLines message
    callback messages

module.exports = LinterJavac
