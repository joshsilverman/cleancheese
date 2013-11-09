class Cleancheese.Models.Task extends Backbone.Model

  defaults: {
    name: "new task"
  }

  epic: null

  initialize: (params) ->
    @create_epic_model(params)

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

  create_epic_model: (params) ->
    if params and params['epic']
      @epic = new Cleancheese.Models.Epic(params['epic'])