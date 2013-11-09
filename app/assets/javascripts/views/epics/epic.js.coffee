class Cleancheese.Views.Epic extends Backbone.View
  template: JST['epics/epic']
  tagName: 'span'

  initialize: ->

  render: ->
    $(@el).html(@template(epic: @model))
    this