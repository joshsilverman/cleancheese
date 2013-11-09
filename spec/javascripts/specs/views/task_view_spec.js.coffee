# =# require helpers/spec_helper

describe 'TaskView', ->
  beforeEach ->
    @model = new Cleancheese.Models.Task(name: 'task 1')
    @view = new Cleancheese.Views.Task(model: @model)

  describe '#render', ->
    it 'has class .task', ->
      el = @view.render().el
      expect($(el).find('.name').html()).toEqual 'task 1'
    
    it 'does not have .epic-label when task does not have epic', ->
      el = @view.render().el
      expect($(el).find('.epic-label').length).toEqual 0

    it 'has .epic-label when task has epic', ->
      @epic_model = new Cleancheese.Models.Epic(name: 'epic 1')
      @model.epic = @epic_model

      el = @view.render().el
      
      expect($(el).find('.epic-label').html()).toEqual 'epic 1'