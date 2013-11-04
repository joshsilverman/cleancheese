# include spec/javascripts/helpers/spec_helper.js and app/assets/javascripts/foo.js
# =# require helpers/spec_helper
# =# require foo
describe 'Task', ->
  describe '#toggle', ->
    it "returns new state of model", ->
      @task = new Cleancheese.Models.Task('complete', false)
      # @task.set('complete', false)
      
      new_state = @task.toggle()

      expect(new_state).toBe true