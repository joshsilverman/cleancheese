class Cleancheese.Views.ProgressHeader extends Backbone.View
  template: JST['tasks/progress_header']
  tagName: 'ul'

  render: ->
    progress_units = @progress_units()
    console.log(Object.keys(progress_units))
    console.log(progress_units)
    $(@el).html(@template(progress_units: progress_units))
    this

  progress_units: ->
    s: false,
    m: true,
    t: false,
    w: true,
    r: false,
    f: false,
    u: false