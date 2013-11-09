class Cleancheese.Views.EpicsIndex extends Backbone.View

  template: JST['epics/index']

  initialize: ->
    @collection.on('sync', @render, this)
    @collection.on('remove', @render, this)

  render: ->
    $(@el).html(@template())
    @collection.each @append_epic
    this

  append_epic: (model) ->
    view = new Cleancheese.Views.Epic(model: model)
    el = $(view.render().el).addClass('epic')
    $('.epics').append(el)