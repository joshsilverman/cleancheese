class Cleancheese.Views.TasksIndex extends Backbone.View

  template: JST['tasks/index']

  initialize: ->
    @collection.on('sync', @render, this)

  render: ->
    $(@el).html(@template(tasks: @collection))
    this