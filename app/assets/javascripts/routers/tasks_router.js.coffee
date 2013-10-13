class Cleancheese.Routers.Tasks extends Backbone.Router
  routes:
    '': 'index'
    'tasks/:id': 'show'

  initialize: ->
    @collection = new Cleancheese.Collections.Tasks()
    @collection.fetch()

  index: ->
    tasks_view = new Cleancheese.Views.TasksIndex(collection: @collection)
    progress_header_view = new Cleancheese.Views.ProgressHeader(collection: @collection)
    $('#container').html(tasks_view.render().el)
    $('#progress_header').html(progress_header_view.render().el)

  show: (id) ->
    alert "Task #{id}"