class Cleancheese.Models.Task extends Backbone.Model

  defaults: {
    name: "new task"
  }

  toggle: ->
    new_state = !@get("complete")
    @once('sync', @test, this)
    @save(complete: new_state)
    new_state

  update_rank: (new_rank) ->
    @save(rank: new_rank)
    new_rank

  test: ->
    @fetch()