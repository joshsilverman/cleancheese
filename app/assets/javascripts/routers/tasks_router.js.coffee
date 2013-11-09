class Cleancheese.Routers.Tasks extends Backbone.Router
  routes:
    '': 'index'
    'tasks/:id': 'show'

  initialize: ->
    @collection = new Cleancheese.Collections.Tasks()
    @collection.fetch()

    @epics_collection = new Cleancheese.Collections.Epics()
    @epics_collection.fetch()

  index: ->
    tasks_index_view = new Cleancheese.Views.TasksIndex(collection: @collection)
    $('#tasks_container').html(tasks_index_view.render().el)

    progress_header_view = new Cleancheese.Views.ProgressHeader(collection: @collection)
    $('#progress_header').html(progress_header_view.render().el)

    epics_index_view = new Cleancheese.Views.EpicsIndex(collection: @epics_collection)
    $('#epics_container').html(epics_index_view.render().el)

  show: (id) ->
    alert "Task #{id}"