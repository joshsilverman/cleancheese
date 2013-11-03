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
    @make_sortable()
    this

  append_task: (task) ->
    view = new Cleancheese.Views.Task(model: task)
    el = $(view.render().el).addClass('task')
    el.addClass('new') if (task.get('id') == undefined)
    $(el).data('id', task.get('id')) unless (task.get('id') == undefined)
    $('.tasks').append el

  new_task: (event) ->
    task_el = $(event.currentTarget)
    Cleancheese.Views.Task.make_editable(task_el)

  create_task: (event) ->
    name_el = $(event.target)
    name = name_el.html()
    @collection.create name: name

  update_rank: (event, ui) =>
    task_el = ui.item
    task = @collection.where(id: $(task_el).data('id'))[0]
    @collection.off('sync', @render, this)
    task.once('sync', => @collection.fetch())
    @collection.on('sync', => @collection.on('sync', @render, this))
    task.update_rank(task_el.prevAll().length)

  make_sortable: ->
    $(@el).sortable(
        items: '.task:not(.new)', 
        axis: 'y',
        beforeStop: @update_rank,
        handle: '.handle',
        distance: 15,
        grid: [ 0, 20 ]
      ).disableSelection()