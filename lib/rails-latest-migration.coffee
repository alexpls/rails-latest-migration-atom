fs = require 'fs'
Path = require 'path'
MigrationListView = require './migration-list-view'

module.exports =
  activate: ->
    atom.commands.add "atom-workspace",
      "rails-latest-migration:find": => @find(),
      "rails-latest-migration:list": => @list()

  find: ->
    @fetchListOfMigrations (migrations) ->
      latest_migration_path = migrations[0]
      atom.workspace.open(latest_migration_path)

  list: ->
    @fetchListOfMigrations (files) ->
      new MigrationListView(files)

  fetchListOfMigrations: (callback) ->
    dir = atom.project.getDirectories()[0]

    if @isRailsDir(dir)
      files = @getListOfMigrations(dir)

      if files.length > 0
        callback(files)
      else
        alert "Uh oh! Could not find any migrations in your db/migrate directory. Please add some and try again."
    else
      alert "Uh oh! This doesn't look like a Rails project. Please open a Rails project and try again."

  isRailsDir: (dir) ->
    expected_rails_files = ['app', 'db', 'config', 'Gemfile']
    entries = dir.getEntriesSync()
    matching_dirs = []

    entries.forEach (entry) ->
      if expected_rails_files.indexOf(entry.getBaseName()) > -1
        matching_dirs.push(entry)

    return expected_rails_files.length == matching_dirs.length

  getMigrationsDir: (dir) ->
    Path.join(dir.getPath(), 'db', 'migrate')

  getListOfMigrations: (dir) ->
    migrations_dir = @getMigrationsDir(dir)

    files = fs.readdirSync(migrations_dir).filter (elem) ->
      stat = fs.statSync(Path.join(migrations_dir, elem))
      return stat.isFile()

    files.reverse().map (file) ->
      Path.join(migrations_dir, file)
