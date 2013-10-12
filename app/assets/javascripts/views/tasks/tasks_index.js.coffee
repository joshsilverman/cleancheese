class Cleancheese.Views.TasksIndex extends Backbone.View
  template: JST['tasks/index']
  events:
    "click .tasks .new": "new_task"
    "blur .tasks .new": "create_task"

  initialize: ->
    @collection.on('sync', @render, this)
    @collection.on('remove', @render, this)

  render: ->
    $(@el).html(@template())
    @collection.each @append_task
    @append_task new Cleancheese.Models.Task
    this

  append_task: (task) ->
    view = new Cleancheese.Views.Task(model: task)
    el = $(view.render().el)
    el.addClass('new') if (task.get('id') == undefined)
    $('.table.tasks').append el

  new_task: (event) ->
    task_el = $(event.currentTarget)
    Cleancheese.Views.Task.make_editable(task_el)

  create_task: (event) ->
    name_el = $(event.target)
    name = name_el.html()
    @collection.create name: name