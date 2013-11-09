window.Cleancheese =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: -> 
    new Cleancheese.Routers.Tasks()
    Backbone.history.start()