# =# require helpers/spec_helper

describe 'TaskView', ->
  beforeEach ->
    @model = new Cleancheese.Models.Task(name: 'task 1')
    @view = new Cleancheese.Views.Task(model: @model)

  describe '#render', ->
    it 'has class .task', ->
      el = @view.render().el
      expect($(el).find('.name').html()).toEqual 'task 1'
    
    it 'does not have .epic when task does not have epic', ->
      el = @view.render().el
      expect($(el).find('.epic').length).toEqual 0

    it 'has .epic when task has epic', ->
      @epic_model = new Cleancheese.Models.Epic(name: 'epic 1')
      @model.set('epics', [@epic_model])

      el = @view.render().el
      
      expect($(el).find('.epic').html()).toEqual 'epic 1'