class Cleancheese.Models.Task extends Backbone.Model
  defaults: {
    name: "new task"
  }

  toggle: ->
    new_state = !@get("complete")
    @save(complete: new_state)
    new_state