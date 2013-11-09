# include spec/javascripts/helpers/spec_helper.js and app/assets/javascripts/foo.js
# =# require helpers/spec_helper

describe 'Task', ->
  describe '#initialize', ->
    it "returns null if no epics for task", ->
      @model = new Cleancheese.Models.Task
      
      expect(@model.epic).toEqual null

    it "returns epic model if epic params passed to new Task", ->
      @epic_params = name: 'epic 1'
      @epic_model = new Cleancheese.Models.Epic(name: 'epic 1')
      @model = new Cleancheese.Models.Task('complete': false, 'epic': @epic_params)
      
      expect(@model.epic.get('name')).toEqual @epic_model.get('name')