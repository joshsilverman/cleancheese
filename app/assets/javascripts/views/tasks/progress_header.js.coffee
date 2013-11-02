class Cleancheese.Views.ProgressHeader extends Backbone.View
  template: JST['tasks/progress_header']
  tagName: 'ul'

  initialize: ->
    @collection.on('sync', @render, this)

  render: ->
    progress_units = @progress_units()
    $(@el).html(@template(progress_units: progress_units))
    this

  progress_units: ->
    units = [false, false, false, false, false, false, false]
    for task in @collection.where(complete:true)
      date_str = task.get('completed_at')
      date_str
      if date_str
        date = new Date(date_str)
        day_index = date.getDay()
        units[day_index] = true
    units