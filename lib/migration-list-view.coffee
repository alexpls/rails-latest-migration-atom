{ $$, SelectListView } = require 'atom-space-pen-views'

module.exports =
class MigrationListView extends SelectListView
  initialize: (@data = []) ->
    super
    @show()
    @parseData()

  parseData: ->
    migrations = @data.map (migration) ->
      [..., name] = migration.split('/')

      { name: name, file: migration }

    @setItems migrations
    @focusFilterEditor()

  getFilterKey: -> 'name'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()

  cancelled: -> @hide()

  hide: -> @panel?.destroy()

  viewForItem: ({name}) ->
    $$ -> @li(name)

  confirmed: ({file}) ->    
    atom.workspace.open(file)
    @cancel()
