class Cleancheese.Views.Task extends Backbone.View
  template: JST['tasks/task']
  events:
    "click .destroy": "destroy_task"
    "click .complete": "complete_task"
    "click .edit": "edit_task"
    "blur .name": "update_task"
    "keypress .name": "override_enter"

  render: ->
    $(@el).html(@template(task: @model))
    $(@el).addClass('complete') if @model.get('complete')
    this

  edit_task: (event) ->
    return if $(event.currentTarget).hasClass("new")
    task_el = $(event.target).parents('.task')
    Cleancheese.Views.Task.make_editable(task_el)

  update_task: (event) =>
    task_el = $(event.target).parents('.task')
    return if task_el.hasClass("new")
    name = task_el.find('.name').html().replace(/&nbsp;/g,'')
    @model.set name: name
    @model.save()

  destroy_task: (event) =>
    event.preventDefault()
    @model.destroy()

  complete_task: (event) =>
    event.preventDefault()
    new_state = @model.toggle()

  @make_editable: (task_el) ->
    name_el = task_el.find('.name')
    name_el.prop('contentEditable', true).focus()
    range = document.createRange()
    range.selectNodeContents(name_el[0])
    sel = window.getSelection()
    sel.removeAllRanges()
    sel.addRange(range)

  override_enter: (event) ->
    return unless event.keyCode == 13
    event.preventDefault()
    event.stopPropagation()
    $(@el).find('.name').blur()