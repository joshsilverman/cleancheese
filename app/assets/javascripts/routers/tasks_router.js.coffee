class Cleancheese.Routers.Tasks extends Backbone.Router
  routes:
    '': 'index'
    'tasks/:id': 'show'

  initialize: ->
    @collection = new Cleancheese.Collections.Tasks()
    @collection.fetch()

  index: ->
    view = new Cleancheese.Views.TasksIndex(collection: @collection)
    $('#container').html(view.render().el)

  show: (id) ->
    alert "Task #{id}"